import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/data_models.dart';
import '../providers/app_provider.dart';
import '../core/theme.dart';

class AssessmentResultScreen extends StatelessWidget {
  final HealthAssessment assessment;

  const AssessmentResultScreen({super.key, required this.assessment});

  Future<void> _openMap() async {
    final lat = assessment.latitude ?? 28.6139;
    final lng = assessment.longitude ?? 77.2090;
    final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final txHash = provider.lastTransactionHash;
    final lat = assessment.latitude ?? 28.6139;
    final lng = assessment.longitude ?? 77.2090;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text("AI Agent Assessment"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Blockchain Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.shade200, width: 2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.security_rounded, color: Colors.blue, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Immutable Medical Record Created", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue)),
                        const SizedBox(height: 4),
                        Text("TX Hash: ${txHash ?? 'Processing...'}", 
                          style: const TextStyle(fontSize: 10, color: Colors.blueGrey, overflow: TextOverflow.ellipsis)),
                        const Text("Stored securely on Blockchain", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Main Result Card
            _buildResultCard(assessment),
            const SizedBox(height: 24),

            // Referral / Map Section
            if (assessment.referralLocation != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Nearest Referral: ${assessment.referralLocation}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _openMap,
                    child: Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        image: DecorationImage(
                          image: NetworkImage("https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=14&size=600x300&markers=color:red%7C$lat,$lng&key=AIzaSyBm0dpYuy1E7fhpEFWq8mpm2NNivs9cUbo"),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 20, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black.withAlpha(150), Colors.transparent],
                          ),
                        ),
                        padding: const EdgeInsets.all(20),
                        alignment: Alignment.bottomLeft,
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text("Route to ${assessment.referralLocation}", 
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/home')),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                      side: const BorderSide(color: AppTheme.primaryColor, width: 2),
                    ),
                    child: const Text("Save & Exit", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _openMap,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    child: const Text("Navigate Now", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(HealthAssessment data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 30)],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildRiskBadge(data.riskLevel),
              const Spacer(),
              const Icon(Icons.psychology_rounded, color: AppTheme.primaryColor),
            ],
          ),
          const SizedBox(height: 20),
          Text(data.possibleCondition, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Text(data.description, style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.5)),
          const Divider(height: 40),
          const Text("AI Agent Proactive Plan", style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primaryColor)),
          const SizedBox(height: 12),
          Text(data.recommendation, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildRiskBadge(RiskLevel level) {
    Color color = level == RiskLevel.high ? Colors.red : level == RiskLevel.medium ? Colors.orange : Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(level.name.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
