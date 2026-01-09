import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../core/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  String _selectedLanguage = 'English';
  bool _isCtaHovered = false;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AppTheme.secondaryColor.withAlpha(10),
              Colors.white,
              AppTheme.pinkAccent.withAlpha(8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                _buildBackButton(),

                const SizedBox(height: 32),

                // Animated Header
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: _floatController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatController.value * 5),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withAlpha(60),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.waving_hand_rounded, color: Colors.white, size: 28),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome!",
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Let's get to know you",
                          style: TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Form Card
                Container(
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(color: AppTheme.primaryColor.withAlpha(10), blurRadius: 30, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name Field
                      _buildLabel("Your Name", Icons.person_outline_rounded, AppTheme.primaryColor),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _nameController,
                        hint: "Enter your name (optional)",
                        icon: Icons.badge_outlined,
                      ),

                      const SizedBox(height: 28),

                      // Language Field
                      _buildLabel("Preferred Language", Icons.translate_rounded, AppTheme.warningColor),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedLanguage,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.language_rounded, color: AppTheme.warningColor),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          items: [
                            _buildLanguageItem('English', '🇬🇧'),
                            _buildLanguageItem('Hindi', '🇮🇳'),
                            _buildLanguageItem('Spanish', '🇪🇸'),
                            _buildLanguageItem('French', '🇫🇷'),
                          ],
                          onChanged: (val) => setState(() => _selectedLanguage = val!),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                // Features Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFeature(Icons.speed_rounded, "Fast", AppTheme.tealAccent),
                    _buildFeature(Icons.lock_outline_rounded, "Secure", AppTheme.primaryColor),
                    _buildFeature(Icons.psychology_rounded, "AI-Powered", AppTheme.pinkAccent),
                  ],
                ),

                const SizedBox(height: 36),

                // CTA Button
                MouseRegion(
                  onEnter: (_) => setState(() => _isCtaHovered = true),
                  onExit: (_) => setState(() => _isCtaHovered = false),
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      final provider = Provider.of<AppProvider>(context, listen: false);
                      provider.login(_nameController.text, _selectedLanguage);
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 64,
                      transform: Matrix4.identity()..scale(_isCtaHovered ? 1.03 : 1.0),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withAlpha(_isCtaHovered ? 130 : 80),
                            blurRadius: _isCtaHovered ? 30 : 20,
                            offset: Offset(0, _isCtaHovered ? 12 : 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.rocket_launch_rounded, color: Colors.white),
                          const SizedBox(width: 12),
                          const Text(
                            "Continue as Guest",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            transform: Matrix4.translationValues(_isCtaHovered ? 6 : 0, 0, 0),
                            child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Privacy Footer
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withAlpha(15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield_rounded, size: 16, color: AppTheme.successColor),
                        const SizedBox(width: 8),
                        Text(
                          "Your data stays private and secure",
                          style: TextStyle(fontSize: 12, color: AppTheme.successColor, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
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
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor.withAlpha(180)),
        filled: true,
        fillColor: AppTheme.backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildLanguageItem(String language, String flag) {
    return DropdownMenuItem(
      value: language,
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Text(language),
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
      ],
    );
  }
}
