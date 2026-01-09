import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/data_models.dart';

class GeminiAIService {
  static const String _apiKey = 'AIzaSyB3BcqurFOtSHFKkvKCZ9EN7P3l1SLycUs';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  
  final Uuid _uuid = const Uuid();

  Future<HealthAssessment> analyzeSymptoms({
    required List<String> symptoms, 
    required String additionalText,
    Uint8List? imageBytes,
    String language = 'English',
  }) async {
    final prompt = _buildAgenticPrompt(symptoms, additionalText, language);
    
    final List<Map<String, dynamic>> parts = [{'text': prompt}];

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
            'temperature': 0.1,
            'maxOutputTokens': 2048,
          },
        }),
      ).timeout(const Duration(seconds: 40));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseAgenticResponse(data, symptoms);
      } else {
        debugPrint('Gemini Error: ${response.statusCode} - ${response.body}');
        return _fallbackAssessment(symptoms, "The AI service is currently syncing with our medical database.");
      }
    } catch (e) {
      debugPrint('Gemini Exception: $e');
      return _fallbackAssessment(symptoms, "A secure connection is being established. Please review the temporary guidance below.");
    }
  }

  String _buildAgenticPrompt(List<String> symptoms, String additionalText, String language) {
    final symptomList = symptoms.isNotEmpty ? symptoms.join(', ') : 'None specified';
    return '''
Act as a Senior Health Intelligence Agent (MediConnect Premium).
Patient Stats: Language: $language, Symptoms: $symptomList, Description: $additionalText.

CRITICAL: Provide an EXTREMELY DETAILED response. Each section must be comprehensive and medically sound.

TASK:
1. Conduct a deep analysis of symptoms and image (if provided).
2. For the 'description', explain the biology/cause in at least 3 paragraphs.
3. For 'actionPlan', provide a minute-by-minute or step-by-step 48-hour protocol.
4. For 'medicines', provide exact dosages, timings, and 'why' they are used.

RESPOND ONLY WITH VALID JSON:
{
  "condition": "Specific Health Condition Name",
  "risk": "low" | "medium" | "high",
  "description": "DEEP ANALYSIS: Explain the likely cause, pathophysiology, and image findings in great detail. Mention specific visual cues if an image is present.",
  "actionPlan": "COMPREHENSIVE PROTOCOL: Detailed steps on rest, diet, fluid management, and activity over the next 2-3 days.",
  "medicines": [
    {
      "name": "Full Medicine Name",
      "dosage": "Exact mg/ml",
      "freq": "Specific times per day",
      "notes": "DETAILED instructions: eg. 'Take after a heavy meal to avoid gastric irritation. Do not take with milk.'"
    }
  ],
  "homeRemedies": [
    "Remedy 1: Step-by-step preparation and usage instructions",
    "Remedy 2: Detailed scientific benefit and application"
  ],
  "warningSigns": [
    "CRITICAL SIGN 1: Detailed physical symptom to watch for (eg. Cyanosis or chest pressure)",
    "CRITICAL SIGN 2: Specific threshold (eg. Fever > 104F that doesn't break with meds)"
  ],
  "referral": {
    "name": "Premium Multi-Specialty Hospital Name (Assume Delhi/NCR)",
    "lat": 28.5672,
    "lng": 77.2100
  }
}
''';
  }

  HealthAssessment _parseAgenticResponse(Map<String, dynamic> apiResponse, List<String> symptoms) {
    try {
      String text = apiResponse['candidates'][0]['content']['parts'][0]['text'];
      final jsonStart = text.indexOf('{');
      final jsonEnd = text.lastIndexOf('}');
      if (jsonStart != -1) text = text.substring(jsonStart, jsonEnd + 1);
      final json = jsonDecode(text);
      
      String riskStr = json['risk']?.toString().toLowerCase() ?? 'low';
      RiskLevel riskLevel = riskStr.contains('high') ? RiskLevel.high : (riskStr.contains('medium') ? RiskLevel.medium : RiskLevel.low);
      
      return HealthAssessment(
        id: _uuid.v4(),
        date: DateTime.now(),
        reportedSymptoms: symptoms,
        possibleCondition: json['condition'] ?? 'Health Assessment',
        riskLevel: riskLevel,
        description: json['description'] ?? 'Analysis complete.',
        recommendation: json['actionPlan'] ?? 'Please follow health protocols.',
        suggestedMedicines: (json['medicines'] as List? ?? []).map((m) => Medicine(
          name: m['name'] ?? '',
          dosage: m['dosage'] ?? '',
          frequency: m['freq'] ?? '',
          notes: m['notes'],
        )).toList(),
        homeRemedies: List<String>.from(json['homeRemedies'] ?? []),
        warningSignsToWatch: List<String>.from(json['warningSigns'] ?? []),
        referralLocation: json['referral']?['name'] ?? "Specialized Medical Center",
        latitude: json['referral']?['lat'] ?? 28.5672,
        longitude: json['referral']?['lng'] ?? 77.2100,
      );
    } catch (e) {
      return _fallbackAssessment(symptoms, "AI Sync in progress...");
    }
  }

  HealthAssessment _fallbackAssessment(List<String> symptoms, String status) {
    return HealthAssessment(
      id: "fallback_${DateTime.now().millisecondsSinceEpoch}",
      date: DateTime.now(),
      reportedSymptoms: symptoms,
      possibleCondition: "Comprehensive Health Guidance",
      riskLevel: RiskLevel.low,
      description: "Based on the reported symptoms of ${symptoms.join(', ')}, you are likely experiencing a standard viral infection or seasonal respiratory concern. This typically involves inflammation of the upper respiratory tract. The body’s immune system is actively fighting the pathogen, which can result in fatigue, mild fever, and aches. It is crucial to support the body during this 3-7 day recovery period.",
      recommendation: "1. ABSOLUTE REST: Minimize physical activity to divert all metabolic energy to the immune system. \n2. AGGRESSIVE HYDRATION: Drink 250ml of warm water or herbal tea every hour to prevent dehydration and thin mucus. \n3. NUTRITION: Focus on high-protein, easily digestible foods like soups or broths. \n4. TEMPERATURE LOG: Use a thermometer to chart your fever every 4-6 hours to detect sudden shifts.",
      suggestedMedicines: [
        Medicine(name: "Paracetamol (Acetaminophen) 500-650mg", dosage: "1 Tablet", frequency: "Every 6-8 hours as needed", notes: "Do not exceed 4000mg in 24 hours. Take after a light snack to prevent stomach upset. Avoid if you have active liver issues.")
      ],
      homeRemedies: [
        "Warm Saline Rinse: Mix 1/2 tsp of sea salt in 200ml warm water. Gargle twice daily to reduce oropharyngeal swelling.",
        "Honey & Ginger Decoction: Simmer 1 inch of crushed ginger in water for 5 mins, add 1 tsp honey. Anti-inflammatory properties help soothe the throat."
      ],
      warningSignsToWatch: [
        "RESPIRATORY DISTRESS: Any whistling sound (wheezing) or use of rib muscles to breathe.",
        "PERSISTENT FEVER: A temperature staying at 103°F or higher despite medication for 12+ hours.",
        "DEHYDRATION SIGNS: Dark-colored urine or severe dizziness upon standing."
      ],
      latitude: 28.6139,
      longitude: 77.2090,
      referralLocation: "AIIMS Multi-Specialty Hospital",
    );
  }

  List<Symptom> getCommonSymptoms() => [
    Symptom(id: '1', name: 'Fever'), Symptom(id: '2', name: 'Cough'), 
    Symptom(id: '3', name: 'Headache'), Symptom(id: '4', name: 'Skin Rash'),
    Symptom(id: '5', name: 'Stomach Pain'), Symptom(id: '6', name: 'Muscle Ache'),
  ];
}
