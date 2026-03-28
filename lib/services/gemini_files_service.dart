import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config.dart';

/// Gemini Files API upload + generateContent via direct REST calls.
/// Adapted from test_gemini/lib/gemini_files_service.dart.
class GeminiFilesService {
  GeminiFilesService({required this.apiKey, String? model})
      : model = model ?? geminiModel;

  final String apiKey;
  final String model;

  static final Uri _uploadStart = Uri.parse(
    'https://generativelanguage.googleapis.com/upload/v1beta/files',
  );
  static const _pollInterval = Duration(seconds: 3);
  static const _maxPolls = 400; // ~20 minutes of polling for large videos

  /// Fixed coaching prompt — users never type their own prompt.
  static const String liftingPrompt = '''
You are an expert strength and conditioning coach analyzing a weightlifting video.

Analyze the athlete's form carefully and return ONLY valid JSON (no markdown fences, no explanation text, just the raw JSON object) matching this exact schema:
{
  "exerciseName": "string (e.g. Back Squat, Deadlift, Bench Press)",
  "formScore": <integer 0-100>,
  "overallSummary": "string (2-3 sentences summarizing the lift quality)",
  "metrics": [
    { "name": "string", "score": <integer 0-100>, "feedback": "string (one sentence)" }
  ],
  "issues": [
    { "title": "string", "severity": "Critical|Moderate|Good", "description": "string (1-2 sentences)", "fix": "string or null" }
  ],
  "strengths": ["string"]
}

Rules:
- Include 4-6 metrics. Common ones: Depth, Bar Path, Knee Tracking, Spine Neutral, Tempo, Hip Hinge, Foot Position, Lockout.
- Include 2-4 issues. Use severity "Good" for positive observations (no fix needed).
- strengths should be 2-4 short bullet points.
- All scores are integers 0-100.
- Return ONLY the JSON object. No markdown. No prose before or after.
''';

  /// Uploads bytes, waits until ACTIVE, runs generateContent, cleans up.
  Future<String> uploadProcessAndGenerate({
    required List<int> bytes,
    required String mimeType,
    required String displayName,
    void Function(String status)? onStatus,
    bool deleteFileAfter = true,
  }) async {
    onStatus?.call('Uploading video to Gemini…');
    final fileName = await _resumableUpload(
      bytes: bytes,
      mimeType: mimeType,
      displayName: displayName,
    );

    try {
      onStatus?.call('Processing video on Google servers…');
      final fileUri = await _waitUntilActive(fileName, onStatus);

      onStatus?.call('Analyzing your form with AI…');
      final text = await _generateContent(
        fileUri: fileUri,
        mimeType: mimeType,
      );
      return text;
    } finally {
      if (deleteFileAfter) {
        try {
          await _deleteFile(fileName);
        } catch (_) {
          // Best-effort cleanup — ignore errors
        }
      }
    }
  }

  Future<String> _resumableUpload({
    required List<int> bytes,
    required String mimeType,
    required String displayName,
  }) async {
    final client = http.Client();
    try {
      final start = http.Request(
        'POST',
        _uploadStart.replace(queryParameters: {'key': apiKey}),
      );
      start.headers.addAll({
        'X-Goog-Upload-Protocol': 'resumable',
        'X-Goog-Upload-Command': 'start',
        'X-Goog-Upload-Header-Content-Length': '${bytes.length}',
        'X-Goog-Upload-Header-Content-Type': mimeType,
        'Content-Type': 'application/json',
      });
      start.body = jsonEncode({
        'file': {'display_name': displayName},
      });

      final streamed = await client.send(start);
      final responseBody = await streamed.stream.bytesToString();

      if (streamed.statusCode != 200) {
        throw GeminiFilesException(
          'Upload start failed (${streamed.statusCode}): $responseBody',
        );
      }

      final uploadUrl =
          _headerIgnoreCase(streamed.headers, 'x-goog-upload-url');
      if (uploadUrl == null || uploadUrl.isEmpty) {
        throw GeminiFilesException('Missing X-Goog-Upload-URL header');
      }

      final upload = http.Request('POST', Uri.parse(uploadUrl.trim()));
      upload.headers.addAll({
        'Content-Length': '${bytes.length}',
        'X-Goog-Upload-Offset': '0',
        'X-Goog-Upload-Command': 'upload, finalize',
      });
      upload.bodyBytes =
          bytes is Uint8List ? bytes : Uint8List.fromList(bytes);

      final uploadResp =
          await http.Response.fromStream(await client.send(upload));
      if (uploadResp.statusCode != 200) {
        throw GeminiFilesException(
          'Upload failed (${uploadResp.statusCode}): ${uploadResp.body}',
        );
      }

      final decoded = jsonDecode(uploadResp.body) as Map<String, dynamic>;
      final file = decoded['file'] as Map<String, dynamic>?;
      final name = file?['name'] as String?;
      if (name == null || name.isEmpty) {
        throw GeminiFilesException('Upload response missing file.name');
      }
      return name;
    } finally {
      client.close();
    }
  }

  static Map<String, dynamic> _fileRecordFromGetResponse(
      Map<String, dynamic> decoded) {
    final nested = decoded['file'];
    if (nested is Map<String, dynamic>) return nested;
    return decoded;
  }

  static String? _normState(Map<String, dynamic> file) {
    final s = file['state'];
    if (s == null) return null;
    return s.toString().toUpperCase();
  }

  static String? _fileUri(Map<String, dynamic> file) {
    for (final key in ['uri', 'fileUri', 'file_uri']) {
      final u = file[key];
      if (u is String && u.isNotEmpty) return u;
    }
    return null;
  }

  Future<String> _waitUntilActive(
    String fileName,
    void Function(String status)? onStatus,
  ) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/$fileName',
    ).replace(queryParameters: {'key': apiKey});

    String? lastState;
    for (var i = 0; i < _maxPolls; i++) {
      final r = await http.get(uri);
      if (r.statusCode != 200) {
        throw GeminiFilesException(
            'File status failed (${r.statusCode}): ${r.body}');
      }
      final decoded = jsonDecode(r.body) as Map<String, dynamic>;
      final file = _fileRecordFromGetResponse(decoded);
      final state = _normState(file);
      final fileUri = _fileUri(file);
      lastState = state ?? lastState;

      if (state == 'ACTIVE') {
        if (fileUri == null || fileUri.isEmpty) {
          throw GeminiFilesException('ACTIVE file missing uri');
        }
        return fileUri;
      }
      if (state == 'FAILED') {
        throw GeminiFilesException(
          'File processing failed: ${file['error'] ?? r.body}',
        );
      }

      final label = state ?? 'UNKNOWN';
      onStatus?.call('Processing on Google… ($label) · attempt ${i + 1}');
      await Future<void>.delayed(_pollInterval);
    }
    throw GeminiFilesException(
      'Timed out waiting for file to become ACTIVE '
      '(last state: ${lastState ?? "null"}). '
      'Try a shorter clip.',
    );
  }

  Future<String> _generateContent({
    required String fileUri,
    required String mimeType,
  }) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/$model:generateContent',
    ).replace(queryParameters: {'key': apiKey});

    final body = jsonEncode({
      'contents': [
        {
          'role': 'user',
          'parts': [
            {
              'file_data': {
                'mime_type': mimeType,
                'file_uri': fileUri,
              },
            },
            {'text': liftingPrompt},
          ],
        },
      ],
    });

    final r = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (r.statusCode != 200) {
      throw GeminiFilesException(
        'generateContent failed (${r.statusCode}): ${r.body}',
      );
    }

    final decoded = jsonDecode(r.body) as Map<String, dynamic>;
    final candidates = decoded['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      final promptFeedback = decoded['promptFeedback'];
      throw GeminiFilesException('No candidates: $promptFeedback');
    }

    final parts = (candidates.first as Map<String, dynamic>)['content']
        ?['parts'] as List<dynamic>?;
    if (parts == null) return '';

    final buffer = StringBuffer();
    for (final p in parts) {
      final text = (p as Map<String, dynamic>)['text'] as String?;
      if (text != null) buffer.write(text);
    }
    final out = buffer.toString();
    return out.isEmpty ? 'No text in response.' : out;
  }

  Future<void> _deleteFile(String fileName) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/$fileName',
    ).replace(queryParameters: {'key': apiKey});
    final r = await http.delete(uri);
    if (r.statusCode != 200 && r.statusCode != 204) {
      throw GeminiFilesException(
          'Delete failed (${r.statusCode}): ${r.body}');
    }
  }

  static String? _headerIgnoreCase(
      Map<String, String> headers, String name) {
    final lower = name.toLowerCase();
    for (final e in headers.entries) {
      if (e.key.toLowerCase() == lower) return e.value;
    }
    return null;
  }
}

class GeminiFilesException implements Exception {
  GeminiFilesException(this.message);
  final String message;

  @override
  String toString() => message;
}
