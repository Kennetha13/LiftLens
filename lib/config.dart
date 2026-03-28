/// Google AI Studio: https://aistudio.google.com/apikey
///
/// Run the app with your key (never commit real keys to source):
///   flutter run --dart-define=GEMINI_API_KEY=your_key_here
const String apiKey = String.fromEnvironment(
  'GEMINI_API_KEY',
  defaultValue: '',
);

/// Gemini model for video analysis.
/// Gemini model for video analysis.
const String geminiModel = 'models/gemini-3-flash-preview';
