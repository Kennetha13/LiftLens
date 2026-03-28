import 'dart:convert';

/// Structured result parsed from Gemini's JSON response.
class AnalysisResult {
  const AnalysisResult({
    required this.exerciseName,
    required this.formScore,
    required this.overallSummary,
    required this.metrics,
    required this.issues,
    required this.strengths,
  });

  final String exerciseName;
  final int formScore; // 0–100
  final String overallSummary;
  final List<FormMetric> metrics;
  final List<FormIssue> issues;
  final List<String> strengths;

  /// Parses Gemini's raw text output into an [AnalysisResult].
  /// Strips markdown fences if present, then decodes JSON.
  factory AnalysisResult.fromGeminiText(String raw) {
    // Strip ```json ... ``` or ``` ... ``` fences that the model sometimes adds
    String cleaned = raw.trim();
    if (cleaned.startsWith('```')) {
      final firstNewline = cleaned.indexOf('\n');
      if (firstNewline != -1) cleaned = cleaned.substring(firstNewline + 1);
      if (cleaned.endsWith('```')) {
        cleaned = cleaned.substring(0, cleaned.length - 3).trim();
      }
    }

    final Map<String, dynamic> json = jsonDecode(cleaned) as Map<String, dynamic>;

    return AnalysisResult(
      exerciseName: (json['exerciseName'] as String?) ?? 'Weightlifting',
      formScore: (json['formScore'] as num?)?.toInt() ?? 0,
      overallSummary: (json['overallSummary'] as String?) ?? '',
      metrics: ((json['metrics'] as List<dynamic>?) ?? [])
          .map((e) => FormMetric.fromJson(e as Map<String, dynamic>))
          .toList(),
      issues: ((json['issues'] as List<dynamic>?) ?? [])
          .map((e) => FormIssue.fromJson(e as Map<String, dynamic>))
          .toList(),
      strengths: ((json['strengths'] as List<dynamic>?) ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class FormMetric {
  const FormMetric({
    required this.name,
    required this.score,
    required this.feedback,
  });

  final String name;
  final int score; // 0–100
  final String feedback;

  factory FormMetric.fromJson(Map<String, dynamic> json) => FormMetric(
        name: (json['name'] as String?) ?? '',
        score: (json['score'] as num?)?.toInt() ?? 0,
        feedback: (json['feedback'] as String?) ?? '',
      );
}

class FormIssue {
  const FormIssue({
    required this.title,
    required this.severity,
    required this.description,
    this.fix,
  });

  final String title;
  final IssueSeverity severity;
  final String description;
  final String? fix;

  factory FormIssue.fromJson(Map<String, dynamic> json) {
    final severityStr =
        (json['severity'] as String?)?.toLowerCase() ?? 'moderate';
    final severity = severityStr == 'critical'
        ? IssueSeverity.critical
        : severityStr == 'good'
            ? IssueSeverity.good
            : IssueSeverity.moderate;

    return FormIssue(
      title: (json['title'] as String?) ?? '',
      severity: severity,
      description: (json['description'] as String?) ?? '',
      fix: json['fix'] as String?,
    );
  }
}

enum IssueSeverity { critical, moderate, good }
