import 'dart:convert';
import 'package:http/http.dart' as http;

class GemmaPhrasesService {
  bool _isInitialized = false;
  
  // Configuración de la API de DigitalOcean Agent Platform
  static const String _apiUrl = 'https://xbenlpmsypv35esm3p23xgen.agents.do-ai.run/api/v1/chat/completions';
  static const String _apiKey = 'mpQLiBtjIJyM3nKVr86G5uE10PJjDNjI';
  
  /// Inicializa el servicio
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    print('✅ Servicio de IA inicializado (API DigitalOcean)');
  }

  /// Verifica si el servicio está listo
  bool isReady() => _isInitialized;

  /// Genera frases motivacionales basadas en una meta específica
  Future<List<String>> generatePhrasesForGoal({
    required String goalTitle,
    required String goalDescription,
    int count = 5,
    bool brutalMode = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'messages': [
            {
              'role': 'user',
              'content': goalTitle,
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        // Parsear el JSON dentro del content
        final phrasesJson = jsonDecode(content);
        final frases = List<String>.from(phrasesJson['frases']);
        
        print('✅ Generadas ${frases.length} frases con IA');
        return frases.take(count).toList();
      } else {
        print('❌ Error API: ${response.statusCode}');
        return _getFallbackPhrases(goalTitle, count);
      }
    } catch (e) {
      print('❌ Error generando frases: $e');
      return _getFallbackPhrases(goalTitle, count);
    }
  }

  /// Genera frases genéricas sin meta específica
  Future<List<String>> generateGenericPhrases({
    int count = 10,
    bool brutalMode = true,
  }) async {
    return generatePhrasesForGoal(
      goalTitle: 'disciplina',
      goalDescription: '',
      count: count,
      brutalMode: brutalMode,
    );
  }

  /// Regenera una frase específica con variaciones
  Future<List<String>> regeneratePhrase(String originalPhrase, int variations) async {
    return generatePhrasesForGoal(
      goalTitle: originalPhrase,
      goalDescription: '',
      count: variations,
      brutalMode: true,
    );
  }

  /// Frases de respaldo si falla la API
  List<String> _getFallbackPhrases(String goalTitle, int count) {
    return [
      'No hay excusas, solo $goalTitle por conquistar',
      'El dolor es temporal, la victoria es para siempre',
      '$goalTitle no es una meta, es un desafío a tu límite',
      'La mente es más fuerte que el cuerpo, haz que te obedezca',
      'Actúa como si tu vida dependiera de ello, porque tu orgullo sí',
    ].take(count).toList();
  }

  /// Libera recursos del servicio
  void dispose() {
    _isInitialized = false;
  }

  /// Verifica si el servicio está configurado correctamente
  bool isConfigured() {
    return true; // Siempre disponible con API
  }
}
