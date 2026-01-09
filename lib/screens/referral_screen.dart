import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../widgets/custom_widgets.dart';

class ReferralScreen extends StatelessWidget {
  final HealthAssessment assessment;

  const ReferralScreen({super.key, required this.assessment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Naviate Referrals")), // Minor joke for consistency but let's fix it later
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.red),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Based on your symptoms, we recommend visiting a healthcare professional immediately.",
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text("Nearest Healthcare Center", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.local_hospital, size: 40, color: Colors.blue),
                      title: Text(assessment.referralLocation ?? "Community Health Center", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: const Text("Calculated by Agentic AI • Open 24/7"),
                    ),
                    const Divider(),
                    const ListTile(
                      leading: Icon(Icons.location_on),
                      title: Text("Village Main Road, Near AI Recommended Hub"),
                    ),
                    const ListTile(
                      leading: Icon(Icons.phone),
                      title: Text("+91 987 654 3210"),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: "Navigate",
                      onPressed: () {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Opening Maps...")));
                      },
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            CustomButton(
              text: "Done",
              isSecondary: true,
              onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/home')),
            ),
          ],
        ),
      ),
    );
  }
}
