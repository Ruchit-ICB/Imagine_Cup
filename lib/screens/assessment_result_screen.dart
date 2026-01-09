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
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text("AI Health Analysis", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // Blockchain Status Banner
            if (txHash != null)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(20),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blue.withAlpha(50)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.security_rounded, color: Colors.blue, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Immutable Medical Record Created", 
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blue)),
                          Text("TX: ${txHash.substring(0, 30)}...", 
                            style: const TextStyle(fontSize: 9, color: Colors.blueGrey, overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Top Hero Card (Premium Style from 2nd/3rd pic)
            _buildHeroCard(assessment),
            const SizedBox(height: 20),

            // Analysis Sections
            _buildInfoSection(
              title: "What's Happening",
              content: assessment.description,
              icon: Icons.info_rounded,
              iconColor: Colors.blueAccent,
            ),
            const SizedBox(height: 16),
            
            _buildInfoSection(
              title: "What To Do",
              content: assessment.recommendation,
              icon: Icons.lightbulb_rounded,
              iconColor: Colors.pinkAccent,
            ),
            const SizedBox(height: 16),

            // Suggested Medicines
            if (assessment.suggestedMedicines.isNotEmpty)
              _buildMedicineSection(assessment.suggestedMedicines),
            
            const SizedBox(height: 24),

            // Map Section
            if (assessment.referralLocation != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                    child: Text("Nearest Referral: ${assessment.referralLocation}", 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
                  ),
                  GestureDetector(
                    onTap: _openMap,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        image: DecorationImage(
                          image: NetworkImage("https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=14&size=600x300&markers=color:red%7C$lat,$lng&key=AIzaSyBm0dpYuy1E7fhpEFWq8mpm2NNivs9cUbo"),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 40, offset: const Offset(0, 15)),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black.withAlpha(160), Colors.transparent],
                          ),
                        ),
                        padding: const EdgeInsets.all(24),
                        alignment: Alignment.bottomLeft,
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_rounded, color: Colors.white, size: 28),
                            const SizedBox(width: 12),
                            Expanded(child: Text("Route to ${assessment.referralLocation}", 
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/home')),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      side: BorderSide(color: AppTheme.primaryColor.withAlpha(100), width: 2),
                    ),
                    child: const Text("Save & Exit", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _openMap,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 8,
                      shadowColor: AppTheme.primaryColor.withAlpha(100),
                    ),
                    child: const Text("Navigate Now", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(HealthAssessment data) {
    Color baseColor = data.riskLevel == RiskLevel.high ? Colors.red : data.riskLevel == RiskLevel.medium ? Colors.orange : Colors.green;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [baseColor.withAlpha(40), baseColor.withAlpha(100)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: baseColor.withAlpha(50)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: baseColor, shape: BoxShape.circle),
            child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),
          Text(data.possibleCondition, 
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_user_rounded, color: Colors.white, size: 14),
                const SizedBox(width: 6),
                Text("${data.riskLevel.name.toUpperCase()} RISK", 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({required String title, required String content, required IconData icon, required Color iconColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 20, offset: const Offset(0, 5))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconColor.withAlpha(40), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildMedicineSection(List<Medicine> medicines) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 20, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.green.withAlpha(40), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.medical_services_rounded, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 12),
              const Text("Suggested Medicines", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 16),
          ...medicines.map((m) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.withAlpha(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_pharmacy_rounded, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Text("${m.name} (${m.dosage})", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(m.frequency, style: TextStyle(fontSize: 13, color: Colors.green.shade700, fontWeight: FontWeight.w600)),
                if (m.notes != null) ...[
                  const SizedBox(height: 4),
                  Text("Note: ${m.notes}", style: TextStyle(fontSize: 12, color: Colors.green.shade800, fontStyle: FontStyle.italic)),
                ]
              ],
            ),
          )),
        ],
      ),
    );
  }
}
