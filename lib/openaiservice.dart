//This File can be used to get answers from chatgpt.. but requires chatgpt paid subscription.
import 'dart:convert';
// import 'package:assistant/secrets.dart'; Stores API key
import 'package:http/http.dart' as http;

class Openaiservice {
  final List<Map<String, String>> messages = [];
  Future<String> isArtprompt(String prompt) async {
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $openAIAPIKey', // Replace with your OpenAI API key
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'user',
              'content':
                  "Does this prompt ask for an image? $prompt", // Ask the model if the prompt is asking for an image
            },
          ],
        }),
      );

      if (res.statusCode == 200) {
        String content = jsonDecode(res.body)['choices'][0]['message']
                    ['content']
                ?.toLowerCase()
                ?.trim() ??
            '';
        if (content.contains('yes')) {
          return await dallEAPI(prompt);
        } else {
          return await chatGPTAPI(prompt);
        }
      } else {
        print('Error Response: ${res.body}');
        print('Rate limit error. Headers: ${res.headers}');

        return 'API returned an error: ${res.statusCode}, ${res.reasonPhrase}';
      }
    } catch (e) {
      print('Exception: $e');
      return 'Error: $e';
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $openAIAPIKey', // Replace with your OpenAI API key
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': messages,
        }),
      );

      print('Response: ${res.body}');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['choices'] != null && body['choices'].isNotEmpty) {
          String content = body['choices'][0]['message']['content'] ?? '';
          content = content.trim();
          messages.add({
            'role': 'assistant',
            'content': content,
          });
          return content;
        }
      }
      return 'Unexpected API response format';
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String> dallEAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $openAIAPIKey', // Replace with your OpenAI API key
        },
        body: jsonEncode({
          'prompt': prompt,
          'n': 1,
          'size': '1024x1024',
        }),
      );

      print('Response: ${res.body}');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['data'] != null && body['data'].isNotEmpty) {
          String image = body['data'][0]['url'] ?? '';
          messages.add({
            'role': 'assistant',
            'content': image,
          });
          return image;
        }
      }
      return 'Unexpected API response format';
    } catch (e) {
      return 'Error: $e';
    }
  }
}
