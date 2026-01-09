import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/data_models.dart';

class GeminiAIService {
  static const String _apiKey = 'AIzaSyB3BcqurFOtSHFKkvKCZ9EN7P3l1SLycUs';
  // Using the most stable model endpoint
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  
  final Uuid _uuid = const Uuid();

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
            'temperature': 0.1, // Very low for strict JSON adherence
            'topK': 32,
            'topP': 1,
            'maxOutputTokens': 1500,
          },
        }),
      ).timeout(const Duration(seconds: 40));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseAgenticResponse(data, symptoms);
      } else {
        debugPrint('Gemini API Error: ${response.statusCode} - ${response.body}');
        return _fallbackAssessment(symptoms, "Service busy. Please try again in 5 seconds.");
      }
    } catch (e) {
      debugPrint('Exception in analyzeSymptoms: $e');
      return _fallbackAssessment(symptoms, "Connection error. Please check your network.");
    }
  }

  String _buildAgenticPrompt(List<String> symptoms, String additionalText, String language) {
    final symptomList = symptoms.isNotEmpty ? symptoms.join(', ') : 'None specified';
    
    return '''
You are MediConnect Health Agent, a state-of-the-art proactive AI healthcare assistant for rural communities.
Analyze the provided symptoms and visual data to create a medical action plan.

PATIENT DATA:
• Language: $language
• Symptoms: $symptomList
• Patient Description: $additionalText

TASK:
1. Act as a Health Agent: Provide a clear "Action Plan".
2. Computer Vision: Describe findings from any image provided.
3. Multi-language: Provide all text fields in $language.
4. Coordination: Identify the nearest likely medical facility based on the urgency.

RESPOND WITH ONLY JSON (No extra text, no ```):
{
  "condition": "Name of condition",
  "riskLevel": "high" | "medium" | "low",
  "description": "2-3 sentences about the condition. If an image was provided, mention visual findings.",
  "agenticPlan": "Proactive 2-3 sentence action plan for the patient.",
  "medicines": [
    {"name": "...", "dosage": "...", "frequency": "...", "notes": "..."}
  ],
  "homeRemedies": ["Remedy 1", "Remedy 2"],
  "warningSignsToWatch": ["Sign 1", "Sign 2"],
  "referral": {
    "name": "Name of Nearest Real Hospital or Clinic",
    "lat": 28.5672,
    "lng": 77.2100
  }
}

COORDINATION GUIDELINES:
- For High Risk: Referral should be a Major Hospital. 
- For Low/Medium: Referral can be a Community Health Center.
- Use realistic coordinates (e.g., Near New Delhi / NCR region as default demo location).
''';
  }

  HealthAssessment _parseAgenticResponse(Map<String, dynamic> apiResponse, List<String> symptoms) {
    try {
      String responseText = apiResponse['candidates'][0]['content']['parts'][0]['text'] as String;
      
      // Better JSON extraction
      final jsonStart = responseText.indexOf('{');
      final jsonEnd = responseText.lastIndexOf('}');
      if (jsonStart != -1 && jsonEnd != -1) {
        responseText = responseText.substring(jsonStart, jsonEnd + 1);
      }
      
      final json = jsonDecode(responseText);
      
      RiskLevel riskLevel;
      String risk = json['riskLevel']?.toString().toLowerCase() ?? 'low';
      if (risk.contains('high')) riskLevel = RiskLevel.high;
      else if (risk.contains('medium')) riskLevel = RiskLevel.medium;
      else riskLevel = RiskLevel.low;
      
      List<Medicine> medicines = (json['medicines'] as List? ?? []).map((m) => Medicine(
        name: m['name'] ?? '',
        dosage: m['dosage'] ?? '',
        frequency: m['frequency'] ?? '',
        notes: m['notes'],
      )).toList();

      final referral = json['referral'] ?? {};

      return HealthAssessment(
        id: _uuid.v4(),
        date: DateTime.now(),
        reportedSymptoms: symptoms,
        possibleCondition: json['condition'] ?? 'General Assessment',
        riskLevel: riskLevel,
        description: json['description'] ?? 'Analysis complete.',
        recommendation: json['agenticPlan'] ?? 'Please follow home care and rest.',
        suggestedMedicines: medicines,
        homeRemedies: List<String>.from(json['homeRemedies'] ?? []),
        warningSignsToWatch: List<String>.from(json['warningSignsToWatch'] ?? []),
        referralLocation: referral['name']?.toString() ?? "Nearest Help Center",
        latitude: double.tryParse(referral['lat'].toString()) ?? 28.5672,
        longitude: double.tryParse(referral['lng'].toString()) ?? 77.2100,
      );
    } catch (e) {
      debugPrint('Parsing error: $e');
      return _fallbackAssessment(symptoms, "AI thinking... please try again.");
    }
  }

  HealthAssessment _fallbackAssessment(List<String> symptoms, String error) {
    return HealthAssessment(
      id: _uuid.v4(),
      date: DateTime.now(),
      reportedSymptoms: symptoms,
      possibleCondition: "Analysis Delayed",
      riskLevel: RiskLevel.low,
      description: error,
      recommendation: "Describe your symptoms more clearly or try again in a moment.",
      latitude: 28.6139,
      longitude: 77.2090,
      referralLocation: "Primary Health Center",
    );
  }

  List<Symptom> getCommonSymptoms() {
    return [
      Symptom(id: '1', name: 'Fever'),
      Symptom(id: '2', name: 'Cough'),
      Symptom(id: '3', name: 'Headache'),
      Symptom(id: '4', name: 'Skin Rash'),
      Symptom(id: '5', name: 'Stomach Pain'),
      Symptom(id: '6', name: 'Muscle Pain'),
    ];
  }
}
