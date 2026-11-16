import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../data/mock_lecturas.dart';
import '../models/lectura.dart';

class ApiService {
  // En emulador Android, 10.0.2.2 accede al localhost de la máquina anfitriona
  // En pruebas de escritorio / web, se utiliza 127.0.0.1 o localhost
  static String baseUrl = Platform.isAndroid ? 'http://10.0.2.2:3000' : 'http://127.0.0.1:3000';

  // Caché en memoria para acciones registradas por el usuario
  static final List<Map<String, dynamic>> _accionesLocales = [
    {
      'dispositivo': 'compostera-01',
      'tipo': 'volteo',
      'momento': DateTime.now().subtract(const Duration(hours: 4)).toUtc().toIso8601String(),
    },
    {
      'dispositivo': 'compostera-01',
      'tipo': 'riego',
      'momento': DateTime.now().subtract(const Duration(days: 1, hours: 2)).toUtc().toIso8601String(),
    },
  ];

  /// Obtiene el historial de mediciones desde el backend con fallback a Mock
  static Future<List<Lectura>> obtenerLecturas({
    String dispositivo = 'compostera-01',
    String? desde,
    String? hasta,
  }) async {
    try {
      final queryParams = <String, String>{'dispositivo': dispositivo};
      if (desde != null) queryParams['desde'] = desde;
      if (hasta != null) queryParams['hasta'] = hasta;

      final uri = Uri.parse('$baseUrl/api/lecturas').replace(queryParameters: queryParams);
      
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 3);
      final request = await client.getUrl(uri);
      request.headers.set('Accept', 'application/json');
      
      final response = await request.close().timeout(const Duration(seconds: 4));
      
      if (response.statusCode == 200) {
        final bodyStr = await response.transform(utf8.decoder).join();
        final data = jsonDecode(bodyStr) as Map<String, dynamic>;
        final listaJson = data['lecturas'] as List<dynamic>? ?? [];
        
        if (listaJson.isNotEmpty) {
          return listaJson
              .map((item) => Lectura.fromJson(item as Map<String, dynamic>))
              .toList()
            ..sort((a, b) => a.momento.compareTo(b.momento));
        }
      }
    } catch (_) {
      // Si el backend no está disponible o timeout, fallback a mock continuo
    }

    return getLecturasMock();
  }

  /// Obtiene la última lectura registrada
  static Future<Lectura> obtenerUltimaLectura({
    String dispositivo = 'compostera-01',
  }) async {
    final lista = await obtenerLecturas(dispositivo: dispositivo);
    if (lista.isNotEmpty) {
      return lista.last;
    }
    return getLecturasMock().last;
  }

  /// Registra una acción de mantenimiento (volteo, riego, etc.) en el backend
  static Future<bool> registrarAccion({
    required String dispositivo,
    required String tipo,
  }) async {
    final momento = DateTime.now().toUtc().toIso8601String();
    
    // Guardar en caché local inmediatamente
    _accionesLocales.insert(0, {
      'dispositivo': dispositivo,
      'tipo': tipo,
      'momento': momento,
    });

    try {
      final uri = Uri.parse('$baseUrl/api/acciones');
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 3);
      final request = await client.postUrl(uri);
      request.headers.contentType = ContentType.json;
      
      final payload = jsonEncode({
        'dispositivo': dispositivo,
        'tipo': tipo,
        'momento': momento,
      });
      request.write(payload);

      final response = await request.close().timeout(const Duration(seconds: 4));
      return response.statusCode == 201;
    } catch (_) {
      // Aunque el backend no responda, la acción quedó guardada localmente
      return true;
    }
  }

  /// Lista las acciones registradas para la bitácora
  static Future<List<Map<String, dynamic>>> obtenerAcciones({
    String dispositivo = 'compostera-01',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/acciones?dispositivo=$dispositivo');
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 3);
      final request = await client.getUrl(uri);
      final response = await request.close().timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final bodyStr = await response.transform(utf8.decoder).join();
        final data = jsonDecode(bodyStr) as Map<String, dynamic>;
        final lista = (data['acciones'] as List<dynamic>?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList();
        if (lista != null && lista.isNotEmpty) {
          return lista;
        }
      }
    } catch (_) {}

    return _accionesLocales;
  }
}
