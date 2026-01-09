import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../core/theme.dart';

class AssessmentResultScreen extends StatefulWidget {
  final HealthAssessment assessment;

  const AssessmentResultScreen({super.key, required this.assessment});

  @override
  State<AssessmentResultScreen> createState() => _AssessmentResultScreenState();
}

class _AssessmentResultScreenState extends State<AssessmentResultScreen> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  bool _isActionHovered = false;
  bool _isHomeHovered = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHighRisk = widget.assessment.riskLevel == RiskLevel.high;
    final isMediumRisk = widget.assessment.riskLevel == RiskLevel.medium;
    final color = _getRiskColor(widget.assessment.riskLevel);
    final gradient = _getRiskGradient(widget.assessment.riskLevel);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withAlpha(15), AppTheme.backgroundColor],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    _buildBackButton(),
                    const Expanded(
                      child: Text(
                        "AI Health Analysis",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),

                const SizedBox(height: 24),

                // Result Card
                ScaleTransition(
                  scale: CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
                  child: _buildResultCard(color, gradient, isHighRisk, isMediumRisk),
                ),

                const SizedBox(height: 20),

                // Analysis Card
                _buildInfoCard(
                  icon: Icons.psychology_rounded,
                  title: "What's Happening",
                  content: widget.assessment.description,
                  gradient: AppTheme.primaryGradient,
                ),

                const SizedBox(height: 14),

                // Recommendation Card
                _buildInfoCard(
                  icon: Icons.lightbulb_rounded,
                  title: "What To Do",
                  content: widget.assessment.recommendation,
                  gradient: AppTheme.accentGradient,
                ),

                // Medicines Section
                if (widget.assessment.suggestedMedicines.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _buildMedicinesCard(),
                ],

                // Home Remedies Section
                if (widget.assessment.homeRemedies.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _buildListCard(
                    icon: Icons.home_rounded,
                    title: "Home Remedies",
                    items: widget.assessment.homeRemedies,
                    color: AppTheme.tealAccent,
                    itemIcon: Icons.eco_rounded,
                  ),
                ],

                // Warning Signs Section
                if (widget.assessment.warningSignsToWatch.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _buildListCard(
                    icon: Icons.warning_rounded,
                    title: "When to Seek Help",
                    items: widget.assessment.warningSignsToWatch,
                    color: AppTheme.warningColor,
                    itemIcon: Icons.error_outline_rounded,
                  ),
                ],

                const SizedBox(height: 20),

                // Disclaimer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_rounded, color: Colors.amber.shade700, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.assessment.disclaimer,
                          style: TextStyle(fontSize: 12, color: Colors.amber.shade900, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                if (isHighRisk || widget.assessment.referralLocation != null)
                  _buildPrimaryActionButton(color, gradient)
                else
                  _buildHomeButton(),

                if (isHighRisk && widget.assessment.referralLocation != null) ...[
                  const SizedBox(height: 12),
                  _buildHomeButton(),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(Color color, LinearGradient gradient, bool isHighRisk, bool isMediumRisk) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, color.withAlpha(10)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withAlpha(40), width: 2),
        boxShadow: [
          BoxShadow(color: color.withAlpha(30), blurRadius: 30, offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: gradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withAlpha((80 * _pulseController.value).toInt() + 40),
                      blurRadius: 25 * _pulseController.value + 10,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Icon(
                  isHighRisk ? Icons.warning_rounded : isMediumRisk ? Icons.info_rounded : Icons.check_circle_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            widget.assessment.possibleCondition,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black87),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getRiskIcon(widget.assessment.riskLevel), size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  "${widget.assessment.riskLevel.name.toUpperCase()} RISK",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicinesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF81C784)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.medication_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                "Suggested Medicines",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.assessment.suggestedMedicines.map((medicine) => _buildMedicineItem(medicine)),
        ],
      ),
    );
  }

  Widget _buildMedicineItem(Medicine medicine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medication_liquid_rounded, color: Color(0xFF388E3C), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  medicine.name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF2E7D32)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildMedicineTag(Icons.local_hospital_rounded, medicine.dosage, const Color(0xFF1976D2)),
              const SizedBox(width: 8),
              Expanded(child: _buildMedicineTag(Icons.schedule_rounded, medicine.frequency, const Color(0xFF7B1FA2))),
            ],
          ),
          if (medicine.notes != null && medicine.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 14, color: Colors.orange.shade700),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      medicine.notes!,
                      style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMedicineTag(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(child: Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildListCard({
    required IconData icon,
    required String title,
    required List<String> items,
    required Color color,
    required IconData itemIcon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: color.withAlpha(20), shape: BoxShape.circle),
                  child: Icon(itemIcon, size: 12, color: color),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(item, style: TextStyle(fontSize: 14, height: 1.5, color: Colors.grey.shade700))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required LinearGradient gradient,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          Text(content, style: TextStyle(fontSize: 15, height: 1.6, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10)],
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildPrimaryActionButton(Color color, LinearGradient gradient) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isActionHovered = true),
      onExit: (_) => setState(() => _isActionHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/referral', arguments: widget.assessment),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 60,
          transform: Matrix4.identity()..scale(_isActionHovered ? 1.02 : 1.0),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(_isActionHovered ? 120 : 80),
                blurRadius: _isActionHovered ? 25 : 15,
                offset: Offset(0, _isActionHovered ? 10 : 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 10),
              const Text("Find Nearest Help", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.translationValues(_isActionHovered ? 6 : 0, 0, 0),
                child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHomeHovered = true),
      onExit: (_) => setState(() => _isHomeHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.popUntil(context, ModalRoute.withName('/home')),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: _isHomeHovered ? AppTheme.primaryColor.withAlpha(15) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primaryColor, width: 2),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home_rounded, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text("Back to Home", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRiskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.high: return const Color(0xFFE53935);
      case RiskLevel.medium: return const Color(0xFFFFA726);
      case RiskLevel.low: return const Color(0xFF43A047);
    }
  }

  LinearGradient _getRiskGradient(RiskLevel level) {
    switch (level) {
      case RiskLevel.high: return const LinearGradient(colors: [Color(0xFFE53935), Color(0xFFFF5252)]);
      case RiskLevel.medium: return const LinearGradient(colors: [Color(0xFFFFA726), Color(0xFFFFB74D)]);
      case RiskLevel.low: return const LinearGradient(colors: [Color(0xFF43A047), Color(0xFF66BB6A)]);
    }
  }

  IconData _getRiskIcon(RiskLevel level) {
    switch (level) {
      case RiskLevel.high: return Icons.warning_rounded;
      case RiskLevel.medium: return Icons.info_rounded;
      case RiskLevel.low: return Icons.check_circle_rounded;
    }
  }
}
