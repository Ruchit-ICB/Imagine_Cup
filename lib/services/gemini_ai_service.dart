import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/data_models.dart';

class GeminiAIService {
  static const String _apiKey = 'AIzaSyB3BcqurFOtSHFKkvKCZ9EN7P3l1SLycUs';
  // Using gemini-1.5-flash for better stability and performance
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
            'temperature': 0.2, // Lower temperature for more consistent JSON
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 2048,
            'response_mime_type': 'application/json', // Requesting JSON output specifically
          },
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseAgenticResponse(data, symptoms);
      } else {
        debugPrint('Gemini API Error: ${response.statusCode} - ${response.body}');
        return _fallbackAssessment(symptoms, "Service unavailable (${response.statusCode})");
      }
    } catch (e) {
      debugPrint('Exception in analyzeSymptoms: $e');
      return _fallbackAssessment(symptoms, "Connection error. Please check your internet.");
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

CRITICAL: Respond with ONLY a valid JSON object. No markdown, no "```json", no extra text.

JSON STRUCTURE:
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
- If an image is present, mention visual findings in the description.
''';
  }

  HealthAssessment _parseAgenticResponse(Map<String, dynamic> apiResponse, List<String> symptoms) {
    try {
      String responseText = apiResponse['candidates'][0]['content']['parts'][0]['text'] as String;
      
      // Robust JSON extraction
      responseText = _extractJson(responseText);
      final json = jsonDecode(responseText);
      
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

      final plan = json['agenticPlan'] ?? {};
      final rec = "Plan: ${plan['immediateActions']?.join(', ') ?? 'Rest and monitor'}. Coordination: ${plan['coordinationNeeded'] ?? 'Home care'}";

      return HealthAssessment(
        id: _uuid.v4(),
        date: DateTime.now(),
        reportedSymptoms: symptoms,
        possibleCondition: json['condition'] ?? 'Health Assessment',
        riskLevel: riskLevel,
        description: json['description'] ?? 'Assessment completed.',
        recommendation: rec,
        suggestedMedicines: medicines,
        homeRemedies: List<String>.from(json['homeRemedies'] ?? []),
        warningSignsToWatch: List<String>.from(json['warningSignsToWatch'] ?? []),
        referralLocation: json['referralCoordinates'] != null ? 
          "${json['referralCoordinates']['name']} (${json['referralCoordinates']['lat']}, ${json['referralCoordinates']['lng']})" : null,
      );
    } catch (e) {
      debugPrint('Error parsing Gemini response: $e');
      return _fallbackAssessment(symptoms, "AI returned an invalid response format.");
    }
  }

  String _extractJson(String text) {
    // Try to find the first '{' and last '}'
    int start = text.indexOf('{');
    int end = text.lastIndexOf('}');
    if (start != -1 && end != -1 && end > start) {
      return text.substring(start, end + 1);
    }
    return text.replaceAll('```json', '').replaceAll('```', '').trim();
  }

  HealthAssessment _fallbackAssessment(List<String> symptoms, String status) {
    return HealthAssessment(
      id: _uuid.v4(),
      date: DateTime.now(),
      reportedSymptoms: symptoms,
      possibleCondition: "Assessment Failed",
      riskLevel: RiskLevel.low,
      description: status,
      recommendation: "Please check your internet connection or try describing your symptoms differently. If symptoms are severe, seek medical help immediately.",
      disclaimer: "⚠️ This is a fallback assessment. Please consult a doctor.",
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
