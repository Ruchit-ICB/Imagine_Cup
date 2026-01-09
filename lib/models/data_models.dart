class Symptom {
  final String id;
  final String name;
  final String icon; // Path to asset or icon data
  bool isSelected;

  Symptom({
    required this.id,
    required this.name,
    this.icon = '',
    this.isSelected = false,
  });
}

enum RiskLevel { low, medium, high }

class HealthAssessment {
  final String id;
  final DateTime date;
  final List<String> reportedSymptoms;
  final String possibleCondition;
  final RiskLevel riskLevel;
  final String description;
  final String recommendation;
  final String? referralLocation;

  HealthAssessment({
    required this.id,
    required this.date,
    required this.reportedSymptoms,
    required this.possibleCondition,
    required this.riskLevel,
    required this.description,
    required this.recommendation,
    this.referralLocation,
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
