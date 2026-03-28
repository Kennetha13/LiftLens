import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/analysis_result.dart';

/// Handles the complete Veo 3 video generation lifecycle:
/// 1. Build an instructional prompt from the AnalysisResult
/// 2. POST to Veo's predictLongRunning endpoint
/// 3. Poll the operation until complete
/// 4. Decode & save the MP4 to a temp file
/// 5. Return the local file path for video_player
class VeoService {
  VeoService({required this.apiKey});

  final String apiKey;

  static const _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const _pollInterval = Duration(seconds: 5);
  static const _maxPolls = 120;

  // ── Prompt Builder ──────────────────────────────────────────────────────────

  /// Builds a structured Veo 3 prompt using the 5-part cinematic formula:
  /// [Cinematography] + [Subject] + [Action] + [Context] + [Style & Ambiance]
  ///
  /// Prioritizes Critical issues first, then Moderate, then Good — matching
  /// the exact corrections from Gemini's analysis.
  static String buildVeoPrompt(AnalysisResult result) {
    // Sort issues: Critical → Moderate → Good
    final sorted = [...result.issues]..sort((a, b) {
        const order = {
          IssueSeverity.critical: 0,
          IssueSeverity.moderate: 1,
          IssueSeverity.good: 2,
        };
        return (order[a.severity] ?? 3).compareTo(order[b.severity] ?? 3);
      });

    final fixableIssues =
        sorted.where((i) => i.severity != IssueSeverity.good).toList();

    // Top 2 most critical corrections get on-screen arrows & labels
    final priorityIssues =
        fixableIssues.take(2).toList();
    final secondaryIssues =
        fixableIssues.skip(2).toList();

    // Build arrow/label descriptions for the top priority issues
    final arrowDescriptions = priorityIssues.map((i) {
      final raw = (i.fix ?? i.description)
          .replaceAll(RegExp(r'^💡 FIX:\s*'), '');
      // Create a short label (max 3 words) for the on-screen text overlay
      final shortLabel = i.title.split(' ').take(2).join(' ').toUpperCase();
      return '  - Animated arrow pointing to the $shortLabel area with text label "$shortLabel: ${_shortenFix(raw)}"';
    }).join('\n');

    // Build correction action lines for secondary issues
    final secondaryLines = secondaryIssues.isNotEmpty
        ? '\nAdditionally demonstrate: ${secondaryIssues.map((i) => i.title).join(", ")}.'
        : '';

    // Identify primary focus for Action segment
    final primaryFocus = priorityIssues.isNotEmpty
        ? priorityIssues.first.title
        : '${result.exerciseName} perfect form';

    final exerciseLower = result.exerciseName.toLowerCase();

    // ── 5-Part Cinematic Prompt ────────────────────────────────────────────
    return '''
Wide-angle side shot at 45 degrees showing the full body from head to feet with slight slow-motion at 0.6x speed, \
a professional fitness coach and athlete with perfect posture, \
performing one complete slow and flawless $exerciseLower repetition with deliberate emphasis on $primaryFocus, \
in a clean modern gym with subtle equipment visible in the background and a plain light-grey wall, \
instructional coaching aesthetic with bright even studio lighting and crisp shallow depth of field.

ON-SCREEN VISUAL ANNOTATIONS (critical — must appear in the video):
$arrowDescriptions

FORM CORRECTIONS TO DEMONSTRATE:
${fixableIssues.map((i) {
      final fix = (i.fix ?? i.description).replaceAll(RegExp(r'^💡 FIX:\s*'), '');
      final priority = i.severity == IssueSeverity.critical ? '[CRITICAL]' : '[MODERATE]';
      return '  $priority ${i.title}: $fix';
    }).join('\n')}
$secondaryLines

KEY STYLE NOTES:
  - The movement must be precise and educational — NOT fast or athletic
  - Each correction point should be highlighted visually as the movement passes through it
  - Smooth camera, no cuts, clean professional look
  - Athlete wears fitted athletic wear, gym is well-lit with no shadows on form
''';
  }

  /// Shortens a fix description to a concise on-screen label (max 5 words).
  static String _shortenFix(String fix) {
    final words = fix.split(' ');
    if (words.length <= 5) return fix;
    return '${words.take(5).join(' ')}…';
  }


  /// Full pipeline: builds prompt → generates with Veo 3 → returns network video URL.
  Future<String> generateCorrectionVideo({
    required AnalysisResult result,
    void Function(String status)? onStatus,
  }) async {
    onStatus?.call('Building instructional prompt from your corrections…');
    final prompt = buildVeoPrompt(result);

    onStatus?.call('Sending request to Veo 3…');
    final operationName = await _startGeneration(prompt);

    onStatus?.call('Veo 3 is generating your instructional video…\n(This usually takes 1–3 minutes)');
    return _pollUntilDone(operationName, onStatus);
  }

  // ── Private Methods ─────────────────────────────────────────────────────────

  Future<String> _startGeneration(String prompt) async {
    final url = Uri.parse('$_baseUrl/models/$veoModel:predictLongRunning');

    final body = jsonEncode({
      'instances': [
        {'prompt': prompt}
      ],
      'parameters': {
        'sampleCount': 1,
        'aspectRatio': '9:16',
        'resolution': '1080p',
      },
    });

    debugPrint('=== VEO REQUEST ===');
    debugPrint('Model: $veoModel');
    debugPrint('URL: $url');
    debugPrint('Body: $body');

    final r = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey, // Correct auth method for Gemini API
      },
      body: body,
    );

    debugPrint('=== VEO RESPONSE ===');
    debugPrint('Status: ${r.statusCode}');
    debugPrint('Body: ${r.body}');

    if (r.statusCode != 200) {
      throw VeoException('Veo start failed (${r.statusCode}):\n${r.body}');
    }

    final decoded = jsonDecode(r.body) as Map<String, dynamic>;
    final name = decoded['name'] as String?;
    if (name == null || name.isEmpty) {
      throw VeoException('Missing operation name in response:\n${r.body}');
    }
    debugPrint('=== VEO OPERATION: $name ===');
    return name;
  }

  /// Polls the operation and returns the network video URL when done.
  Future<String> _pollUntilDone(
    String operationName,
    void Function(String status)? onStatus,
  ) async {
    final url = Uri.parse('$_baseUrl/$operationName');

    for (var i = 0; i < _maxPolls; i++) {
      await Future<void>.delayed(_pollInterval);

      final r = await http.get(
        url,
        headers: {'x-goog-api-key': apiKey},
      );

      if (r.statusCode != 200) {
        throw VeoException('Poll failed (${r.statusCode}): ${r.body}');
      }

      final decoded = jsonDecode(r.body) as Map<String, dynamic>;
      final done = decoded['done'] as bool? ?? false;

      if (!done) {
        final elapsed = (i + 1) * _pollInterval.inSeconds;
        onStatus?.call('Generating… ${elapsed}s elapsed\n(typically 60–180 seconds)');
        continue;
      }

      if (decoded.containsKey('error')) {
        throw VeoException('Veo returned an error: ${decoded['error']}');
      }

      final response = decoded['response'] as Map<String, dynamic>?;
      if (response == null) {
        throw VeoException('Generation done but no response data: $decoded');
      }

      debugPrint('=== VEO DONE RESPONSE: $response ===');

      final videoUri = _extractVideoUri(response);
      if (videoUri == null || videoUri.isEmpty) {
        throw VeoException('Generation done but no video URI found in: $response');
      }

      // Append the API key so the URL is directly playable
      final playableUri = videoUri.contains('key=')
          ? videoUri
          : '$videoUri${videoUri.contains('?') ? '&' : '?'}key=$apiKey';

      debugPrint('=== VEO VIDEO URI: $playableUri ===');
      return playableUri;
    }

    throw VeoException(
        'Timed out waiting for Veo after ${_maxPolls * _pollInterval.inSeconds}s.');
  }

  /// Tries all known response shapes from Veo REST API.
  String? _extractVideoUri(Map<String, dynamic> response) {
    // Shape 1: predictions[0].generatedSamples[0].video.uri (most common)
    final predictions = response['predictions'];
    if (predictions is List && predictions.isNotEmpty) {
      final samples = (predictions.first as Map<String, dynamic>)['generatedSamples'];
      if (samples is List && samples.isNotEmpty) {
        final uri = (samples.first as Map<String, dynamic>)['video']?['uri'] as String?;
        if (uri != null) return uri;
      }
    }

    // Shape 2: generateVideoResponse.generatedSamples[0].video.uri
    final gvr = response['generateVideoResponse'] as Map<String, dynamic>?;
    if (gvr != null) {
      final samples = gvr['generatedSamples'] as List<dynamic>?;
      if (samples != null && samples.isNotEmpty) {
        return (samples.first as Map<String, dynamic>)['video']?['uri'] as String?;
      }
    }

    // Shape 3: videos[0].uri
    final videos = response['videos'] as List<dynamic>?;
    if (videos != null && videos.isNotEmpty) {
      final v = videos.first as Map<String, dynamic>;
      return v['uri'] as String? ?? v['videoAttributes']?['uri'] as String?;
    }

    return null;
  }
}

class VeoException implements Exception {
  VeoException(this.message);
  final String message;

  @override
  String toString() => message;
}
