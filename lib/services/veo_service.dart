import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class VeoService {
  // TODO: Put your Gemini API Key here
  static const String _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  /// Sends a request to generate a video based on a prompt.
  /// Returns the operation name to poll.
  Future<String> generateVideo(String prompt) async {
    if (_apiKey.isEmpty) {
      throw Exception('API Key is missing. Please run with --dart-define=GEMINI_API_KEY=your_key');
    }

    final url = Uri.parse('$_baseUrl/models/veo-3.1-generate-preview:predictLongRunning');
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': _apiKey, // Most modern Google APIs prefer this header
      },
      body: jsonEncode({
        "instances": [
          {"prompt": prompt}
        ],
        "parameters": {
          "sampleCount": 1,
          "aspectRatio": "9:16",
          "resolution": "1080p"
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['name']; // This is the operation name
    } else {
      // Parse the error message from the response if possible
      String errorMessage = response.body;
      try {
        final errorJson = jsonDecode(response.body);
        if (errorJson['error'] != null && errorJson['error']['message'] != null) {
          errorMessage = errorJson['error']['message'];
        }
      } catch (_) {}
      
      throw Exception('Veo API Error: $errorMessage (Status: ${response.statusCode})');
    }
  }

  /// Polls the operation status until it's done.
  /// Returns the video URL if successful.
  Future<String?> pollOperation(String operationName) async {
    final url = Uri.parse('$_baseUrl/$operationName');
    
    // Simple polling loop
    for (int i = 0; i < 60; i++) { // Max 5 minutes (60 * 5s)
      final response = await http.get(
        url,
        headers: {'x-goog-api-key': _apiKey},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['done'] == true) {
          if (data['error'] != null) {
            throw Exception('Generation failed: ${data['error']['message']}');
          }
          
          // Removed debug print for security
          
          final res = data['response'];
          if (res != null) {
            // Path 1: predictions array (most common for predictLongRunning)
            if (res['predictions'] != null && res['predictions'] is List && res['predictions'].isNotEmpty) {
              final samples = res['predictions'][0]['generatedSamples'];
              if (samples != null && samples is List && samples.isNotEmpty) {
                final uri = samples[0]['video']?['uri'];
                if (uri != null) return _prepareUri(uri);
              }
            }

            // Path 2: generateVideoResponse (sometimes used in v1beta)
            if (res['generateVideoResponse'] != null) {
              final samples = res['generateVideoResponse']['generatedSamples'];
              if (samples != null && samples is List && samples.isNotEmpty) {
                final uri = samples[0]['video']?['uri'];
                if (uri != null) return _prepareUri(uri);
              }
            }

            // Path 3: Direct videos array
            if (res['videos'] != null && res['videos'] is List && res['videos'].isNotEmpty) {
              final uri = res['videos'][0]['uri'] ?? res['videos'][0]['videoAttributes']?['uri'];
              if (uri != null) return _prepareUri(uri);
            }
          }
          
          // Path 4: Check metadata if response is empty
          if (data['metadata'] != null && data['metadata']['outputUri'] != null) {
            return _prepareUri(data['metadata']['outputUri']);
          }
          
          return null;
        }
      } else {
        throw Exception(_scrub('Failed to check status: ${response.body} (Status: ${response.statusCode})'));
      }
      
      await Future.delayed(const Duration(seconds: 5));
    }
    
    throw Exception('Timed out waiting for video generation');
  }

  // Helper to remove the API key from any strings (like error messages)
  String _scrub(String text) {
    if (_apiKey.isEmpty) return text;
    return text.replaceAll(_apiKey, '***REDACTED***');
  }

  // Define a helper to ensure URIs have the API key
  String _prepareUri(String uri) {
    if (uri.contains('key=')) return uri;
    return uri + (uri.contains('?') ? '&key=$_apiKey' : '?key=$_apiKey');
  }
}
