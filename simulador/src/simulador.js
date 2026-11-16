// Versión ejecutable directa con Node.js puro
const args = process.argv.slice(2);
function leerParametro(nombre, porDefecto) {
  const arg = args.find((a) => a.startsWith(`--${nombre}=`));
  if (arg) return arg.split('=')[1];
  return process.env[nombre.toUpperCase()] || porDefecto;
}

const BACKEND_URL = leerParametro('backend_url', 'http://localhost:3000');
const TOKEN_DISPOSITIVO = leerParametro('token_dispositivo', 'compostera-token-local');
const DISPOSITIVO = leerParametro('dispositivo', 'compostera-01');
const INTERVALO_MS = parseInt(leerParametro('intervalo_ms', '10000'), 10);
const MODO = leerParametro('modo', 'normal').toLowerCase();

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

let paso = 0;
let temperaturaBase = 32.0;
let humedadBase = 56.0;

function calcularLectura() {
  paso++;

  switch (MODO) {
    case 'humedad_baja': {
      const temp = 36.5 + (Math.sin(paso * 0.2) * 2.0);
      const hum = 34.0 + (Math.random() * 5.0);
      return {
        temperatura: parseFloat(temp.toFixed(1)),
        humedad: parseFloat(hum.toFixed(1)),
      };
    }
    case 'humedad_alta': {
      const temp = 28.0 + (Math.sin(paso * 0.2) * 2.0);
      const hum = 66.0 + (Math.random() * 6.0);
      return {
        temperatura: parseFloat(temp.toFixed(1)),
        humedad: parseFloat(hum.toFixed(1)),
      };
    }
    case 'temperatura_alta': {
      const temp = 68.0 + (Math.random() * 5.5);
      const hum = 46.0 + (Math.random() * 4.0);
      return {
        temperatura: parseFloat(temp.toFixed(1)),
        humedad: parseFloat(hum.toFixed(1)),
      };
    }
    case 'temperatura_baja': {
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
      if (paso < 10) {
        temperaturaBase += 1.2;
      } else if (paso < 25) {
        temperaturaBase = 52.0 + Math.sin(paso * 0.3) * 4.0;
      } else {
        temperaturaBase = 46.0 + Math.cos(paso * 0.2) * 3.0;
      }

      humedadBase -= 0.15;
      if (humedadBase < 47.0) {
        humedadBase = 58.0;
      }

      const ruidoTemp = (Math.random() - 0.5) * 0.8;
      const ruidoHum = (Math.random() - 0.5) * 1.0;

      return {
        temperatura: parseFloat((temperaturaBase + ruidoTemp).toFixed(1)),
        humedad: parseFloat((humedadBase + ruidoHum).toFixed(1)),
      };
    }
  }
}

async function transmitirLectura() {
  const { temperatura, humedad } = calcularLectura();
  const momento = new Date().toISOString();

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
      const evaluacion = await respuesta.json();
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

console.log(`${c.verde}✔ Inicialización de Wi-Fi 802.11 b/g/n exitosa. Conectado al AP.${c.reset}`);
console.log(`${c.gris}Presiona Ctrl + C para detener la simulación.${c.reset}\n`);

void transmitirLectura();

setInterval(() => {
  void transmitirLectura();
}, INTERVALO_MS);

