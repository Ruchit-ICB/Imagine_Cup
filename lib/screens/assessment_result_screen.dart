import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../widgets/custom_widgets.dart';

class AssessmentResultScreen extends StatelessWidget {
  final HealthAssessment assessment;

  const AssessmentResultScreen({super.key, required this.assessment});

  @override
  Widget build(BuildContext context) {
    final isHighRisk = assessment.riskLevel == RiskLevel.high;
    final color = _getRiskColor(assessment.riskLevel);

    return Scaffold(
      appBar: AppBar(title: const Text("AI Health Analysis")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isHighRisk ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                size: 64,
                color: color,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              assessment.possibleCondition,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${assessment.riskLevel.name.toUpperCase()} RISK",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Analysis", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(assessment.description, style: const TextStyle(fontSize: 16)),
                    const Divider(height: 32),
                    const Text("Recommendation", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(assessment.recommendation, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            if (isHighRisk)
              CustomButton(
                text: "Find Nearest Help",
                onPressed: () {
                  Navigator.pushNamed(context, '/referral', arguments: assessment);
                },
              )
            else
              CustomButton(
                text: "Back to Home",
                onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/home')),
                isSecondary: true,
              ),
          ],
        ),
      ),
    );
  }

  Color _getRiskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.high: return const Color(0xFFD32F2F);
      case RiskLevel.medium: return const Color(0xFFFFA000);
      case RiskLevel.low: return const Color(0xFF4CAF50);
    }
  }
}
