import 'package:flutter/material.dart';
import '../core/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withAlpha(15),
              AppTheme.secondaryColor.withAlpha(10),
              Colors.white,
              AppTheme.pinkAccent.withAlpha(8),
            ],
            stops: const [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Column(
              children: [
                const Spacer(flex: 2),
                
                // Animated Hero Illustration
                AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatAnimation.value),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer glow ring
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppTheme.primaryColor.withAlpha(30),
                                  AppTheme.secondaryColor.withAlpha(15),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          // Main circle
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withAlpha(60),
                                  blurRadius: 40,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(Icons.favorite_rounded, size: 50, color: Colors.white),
                                Positioned(
                                  bottom: 35,
                                  right: 30,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: AppTheme.accentColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.add, size: 18, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Floating dots
                          Positioned(
                            top: 20,
                            right: 30,
                            child: _buildFloatingDot(AppTheme.warningColor, 12),
                          ),
                          Positioned(
                            bottom: 30,
                            left: 20,
                            child: _buildFloatingDot(AppTheme.tealAccent, 10),
                          ),
                          Positioned(
                            top: 60,
                            left: 15,
                            child: _buildFloatingDot(AppTheme.pinkAccent, 8),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 48),
                
                // Gradient Brand Name
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.accentColor, AppTheme.secondaryColor],
                  ).createShader(bounds),
                  child: const Text(
                    "MEDICONNECT",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                Text(
                  "Your Personal AI Health Assistant",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Accessible healthcare guidance\nfor everyone, everywhere.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.7,
                    color: Colors.grey.shade500,
                  ),
                ),
                
                const Spacer(flex: 3),
                
                // Animated CTA Button with Hover
                MouseRegion(
                  onEnter: (_) => setState(() => _isHovered = true),
                  onExit: (_) => setState(() => _isHovered = false),
                  cursor: SystemMouseCursors.click,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isHovered ? 1.05 : 1.0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withAlpha(_isHovered ? 150 : 80),
                                blurRadius: _isHovered ? 30 : 20,
                                offset: Offset(0, _isHovered ? 12 : 8),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                Navigator.pushReplacementNamed(context, '/login');
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Get Started",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    transform: Matrix4.translationValues(_isHovered ? 5 : 0, 0, 0),
                                    child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 28),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified_rounded, size: 14, color: AppTheme.successColor),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Supported by Microsoft Imagine Cup",
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingDot(Color color, double size) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withAlpha(100), blurRadius: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}
