import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/data_models.dart';

class GeminiAIService {
  static const String _apiKey = 'AIzaSyB3BcqurFOtSHFKkvKCZ9EN7P3l1SLycUs';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  
  final Uuid _uuid = const Uuid();

  /// Agentic AI: Analyzes symptoms and optional images (CV) to create a proactive plan.
  Future<HealthAssessment> analyzeSymptoms({
    required List<String> symptoms, 
    required String additionalText,
    Uint8List? imageBytes,
    String language = 'English',
  }) async {
    final prompt = _buildAgenticPrompt(symptoms, additionalText, language);
    
    final List<Map<String, dynamic>> parts = [
      {'text': prompt}
    ];

    if (imageBytes != null) {
      parts.add({
        'inline_data': {
          'mime_type': 'image/jpeg',
          'data': base64Encode(imageBytes)
        }
      });
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': parts}],
          'generationConfig': {
            'temperature': 0.4,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 2048,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseAgenticResponse(data, symptoms);
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      return _fallbackAssessment(symptoms, additionalText);
    }
  }

  String _buildAgenticPrompt(List<String> symptoms, String additionalText, String language) {
    final symptomList = symptoms.isNotEmpty ? symptoms.join(', ') : 'None specified';
    
    return '''
You are MediConnect Health Agent, a state-of-the-art proactive AI healthcare assistant. 
Analyze the provided symptoms and any visual data (if provided via image).

PATIENT DATA:
• Language: $language
• Symptoms: $symptomList
• Patient Description: $additionalText

TASK:
1. Act as a Health Agent: Don't just diagnose, create an "Action Plan".
2. Computer Vision: If an image is provided (skin rash, prescription, etc.), analyze its visual characteristics.
3. Multi-language: Provide your response in $language.

Respond with ONLY JSON:
{
  "condition": "Name of condition",
  "riskLevel": "low" | "medium" | "high",
  "description": "2-3 sentences about the condition.",
  "agenticPlan": {
    "immediateActions": ["Action 1", "Action 2"],
    "nextFollowUp": "When the agent should check back",
    "coordinationNeeded": "Clinic visit or home care?"
  },
  "medicines": [
    {"name": "...", "dosage": "...", "frequency": "...", "notes": "..."}
  ],
  "homeRemedies": ["..."],
  "warningSignsToWatch": ["..."],
  "referralCoordinates": {"lat": 28.6139, "lng": 77.2090, "name": "Nearest AI-Recommended Clinic"}
}

AGENTIC GUIDELINES:
- Be the patient's coordinator.
- Use simple, culturally relevant terms for $language.
- If an image is present, mention visual findings (e.g., "The image shows redness...")
''';
  }

  HealthAssessment _parseAgenticResponse(Map<String, dynamic> apiResponse, List<String> symptoms) {
    try {
      final responseText = apiResponse['candidates'][0]['content']['parts'][0]['text'] as String;
      final cleanJson = responseText.replaceAll('```json', '').replaceAll('```', '').trim();
      final json = jsonDecode(cleanJson);
      
      RiskLevel riskLevel;
      switch (json['riskLevel']?.toString().toLowerCase()) {
        case 'high': riskLevel = RiskLevel.high; break;
        case 'medium': riskLevel = RiskLevel.medium; break;
        default: riskLevel = RiskLevel.low;
      }
      
      List<Medicine> medicines = (json['medicines'] as List? ?? []).map((m) => Medicine(
        name: m['name'] ?? '',
        dosage: m['dosage'] ?? '',
        frequency: m['frequency'] ?? '',
        notes: m['notes'],
      )).toList();

      // Combine direct recommendation with agentic plan
      final plan = json['agenticPlan'] ?? {};
      final rec = "Plan: ${plan['immediateActions']?.join(', ')}. Coordination: ${plan['coordinationNeeded']}";

      return HealthAssessment(
        id: _uuid.v4(),
        date: DateTime.now(),
        reportedSymptoms: symptoms,
        possibleCondition: json['condition'] ?? 'Assessment',
        riskLevel: riskLevel,
        description: json['description'] ?? '',
        recommendation: rec,
        suggestedMedicines: medicines,
        homeRemedies: List<String>.from(json['homeRemedies'] ?? []),
        warningSignsToWatch: List<String>.from(json['warningSignsToWatch'] ?? []),
        referralLocation: json['referralCoordinates'] != null ? 
          "${json['referralCoordinates']['name']} (${json['referralCoordinates']['lat']}, ${json['referralCoordinates']['lng']})" : null,
      );
    } catch (e) {
      return _fallbackAssessment(symptoms, "Error parsing AI response.");
    }
  }

  // Fallback (same as before)
  HealthAssessment _fallbackAssessment(List<String> symptoms, String err) {
    return HealthAssessment(
      id: _uuid.v4(),
      date: DateTime.now(),
      reportedSymptoms: symptoms,
      possibleCondition: "Assessment Failed",
      riskLevel: RiskLevel.low,
      description: "We couldn't reach the AI agent. $err",
      recommendation: "Please try again later or consult a doctor.",
    );
  }

  List<Symptom> getCommonSymptoms() {
    return [
      Symptom(id: '1', name: 'Fever'),
      Symptom(id: '2', name: 'Cough'),
      Symptom(id: '3', name: 'Headache'),
      Symptom(id: '4', name: 'Skin Rash'),
      Symptom(id: '5', name: 'Stomach Pain'),
      Symptom(id: '6', name: 'Eye Redness'),
    ];
  }
}
