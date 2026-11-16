import 'dotenv/config';

// Configuración con valores por defecto o pasados por banderas CLI (--modo=, --intervalo=)
const args = process.argv.slice(2);
function leerParametro(nombre: string, porDefecto: string): string {
  const arg = args.find((a) => a.startsWith(`--${nombre}=`));
  if (arg) return arg.split('=')[1];
  return process.env[nombre.toUpperCase()] || porDefecto;
}

const BACKEND_URL = leerParametro('backend_url', 'http://localhost:3000');
const TOKEN_DISPOSITIVO = leerParametro('token_dispositivo', 'compostera-token-local');
const DISPOSITIVO = leerParametro('dispositivo', 'compostera-01');
const INTERVALO_MS = parseInt(leerParametro('intervalo_ms', '10000'), 10);
const MODO = leerParametro('modo', 'normal').toLowerCase();

// Colores ANSI para terminal
const c = {
  reset: '\x1b[0m',
  verde: '\x1b[32m',
  amarillo: '\x1b[33m',
  rojo: '\x1b[31m',
  azul: '\x1b[36m',
  negrita: '\x1b[1m',
  gris: '\x1b[90m',
  blanco: '\x1b[37m',
};

console.log(`${c.verde}
╔════════════════════════════════════════════════════════════════════════════╗
║                🌱 SIMULADOR HARDWARE ESP32 - COMPOSTERA                    ║
║         Microcontrolador: ESP32 Tensilica Xtensa Dual-Core 2.4GHz         ║
║         Sensores: DHT22 (Temp/Hum aire) + Sonda humedad sustrato          ║
╚════════════════════════════════════════════════════════════════════════════╝${c.reset}`);

console.log(`${c.negrita}Configuración activa:${c.reset}`);
console.log(`  • Dispositivo:      ${c.azul}${DISPOSITIVO}${c.reset}`);
console.log(`  • Backend URL:      ${c.azul}${BACKEND_URL}${c.reset}`);
console.log(`  • Token Bearer:     ${c.gris}${TOKEN_DISPOSITIVO.substring(0, 10)}...${c.reset}`);
console.log(`  • Frecuencia:       ${c.azul}Cada ${INTERVALO_MS / 1000} segundos${c.reset}`);
console.log(`  • Modo Simulación:  ${c.amarillo}${MODO.toUpperCase()}${c.reset}\n`);

// Estado interno para la curva de compostaje termófila realista
let paso = 0;
let temperaturaBase = 32.0; // Inicia en fase mesófila
let humedadBase = 56.0;      // Inicia en rango óptimo (45 - 60%)

function calcularLectura(): { temperatura: number; humedad: number } {
  paso++;

  switch (MODO) {
    case 'humedad_baja': {
      // Simula mezcla seca (< 45%)
      const temp = 36.5 + (Math.sin(paso * 0.2) * 2.0);
      const hum = 34.0 + (Math.random() * 5.0); // 34% - 39%
      return {
        temperatura: parseFloat(temp.toFixed(1)),
        humedad: parseFloat(hum.toFixed(1)),
      };
    }

    case 'humedad_alta': {
      // Simula mezcla encharcada/exceso de agua (> 60%)
      const temp = 28.0 + (Math.sin(paso * 0.2) * 2.0);
      const hum = 66.0 + (Math.random() * 6.0); // 66% - 72%
      return {
        temperatura: parseFloat(temp.toFixed(1)),
        humedad: parseFloat(hum.toFixed(1)),
      };
    }

    case 'temperatura_alta': {
      // Simula sobrecalentamiento crítico (> 65°C)
      const temp = 68.0 + (Math.random() * 5.5); // 68°C - 73.5°C
      const hum = 46.0 + (Math.random() * 4.0);
      return {
        temperatura: parseFloat(temp.toFixed(1)),
        humedad: parseFloat(hum.toFixed(1)),
      };
    }

    case 'temperatura_baja': {
      // Simula compost frío (< 20°C)
      const temp = 14.0 + (Math.random() * 4.0);
      const hum = 48.0 + (Math.random() * 4.0);
      return {
        temperatura: parseFloat(temp.toFixed(1)),
        humedad: parseFloat(hum.toFixed(1)),
      };
    }

    case 'sin_datos': {
      console.log(`${c.rojo}⚠ Modo 'sin_datos' activado. El nodo ESP32 entró en deep-sleep indefinido y no transmitirá paquetes.${c.reset}`);
      process.exit(0);
    }

    case 'normal':
    default: {
      // Curva termófila realista: la temperatura asciende gradualmente hacia la fase termófila (45°C - 58°C)
      if (paso < 10) {
        temperaturaBase += 1.2; // Fase mesófila en calentamiento
      } else if (paso < 25) {
        temperaturaBase = 52.0 + Math.sin(paso * 0.3) * 4.0; // Fase termófila activa
      } else {
        temperaturaBase = 46.0 + Math.cos(paso * 0.2) * 3.0; // Fase de enfriamiento / maduración
      }

      // La humedad disminuye lentamente por evaporación (salvo riego)
      humedadBase -= 0.15;
      if (humedadBase < 47.0) {
        humedadBase = 58.0; // Simula un riego automático o manual periódico
      }

      // Ruido realista de sensor (±0.4°C, ±0.5%)
      const ruidoTemp = (Math.random() - 0.5) * 0.8;
      const ruidoHum = (Math.random() - 0.5) * 1.0;

      return {
        temperatura: parseFloat((temperaturaBase + ruidoTemp).toFixed(1)),
        humedad: parseFloat((humedadBase + ruidoHum).toFixed(1)),
      };
    }
  }
}

async function transmitirLectura(): Promise<void> {
  const { temperatura, humedad } = calcularLectura();
  const momento = new Date().toISOString(); // Formato RFC 3339 / ISO 8601 UTC con 'Z'

  const paquete = {
    dispositivo: DISPOSITIVO,
    temperatura,
    humedad,
    momento,
  };

  const horaLocal = new Date().toLocaleTimeString();
  process.stdout.write(`${c.gris}[${horaLocal}]${c.reset} ${c.azul}📡 ESP32 enviando paquete...${c.reset} `);

  try {
    const respuesta = await fetch(`${BACKEND_URL}/api/lecturas`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${TOKEN_DISPOSITIVO}`,
      },
      body: JSON.stringify(paquete),
    });

    if (respuesta.status === 201) {
      const evaluacion = (await respuesta.json()) as {
        estado: string;
        recomendacion: string;
        severidad: string;
      };

      let badgeColor = c.verde;
      if (evaluacion.severidad === 'advertencia') badgeColor = c.amarillo;
      if (evaluacion.severidad === 'critico') badgeColor = c.rojo;

      console.log(`${c.verde}HTTP 201 OK${c.reset}`);
      console.log(`   ├─ Temp: ${c.negrita}${temperatura} °C${c.reset} | Hum: ${c.negrita}${humedad} %${c.reset}`);
      console.log(`   ├─ Estado evaluado: ${badgeColor}${evaluacion.estado.toUpperCase()}${c.reset} (${evaluacion.severidad})`);
      console.log(`   └─ Recomendación: ${c.blanco}"${evaluacion.recomendacion}"${c.reset}\n`);
    } else {
      const errTexto = await respuesta.text();
      console.log(`${c.rojo}HTTP ${respuesta.status} ERROR${c.reset}: ${errTexto}`);
    }
  } catch (error) {
    console.log(`${c.rojo}Fallo de conexión:${c.reset} ¿El backend está corriendo en ${BACKEND_URL}?`);
  }
}

// Iniciar transmisión
console.log(`${c.verde}✔ Inicialización de Wi-Fi 802.11 b/g/n exitosa. Conectado al AP.${c.reset}`);
console.log(`${c.gris}Presiona Ctrl + C para detener la simulación.${c.reset}\n`);

// Primera transmisión inmediata
void transmitirLectura();

// Intervalo cíclico (simula el ciclo de deep-sleep y transmisión)
setInterval(() => {
  void transmitirLectura();
}, INTERVALO_MS);
