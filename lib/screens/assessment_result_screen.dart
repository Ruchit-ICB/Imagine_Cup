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
            stops: const [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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

                const SizedBox(height: 32),

                // Animated Result Card
                ScaleTransition(
                  scale: CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.white, color.withAlpha(10)],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: color.withAlpha(40), width: 2),
                      boxShadow: [
                        BoxShadow(color: color.withAlpha(30), blurRadius: 40, offset: const Offset(0, 15)),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Animated Icon
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: gradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withAlpha((80 * _pulseController.value).toInt() + 40),
                                    blurRadius: 30 * _pulseController.value + 10,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                isHighRisk
                                    ? Icons.warning_rounded
                                    : isMediumRisk
                                        ? Icons.info_rounded
                                        : Icons.check_circle_rounded,
                                size: 48,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // Condition Name
                        Text(
                          widget.assessment.possibleCondition,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.black87),
                        ),
                        const SizedBox(height: 16),

                        // Risk Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: gradient,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(color: color.withAlpha(60), blurRadius: 15, offset: const Offset(0, 5)),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getRiskIcon(widget.assessment.riskLevel), size: 18, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                "${widget.assessment.riskLevel.name.toUpperCase()} RISK",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Analysis Card
                _buildInfoCard(
                  icon: Icons.psychology_rounded,
                  title: "Analysis",
                  content: widget.assessment.description,
                  gradient: AppTheme.primaryGradient,
                  delay: 200,
                ),

                const SizedBox(height: 16),

                // Recommendation Card
                _buildInfoCard(
                  icon: Icons.lightbulb_rounded,
                  title: "Recommendation",
                  content: widget.assessment.recommendation,
                  gradient: AppTheme.accentGradient,
                  delay: 400,
                ),

                const SizedBox(height: 32),

                // Action Buttons
                if (isHighRisk)
                  MouseRegion(
                    onEnter: (_) => setState(() => _isActionHovered = true),
                    onExit: (_) => setState(() => _isActionHovered = false),
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/referral', arguments: widget.assessment),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        height: 64,
                        transform: Matrix4.identity()..scale(_isActionHovered ? 1.03 : 1.0),
                        decoration: BoxDecoration(
                          gradient: gradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: color.withAlpha(_isActionHovered ? 130 : 80),
                              blurRadius: _isActionHovered ? 30 : 20,
                              offset: Offset(0, _isActionHovered ? 12 : 8),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 26),
                            const SizedBox(width: 12),
                            const Text(
                              "Find Nearest Help",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(width: 10),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              transform: Matrix4.translationValues(_isActionHovered ? 6 : 0, 0, 0),
                              child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  MouseRegion(
                    onEnter: (_) => setState(() => _isHomeHovered = true),
                    onExit: (_) => setState(() => _isHomeHovered = false),
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => Navigator.popUntil(context, ModalRoute.withName('/home')),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        height: 60,
                        transform: Matrix4.identity()..scale(_isHomeHovered ? 1.02 : 1.0),
                        decoration: BoxDecoration(
                          color: _isHomeHovered ? AppTheme.primaryColor.withAlpha(15) : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppTheme.primaryColor, width: 2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.home_rounded, color: AppTheme.primaryColor),
                            const SizedBox(width: 10),
                            Text(
                              "Back to Home",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
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

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required LinearGradient gradient,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 20),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: gradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(icon, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    content,
                    style: TextStyle(fontSize: 15, height: 1.7, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
      case RiskLevel.high:
        return const LinearGradient(colors: [Color(0xFFE53935), Color(0xFFFF5252)]);
      case RiskLevel.medium:
        return const LinearGradient(colors: [Color(0xFFFFA726), Color(0xFFFFB74D)]);
      case RiskLevel.low:
        return const LinearGradient(colors: [Color(0xFF43A047), Color(0xFF66BB6A)]);
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
