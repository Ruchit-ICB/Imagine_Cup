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
    final lat = assessment.latitude ?? 28.6139;
    final lng = assessment.longitude ?? 77.2090;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: const Text("Gold Standard Analysis", style: TextStyle(color: Color(0xFF2D2D2D), fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2D2D2D), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HERO SECTION
            _buildImagineCupHero(assessment),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  // SAFETY AGENT FLAGS (Imagine Cup Feature)
                  if (assessment.safetyFlags.isNotEmpty)
                    _buildSafetyCard(assessment.safetyFlags),

                  // LONGITUDINAL INSIGHT (Imagine Cup Feature)
                  if (assessment.longitudinalInsight != null)
                    _buildInsightCard("Health Journey Agent", assessment.longitudinalInsight!, Icons.history_edu_rounded, Colors.purple),

                  // AI VISION FOCUS (Imagine Cup Feature)
                  if (assessment.visualFocusPoints != null)
                    _buildInsightCard("AI Visual Focus", assessment.visualFocusPoints!, Icons.center_focus_strong_rounded, Colors.blueAccent),

                  // OCR breakdown
                  if (assessment.ocrAnalysis != null)
                    _buildOCRCard(assessment.ocrAnalysis!),

                  // WHAT'S HAPPENING
                  _buildSectionCard(
                    title: "Clinical Deep Analysis",
                    content: assessment.description,
                    icon: Icons.biotech_rounded,
                    iconColor: Colors.blueAccent,
                  ),
                  const SizedBox(height: 16),

                  // RECOVERY TIMELINE
                  _buildSectionCard(
                    title: "Recovery Timeline",
                    content: assessment.recoveryOutlook,
                    icon: Icons.auto_graph_rounded,
                    iconColor: Colors.deepPurpleAccent,
                  ),
                  const SizedBox(height: 16),

                  // MEDICINES
                  if (assessment.suggestedMedicines.isNotEmpty)
                    _buildMedicineCard(assessment.suggestedMedicines),
                  const SizedBox(height: 16),

                  // HOLISTIC COACHING
                  if (assessment.lifestyleTips.isNotEmpty)
                    _buildListSectionCard(
                      title: "AI Holistic Coaching",
                      items: assessment.lifestyleTips,
                      icon: Icons.spa_rounded,
                      iconColor: Colors.teal,
                    ),
                  const SizedBox(height: 16),

                  // WARNING SIGNS
                  if (assessment.warningSignsToWatch.isNotEmpty)
                    _buildListSectionCard(
                      title: "Critical Red Flags",
                      items: assessment.warningSignsToWatch,
                      icon: Icons.report_gmailerrorred_rounded,
                      iconColor: Colors.orange,
                    ),

                  const SizedBox(height: 24),
                  _buildReferralMap(assessment, lat, lng),
                  const SizedBox(height: 32),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/home')),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text("Archive Results", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _openMap(lat, lng),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                          ),
                          child: const Text("Navigate Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
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

  Widget _buildImagineCupHero(HealthAssessment data) {
    Color baseColor = data.riskLevel == RiskLevel.high ? Colors.red : (data.riskLevel == RiskLevel.medium ? Colors.orange : const Color(0xFF4CAF50));
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [baseColor.withAlpha(50), baseColor.withAlpha(120)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 100, width: 100,
                child: CircularProgressIndicator(
                  value: data.wellnessScore / 100,
                  strokeWidth: 10,
                  backgroundColor: Colors.white.withAlpha(50),
                  valueColor: AlwaysStoppedAnimation<Color>(baseColor),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("${data.wellnessScore.toInt()}%", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
                  const Text("WELLNESS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.possibleCondition, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF2D2D2D))),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(20)),
                  child: Text("${data.riskLevel.name.toUpperCase()} RISK", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyCard(List<String> flags) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFFFF1F0), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.red.withAlpha(30))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.gpp_maybe_rounded, color: Colors.red, size: 24),
              SizedBox(width: 12),
              Text("Safety Interaction Agent", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          ...flags.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("• ", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                Expanded(child: Text(f, style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w500))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String title, String content, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), border: Border.all(color: color.withAlpha(20))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 12),
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: TextStyle(color: Colors.grey.shade800, fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildOCRCard(String analysis) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF2D2D2D), borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.visibility_rounded, color: Colors.blueAccent, size: 20),
              SizedBox(width: 12),
              Text("AI Prescription Parser", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Text(analysis, style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required String content, required IconData icon, required Color iconColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 14),
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Text(content, style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildListSectionCard({required String title, required List<String> items, required IconData icon, required Color iconColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [Icon(icon, color: iconColor, size: 22), const SizedBox(width: 14), Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold))],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_outline_rounded, size: 18, color: iconColor),
                const SizedBox(width: 12),
                Expanded(child: Text(item, style: const TextStyle(fontSize: 14, color: Colors.black87))),
              ],
            ),
          )),
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
          const Row(
            children: [Icon(Icons.medical_services_rounded, color: Colors.green, size: 22), SizedBox(width: 14), Text("AI Prescription Analysis", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold))],
          ),
          const SizedBox(height: 16),
          ...medicines.map((m) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF1F8E9), borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${m.name} (${m.dosage})", style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                Text(m.frequency, style: const TextStyle(color: Color(0xFF388E3C), fontSize: 13)),
                if (m.notes != null) Text("Note: ${m.notes}", style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildReferralMap(HealthAssessment data, double lat, double lng) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Referral Hub", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(data.referralLocation ?? "", style: const TextStyle(fontSize: 12, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          ],
        ),
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
