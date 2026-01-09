import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/data_models.dart';

class GeminiAIService {
  static const String _apiKey = 'AIzaSyB3BcqurFOtSHFKkvKCZ9EN7P3l1SLycUs';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  
  final Uuid _uuid = const Uuid();

  Future<HealthAssessment> analyzeSymptoms(List<String> symptoms, String additionalText) async {
    final prompt = _buildMedicalPrompt(symptoms, additionalText);
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': prompt}]}],
          'generationConfig': {
            'temperature': 0.4,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 2048,
          },
          'safetySettings': [
            {'category': 'HARM_CATEGORY_HARASSMENT', 'threshold': 'BLOCK_ONLY_HIGH'},
            {'category': 'HARM_CATEGORY_HATE_SPEECH', 'threshold': 'BLOCK_ONLY_HIGH'},
            {'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT', 'threshold': 'BLOCK_ONLY_HIGH'},
            {'category': 'HARM_CATEGORY_DANGEROUS_CONTENT', 'threshold': 'BLOCK_ONLY_HIGH'}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseGeminiResponse(data, symptoms);
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      return _fallbackAssessment(symptoms, additionalText);
    }
  }

  String _buildMedicalPrompt(List<String> symptoms, String additionalText) {
    final symptomList = symptoms.isNotEmpty ? symptoms.join(', ') : 'None specified';
    final additionalInfo = additionalText.isNotEmpty ? additionalText : 'None provided';
    
    return '''
You are MediConnect AI, a friendly healthcare assistant for rural communities. Analyze these symptoms and provide helpful, actionable medical guidance.

PATIENT SYMPTOMS:
• Selected: $symptomList
• Description: $additionalInfo

Respond with this EXACT JSON format (no other text, no markdown):
{
  "condition": "Most likely condition name",
  "riskLevel": "low" or "medium" or "high",
  "description": "Clear 2-3 sentence explanation of what might be happening. Be reassuring but honest.",
  "recommendation": "Specific actionable advice in 2-3 sentences. What should they do right now?",
  "medicines": [
    {
      "name": "Medicine name (generic)",
      "dosage": "e.g., 500mg or 1 tablet",
      "frequency": "e.g., Twice daily after meals",
      "notes": "Important info like 'Take with food' or 'Avoid if pregnant'"
    }
  ],
  "homeRemedies": [
    "Simple home remedy 1",
    "Simple home remedy 2",
    "Simple home remedy 3"
  ],
  "warningSignsToWatch": [
    "Symptom that means they should see doctor immediately",
    "Another warning sign"
  ],
  "shouldSeekHelp": true or false,
  "urgency": "immediate" or "soon" or "when_convenient"
}

GUIDELINES:
✓ Suggest 1-3 common, safe, over-the-counter medicines with proper dosages
✓ Include practical home remedies (rest, hydration, warm compress, etc.)
✓ List warning signs that would require immediate medical attention
✓ Use simple words a villager with basic education can understand
✓ For serious symptoms (chest pain, difficulty breathing), ALWAYS recommend immediate help
✓ Be warm and caring in tone
✓ Mention when NOT to take certain medicines (allergies, pregnancy, etc.)
''';
  }

  HealthAssessment _parseGeminiResponse(Map<String, dynamic> apiResponse, List<String> symptoms) {
    try {
      final candidates = apiResponse['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) throw Exception('No candidates');
      
      final content = candidates[0]['content'];
      final parts = content['parts'] as List?;
      if (parts == null || parts.isEmpty) throw Exception('No parts');
      
      String responseText = parts[0]['text'] as String;
      responseText = responseText.replaceAll('```json', '').replaceAll('```', '').trim();
      
      final json = jsonDecode(responseText);
      
      // Parse risk level
      RiskLevel riskLevel;
      switch (json['riskLevel']?.toString().toLowerCase()) {
        case 'high': riskLevel = RiskLevel.high; break;
        case 'medium': riskLevel = RiskLevel.medium; break;
        default: riskLevel = RiskLevel.low;
      }
      
      // Parse medicines
      List<Medicine> medicines = [];
      if (json['medicines'] != null && json['medicines'] is List) {
        for (var med in json['medicines']) {
          medicines.add(Medicine(
            name: med['name'] ?? 'Unknown',
            dosage: med['dosage'] ?? 'As directed',
            frequency: med['frequency'] ?? 'As needed',
            notes: med['notes'],
          ));
        }
      }
      
      // Parse home remedies
      List<String> homeRemedies = [];
      if (json['homeRemedies'] != null && json['homeRemedies'] is List) {
        homeRemedies = List<String>.from(json['homeRemedies']);
      }
      
      // Parse warning signs
      List<String> warningSignsToWatch = [];
      if (json['warningSignsToWatch'] != null && json['warningSignsToWatch'] is List) {
        warningSignsToWatch = List<String>.from(json['warningSignsToWatch']);
      }
      
      // Determine referral
      String? referral;
      if (json['shouldSeekHelp'] == true || riskLevel == RiskLevel.high) {
        if (json['urgency'] == 'immediate') {
          referral = "🚨 Nearest Hospital/Emergency Room - Go immediately";
        } else if (json['urgency'] == 'soon') {
          referral = "🏥 Community Health Center - Visit within 24 hours";
        } else {
          referral = "👨‍⚕️ Local Health Worker - Consult when convenient";
        }
      }
      
      return HealthAssessment(
        id: _uuid.v4(),
        date: DateTime.now(),
        reportedSymptoms: symptoms,
        possibleCondition: json['condition'] ?? 'Health Assessment',
        riskLevel: riskLevel,
        description: json['description'] ?? 'Assessment completed.',
        recommendation: json['recommendation'] ?? 'Please consult a healthcare professional.',
        referralLocation: referral,
        suggestedMedicines: medicines,
        homeRemedies: homeRemedies,
        warningSignsToWatch: warningSignsToWatch,
        disclaimer: "⚠️ This is AI-generated advice. Always consult a doctor before taking any medicine, especially if you are pregnant, breastfeeding, or have allergies.",
      );
    } catch (e) {
      return _fallbackAssessment(symptoms, '');
    }
  }

  HealthAssessment _fallbackAssessment(List<String> symptoms, String additionalText) {
    bool hasSevere = symptoms.any((s) => 
      s.toLowerCase().contains('chest') || 
      s.toLowerCase().contains('breathing') ||
      s.toLowerCase().contains('severe')
    );
    
    bool hasFever = symptoms.any((s) => s.toLowerCase().contains('fever'));
    bool hasCough = symptoms.any((s) => s.toLowerCase().contains('cough'));
    bool hasHeadache = symptoms.any((s) => s.toLowerCase().contains('headache'));
    bool hasStomach = symptoms.any((s) => s.toLowerCase().contains('stomach') || s.toLowerCase().contains('nausea'));
    
    if (hasSevere) {
      return HealthAssessment(
        id: _uuid.v4(),
        date: DateTime.now(),
        reportedSymptoms: symptoms,
        possibleCondition: "Requires Immediate Medical Attention",
        riskLevel: RiskLevel.high,
        description: "Your symptoms are serious and require immediate medical evaluation. Please do not delay seeking help.",
        recommendation: "Go to the nearest hospital or emergency room right away. Call for help if needed.",
        referralLocation: "🚨 Nearest Hospital Emergency Department - Go NOW",
        suggestedMedicines: [],
        homeRemedies: ["Stay calm and rest", "Have someone accompany you"],
        warningSignsToWatch: ["Difficulty breathing gets worse", "Severe chest pain", "Loss of consciousness"],
        disclaimer: "⚠️ Seek immediate medical attention. Do not take any medicine without doctor's advice for these symptoms.",
      );
    } else if (hasFever) {
      return HealthAssessment(
        id: _uuid.v4(),
        date: DateTime.now(),
        reportedSymptoms: symptoms,
        possibleCondition: "Fever / Possible Viral Infection",
        riskLevel: RiskLevel.medium,
        description: "You appear to have a fever, which could be due to a viral or bacterial infection. Monitor your temperature regularly.",
        recommendation: "Rest well, drink plenty of fluids, and take fever-reducing medicine. See a doctor if fever persists beyond 3 days.",
        referralLocation: "🏥 Community Health Center - Visit if fever persists",
        suggestedMedicines: [
          Medicine(name: "Paracetamol (Acetaminophen)", dosage: "500mg", frequency: "Every 4-6 hours as needed", notes: "Do not exceed 4g per day. Take with water."),
        ],
        homeRemedies: ["Drink warm water with honey and lemon", "Apply cold compress on forehead", "Get plenty of rest", "Eat light, easy-to-digest food"],
        warningSignsToWatch: ["Temperature above 103°F (39.4°C)", "Fever lasting more than 3 days", "Rash or spots on body", "Severe headache or neck stiffness"],
      );
    } else if (hasCough) {
      return HealthAssessment(
        id: _uuid.v4(),
        date: DateTime.now(),
        reportedSymptoms: symptoms,
        possibleCondition: "Common Cold / Upper Respiratory Infection",
        riskLevel: RiskLevel.low,
        description: "You likely have a common cold or mild respiratory infection. This usually gets better on its own within a week.",
        recommendation: "Rest, stay hydrated, and avoid cold drinks. Use cough syrup if the cough is disturbing your sleep.",
        referralLocation: null,
        suggestedMedicines: [
          Medicine(name: "Dextromethorphan Cough Syrup", dosage: "10ml", frequency: "Every 6-8 hours", notes: "For dry cough. Take before bed for better sleep."),
          Medicine(name: "Throat Lozenges", dosage: "1 lozenge", frequency: "Every 2-3 hours as needed", notes: "Do not chew, let it dissolve slowly."),
        ],
        homeRemedies: ["Gargle with warm salt water", "Drink ginger tea with honey", "Steam inhalation for 10 minutes", "Stay in warm environment"],
        warningSignsToWatch: ["Cough with blood", "Difficulty breathing", "Cough lasting more than 2 weeks", "High fever with cough"],
      );
    } else if (hasHeadache) {
      return HealthAssessment(
        id: _uuid.v4(),
        date: DateTime.now(),
        reportedSymptoms: symptoms,
        possibleCondition: "Tension Headache",
        riskLevel: RiskLevel.low,
        description: "This appears to be a common tension headache, often caused by stress, lack of sleep, or dehydration.",
        recommendation: "Rest in a quiet, dark room. Take pain relief if needed and drink plenty of water.",
        referralLocation: null,
        suggestedMedicines: [
          Medicine(name: "Paracetamol", dosage: "500mg", frequency: "Every 4-6 hours as needed", notes: "Maximum 4 tablets per day."),
          Medicine(name: "Ibuprofen", dosage: "400mg", frequency: "After meals, every 6-8 hours", notes: "Take with food. Avoid if you have stomach problems."),
        ],
        homeRemedies: ["Apply cold or warm compress on forehead", "Massage temples gently", "Rest in a dark, quiet room", "Stay hydrated"],
        warningSignsToWatch: ["Sudden severe headache (worst of your life)", "Headache with fever and stiff neck", "Vision changes", "Confusion or difficulty speaking"],
      );
    } else if (hasStomach) {
      return HealthAssessment(
        id: _uuid.v4(),
        date: DateTime.now(),
        reportedSymptoms: symptoms,
        possibleCondition: "Indigestion / Gastric Issue",
        riskLevel: RiskLevel.low,
        description: "You may have indigestion or mild gastric upset. This is usually caused by eating habits or mild infection.",
        recommendation: "Eat light food, avoid spicy and oily items. Stay hydrated and rest your stomach.",
        referralLocation: null,
        suggestedMedicines: [
          Medicine(name: "Antacid (Gelusil/Digene)", dosage: "2 teaspoons", frequency: "After meals", notes: "Shake well before use."),
          Medicine(name: "ORS (Oral Rehydration Salts)", dosage: "1 packet in 1 liter water", frequency: "Sip throughout the day", notes: "Essential if you have diarrhea or vomiting."),
        ],
        homeRemedies: ["Drink ginger water", "Eat plain rice and curd", "Avoid spicy, oily food", "Small, frequent meals instead of large ones"],
        warningSignsToWatch: ["Blood in vomit or stool", "Severe abdominal pain", "Unable to keep fluids down", "Signs of dehydration"],
      );
    } else {
      return HealthAssessment(
        id: _uuid.v4(),
        date: DateTime.now(),
        reportedSymptoms: symptoms,
        possibleCondition: "Minor Health Concern",
        riskLevel: RiskLevel.low,
        description: "Your symptoms appear mild and can likely be managed at home with rest and self-care.",
        recommendation: "Get adequate rest, eat nutritious food, and stay hydrated. Monitor your symptoms.",
        referralLocation: null,
        suggestedMedicines: [],
        homeRemedies: ["Get 7-8 hours of sleep", "Drink at least 8 glasses of water", "Eat fruits and vegetables", "Light exercise or walking"],
        warningSignsToWatch: ["Symptoms getting worse", "New symptoms appearing", "Fever developing", "Symptoms lasting more than a week"],
      );
    }
  }

  List<Symptom> getCommonSymptoms() {
    return [
      Symptom(id: '1', name: 'Fever'),
      Symptom(id: '2', name: 'Cough'),
      Symptom(id: '3', name: 'Headache'),
      Symptom(id: '4', name: 'Breathing Difficulty'),
      Symptom(id: '5', name: 'Stomach Pain'),
      Symptom(id: '6', name: 'Nausea'),
      Symptom(id: '7', name: 'Fatigue'),
      Symptom(id: '8', name: 'Sore Throat'),
    ];
  }
}
