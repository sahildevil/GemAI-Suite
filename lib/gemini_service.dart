import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final String apiKey = 'GEMINI API KEY'; // Your Gemini API Key

  Future<String> getGeminiResponse(String prompt) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: apiKey,
      );

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      return response.text ?? 'No response generated.';
    } catch (e) {
      return 'Error: $e';
    }
  }
}
