class Symptom {
  final String id;
  final String name;
  final String icon;
  bool isSelected;

  Symptom({
    required this.id,
    required this.name,
    this.icon = '',
    this.isSelected = false,
  });
}

enum RiskLevel { low, medium, high }

class Medicine {
  final String name;
  final String dosage;
  final String frequency;
  final String? notes;

  Medicine({
    required this.name,
    required this.dosage,
    required this.frequency,
    this.notes,
  });
}

class HealthAssessment {
  final String id;
  final DateTime date;
  final List<String> reportedSymptoms;
  final String possibleCondition;
  final RiskLevel riskLevel;
  final String description;
  final String recommendation;
  final String? referralLocation;
  final double? latitude;
  final double? longitude;
  final List<Medicine> suggestedMedicines;
  final List<String> homeRemedies;
  final List<String> warningSignsToWatch;
  final String disclaimer;
  
  // Imagine Cup AI Enhancements
  final double wellnessScore;
  final String recoveryOutlook;
  final String? ocrAnalysis;
  final List<String> lifestyleTips;

  // Gold Standard Features
  final List<String> safetyFlags; // Drug interactions or life-critical warnings
  final String? longitudinalInsight; // Analysis based on patient history
  final String? visualFocusPoints; // Description of where AI focused in image

  HealthAssessment({
    required this.id,
    required this.date,
    required this.reportedSymptoms,
    required this.possibleCondition,
    required this.riskLevel,
    required this.description,
    required this.recommendation,
    this.referralLocation,
    this.latitude,
    this.longitude,
    this.suggestedMedicines = const [],
    this.homeRemedies = const [],
    this.warningSignsToWatch = const [],
    this.wellnessScore = 80.0,
    this.recoveryOutlook = "Standard recovery expected.",
    this.ocrAnalysis,
    this.lifestyleTips = const [],
    this.safetyFlags = const [],
    this.longitudinalInsight,
    this.visualFocusPoints,
    this.disclaimer = "This is AI-generated advice. Always consult a healthcare professional for medical decisions.",
  });
}

class CommunityInsight {
  final String region;
  final String headline;
  final String advice;
  final IconData icon;

  CommunityInsight({
    required this.region,
    required this.headline,
    required this.advice,
    this.icon = Icons.info_outline,
  });
}

class UserProfile {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String language;

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.language,
  });
}
