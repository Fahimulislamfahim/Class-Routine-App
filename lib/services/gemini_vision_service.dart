import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/routine_model.dart';

class GeminiVisionService {
  static const String defaultModel = 'gemini-2.5-flash';

  static const String systemPrompt =
      "You are a university schedule extraction assistant. Analyze the uploaded class routine image and extract all scheduled class sessions into structured JSON.\n\n"
      "Rules:\n"
      "1. Examine the grid structure where columns represent weekdays (Saturday through Friday) and rows represent time slots.\n"
      "2. For each occupied cell, extract:\n"
      "   - day: Full weekday name (e.g., 'Sunday', 'Wednesday').\n"
      "   - startTime and endTime: 24-hour format (HH:mm), e.g., '10:00' and '11:30'.\n"
      "   - courseTitle: Full name of the course. Expand obvious abbreviations or ellipses (e.g., 'Software Engineerin...' -> 'Software Engineering', 'Artificial Intellig...' -> 'Artificial Intelligence').\n"
      "   - courseCode: The alphanumeric code (e.g., 'SE331', 'SE334').\n"
      "   - facultyInitial: Instructor short code/initial (e.g., 'SSA', 'JA', 'MSA').\n"
      "   - room: Room identifier (e.g., 'AB3-106', '711B', 'ONLINE').\n"
      "   - type: 'lab' or 'theory'.\n"
      "   - subgroup: \n"
      "       * Match the section letter extracted from the routine metadata. For example:\n"
      "         - If Section is A, extract 'A1' for Lab 1 / Lab A1, and 'A2' for Lab 2 / Lab A2.\n"
      "         - If Section is D, extract 'D1' for Lab 1 / Lab D1, and 'D2' for Lab 2 / Lab D2.\n"
      "         - For any Section X, use 'X1' for group 1 and 'X2' for group 2.\n"
      "       * 'ALL' if it is a general theory lecture or applies to the whole section.\n"
      "3. Extract metadata: batch, section, department, and effectiveDate.\n"
      "4. Ignore empty grid slots.\n"
      "5. Return ONLY valid JSON matching the schema below.";

  static final Map<String, dynamic> geminiResponseSchema = {
    "type": "OBJECT",
    "required": ["metadata", "schedule"],
    "properties": {
      "metadata": {
        "type": "OBJECT",
        "required": ["batch", "section", "department"],
        "properties": {
          "batch": {"type": "STRING"},
          "section": {"type": "STRING"},
          "department": {"type": "STRING"},
          "effectiveDate": {"type": "STRING"},
        },
      },
      "schedule": {
        "type": "ARRAY",
        "items": {
          "type": "OBJECT",
          "required": [
            "day",
            "startTime",
            "endTime",
            "courseTitle",
            "courseCode",
            "type",
            "subgroup",
            "room",
          ],
          "properties": {
            "day": {
              "type": "STRING",
              "enum": [
                "Saturday",
                "Sunday",
                "Monday",
                "Tuesday",
                "Wednesday",
                "Thursday",
                "Friday",
              ],
            },
            "startTime": {"type": "STRING"},
            "endTime": {"type": "STRING"},
            "courseTitle": {"type": "STRING"},
            "courseCode": {"type": "STRING"},
            "facultyInitial": {"type": "STRING"},
            "room": {"type": "STRING"},
            "type": {
              "type": "STRING",
              "enum": ["theory", "lab"],
            },
            "subgroup": {
              "type": "STRING",
              "description":
                  "Subgroup identifier aligned with section: 'A1', 'A2', 'B1', 'B2', 'D1', 'D2', etc., or 'ALL' for theory/whole section.",
            },
          },
        },
      },
    },
  };

  /// Extracts routine from image bytes using Gemini Multimodal Vision API
  Future<RoutineModel> extractRoutineFromImage({
    required Uint8List imageBytes,
    required String apiKey,
    String mimeType = 'image/jpeg',
    String model = defaultModel,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw Exception('Gemini API Key is required. Please set your API key in settings.');
    }

    final base64Image = base64Encode(imageBytes);

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=${apiKey.trim()}',
    );

    final requestBody = {
      "systemInstruction": {
        "parts": [
          {"text": systemPrompt},
        ],
      },
      "contents": [
        {
          "parts": [
            {
              "text":
                  "Extract all university class routine sessions and metadata from this routine image strictly according to the specified rules and JSON schema.",
            },
            {
              "inlineData": {
                "mimeType": mimeType,
                "data": base64Image,
              },
            },
          ],
        },
      ],
      "generationConfig": {
        "responseMimeType": "application/json",
        "responseSchema": geminiResponseSchema,
        "temperature": 0.1,
      },
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200) {
      try {
        final errJson = jsonDecode(response.body);
        final errMsg = errJson['error']?['message'] ?? response.body;
        throw Exception('Gemini API Error (${response.statusCode}): $errMsg');
      } catch (e) {
        if (e is Exception && e.toString().contains('Gemini API Error')) {
          rethrow;
        }
        throw Exception('Gemini API Request failed (${response.statusCode}): ${response.body}');
      }
    }

    final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = responseJson['candidates'] as List<dynamic>?;

    if (candidates == null || candidates.isEmpty) {
      throw Exception('No response candidates returned from Gemini Vision model.');
    }

    final firstCandidate = candidates.first as Map<String, dynamic>;
    final content = firstCandidate['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;

    if (parts == null || parts.isEmpty) {
      throw Exception('Empty content parts returned from Gemini Vision model.');
    }

    final rawText = parts.first['text'] as String? ?? '';
    final cleanedJson = _cleanJsonText(rawText);

    try {
      final parsed = jsonDecode(cleanedJson) as Map<String, dynamic>;
      return RoutineModel.fromJson(parsed);
    } catch (e) {
      throw Exception('Failed to parse model output into RoutineModel: $e\nOutput was: $rawText');
    }
  }

  static String _cleanJsonText(String text) {
    var cleaned = text.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    return cleaned.trim();
  }
}
