import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/data_models.dart';
import '../providers/app_provider.dart';
import '../core/theme.dart';

class AssessmentResultScreen extends StatelessWidget {
  final HealthAssessment assessment;

  const AssessmentResultScreen({super.key, required this.assessment});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final txHash = provider.lastTransactionHash;
    final lat = assessment.latitude ?? 28.6139;
    final lng = assessment.longitude ?? 77.2090;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F4), // Soft green-grey background
      appBar: AppBar(
        title: const Text("AI Health Analysis", style: TextStyle(color: Color(0xFF4A4A4A), fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF4A4A4A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HERO SECTION (Exactly like 3rd pic)
            _buildCenteredHero(assessment),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  // Blockchain / Trust Banner
                  if (txHash != null) _buildBlockchainBanner(txHash),

                  // WHAT'S HAPPENING (Blue Section)
                  _buildSectionCard(
                    title: "What's Happening",
                    content: assessment.description,
                    icon: Icons.info_rounded,
                    iconColor: Colors.blueAccent,
                  ),
                  const SizedBox(height: 16),

                  // WHAT TO DO (Pink Section)
                  _buildSectionCard(
                    title: "What To Do",
                    content: assessment.recommendation,
                    icon: Icons.lightbulb_rounded,
                    iconColor: Colors.pinkAccent,
                  ),
                  const SizedBox(height: 16),

                  // MEDICINES (Green Section)
                  if (assessment.suggestedMedicines.isNotEmpty)
                    _buildMedicineCard(assessment.suggestedMedicines),

                  const SizedBox(height: 24),

                  // MAP SECTION
                  _buildReferralMap(assessment, lat, lng),
                  
                  const SizedBox(height: 32),

                  // NAVIGATION ACTION
                  ElevatedButton(
                    onPressed: () => _openMap(lat, lng),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    child: const Text("Navigate to Health Center", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/home')),
                    child: const Text("Back to Dashboard", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenteredHero(HealthAssessment data) {
    Color baseColor = data.riskLevel == RiskLevel.high ? Colors.red : (data.riskLevel == RiskLevel.medium ? Colors.orange : const Color(0xFF4CAF50));
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [baseColor.withAlpha(50), baseColor.withAlpha(120)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(Icons.check_circle, color: baseColor, size: 50),
          ),
          const SizedBox(height: 20),
          Text(data.possibleCondition, 
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF2D2D2D))),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(25)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text("${data.riskLevel.name.toUpperCase()} RISK", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required String content, required IconData icon, required Color iconColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: iconColor, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF555555))),
            ],
          ),
          const SizedBox(height: 16),
          Text(content, style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.6, fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  Widget _buildMedicineCard(List<Medicine> medicines) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF4CAF50), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.medical_services, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              const Text("Suggested Medicines", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF555555))),
            ],
          ),
          const SizedBox(height: 16),
          ...medicines.map((m) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                const Icon(Icons.medication, color: Color(0xFF4CAF50)),
                const SizedBox(width: 12),
                Expanded(child: Text("${m.name} (${m.dosage}) - ${m.frequency}", style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w600))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBlockchainBanner(String tx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.blue.withAlpha(15), border: Border.all(color: Colors.blue.withAlpha(50)), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Icon(Icons.lock_person_rounded, color: Colors.blue, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Text("Securely stored on Blockchain\nTX: ${tx.substring(0, 16)}...", style: const TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildReferralMap(HealthAssessment data, double lat, double lng) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Nearby Referral Hub", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF333333))),
        const SizedBox(height: 12),
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            image: DecorationImage(
              image: NetworkImage("https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=14&size=600x300&markers=color:red%7C$lat,$lng&key=AIzaSyBm0dpYuy1E7fhpEFWq8mpm2NNivs9cUbo"),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openMap(double lat, double lng) async {
    final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    if (await canLaunchUrl(url)) await launchUrl(url);
  }
}
