import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/data_models.dart';
import '../core/theme.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool _isCtaHovered = false;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Hello, ${user?.name.isNotEmpty == true ? user!.name : 'there'}!",
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 800),
                              builder: (context, value, child) {
                                return Transform.rotate(
                                  angle: value * 0.3,
                                  child: const Text("👋", style: TextStyle(fontSize: 28)),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "How are you feeling today?",
                          style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    _buildProfileButton(context),
                  ],
                ),

                const SizedBox(height: 32),

                // Main CTA Card with Hover
                MouseRegion(
                  onEnter: (_) => setState(() => _isCtaHovered = true),
                  onExit: (_) => setState(() => _isCtaHovered = false),
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/symptom_input'),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: Matrix4.identity()..scale(_isCtaHovered ? 1.02 : 1.0),
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryColor,
                            Color(0xFF8B5CF6),
                            AppTheme.secondaryColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withAlpha(_isCtaHovered ? 120 : 70),
                            blurRadius: _isCtaHovered ? 40 : 25,
                            offset: Offset(0, _isCtaHovered ? 16 : 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(50),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.medical_services_rounded, size: 28, color: Colors.white),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(40),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: AppTheme.successColor,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(color: AppTheme.successColor.withAlpha(150), blurRadius: 6),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text("AI Ready", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            "Start New\nConsultation",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Get AI-powered health guidance in minutes",
                            style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 14),
                          ),
                          const SizedBox(height: 24),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(horizontal: _isCtaHovered ? 20 : 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(20),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                                  child: const Text(
                                    "Begin Now",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  transform: Matrix4.translationValues(_isCtaHovered ? 4 : 0, 0, 0),
                                  child: const Icon(Icons.arrow_forward_rounded, size: 18, color: AppTheme.primaryColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // Quick Actions
                Row(
                  children: [
                    Expanded(child: _buildQuickAction(Icons.history_rounded, "History", AppTheme.warningColor, () {})),
                    const SizedBox(width: 12),
                    Expanded(child: _buildQuickAction(Icons.favorite_rounded, "Health Tips", AppTheme.accentColor, () {})),
                    const SizedBox(width: 12),
                    Expanded(child: _buildQuickAction(Icons.location_on_rounded, "Nearby", AppTheme.tealAccent, () {})),
                  ],
                ),

                const SizedBox(height: 36),

                // Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Recent Consultations",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    if (provider.history.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withAlpha(15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "See All",
                          style: TextStyle(color: AppTheme.primaryColor.withAlpha(200), fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                if (provider.history.isEmpty)
                  _buildEmptyState()
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.history.length,
                    itemBuilder: (context, index) => _HistoryCard(item: provider.history[index]),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/profile'),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.pinkAccent.withAlpha(20), AppTheme.primaryColor.withAlpha(15)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primaryColor.withAlpha(30)),
          ),
          child: const Icon(Icons.person_rounded, color: AppTheme.primaryColor),
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: color.withAlpha(20), blurRadius: 15),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 10),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, AppTheme.primaryColor.withAlpha(8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryColor.withAlpha(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.secondaryColor.withAlpha(30), AppTheme.primaryColor.withAlpha(20)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.health_and_safety_rounded, size: 40, color: AppTheme.primaryColor.withAlpha(180)),
          ),
          const SizedBox(height: 20),
          const Text(
            "No consultations yet",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          Text(
            "Start your first consultation to get\nAI-powered health guidance.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatefulWidget {
  final HealthAssessment item;
  const _HistoryCard({required this.item});

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = _getRiskColor(widget.item.riskLevel);
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        transform: Matrix4.identity()..translate(_isHovered ? 4.0 : 0.0, 0.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _isHovered ? color.withAlpha(60) : Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: _isHovered ? color.withAlpha(30) : Colors.black.withAlpha(8),
              blurRadius: _isHovered ? 20 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color.withAlpha(30), color.withAlpha(15)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_getRiskIcon(widget.item.riskLevel), color: color, size: 24),
          ),
          title: Text(
            widget.item.possibleCondition,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              DateFormat('MMM d, yyyy • h:mm a').format(widget.item.date),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color.withAlpha(25), color.withAlpha(15)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.item.riskLevel.name.toUpperCase(),
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
            ),
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                title: Text(widget.item.possibleCondition),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.item.description),
                    const SizedBox(height: 16),
                    const Text("Recommendation:", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(widget.item.recommendation),
                  ],
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close")),
                ],
              ),
            );
          },
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

  IconData _getRiskIcon(RiskLevel level) {
    switch (level) {
      case RiskLevel.high: return Icons.warning_rounded;
      case RiskLevel.medium: return Icons.info_rounded;
      case RiskLevel.low: return Icons.check_circle_rounded;
    }
  }
}
