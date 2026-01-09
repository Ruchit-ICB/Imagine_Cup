import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/data_models.dart';
import '../core/theme.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SymptomInputScreen extends StatefulWidget {
  const SymptomInputScreen({super.key});

  @override
  State<SymptomInputScreen> createState() => _SymptomInputScreenState();
}

class _SymptomInputScreenState extends State<SymptomInputScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  List<Symptom> _symptoms = [];
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isSubmitHovered = false;
  late AnimationController _pulseController;
  late AnimationController _waveController;

  final List<Color> _symptomColors = [
    AppTheme.accentColor,
    AppTheme.primaryColor,
    AppTheme.warningColor,
    AppTheme.tealAccent,
    AppTheme.pinkAccent,
    AppTheme.secondaryColor,
    AppTheme.successColor,
    const Color(0xFF9C27B0),
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    final provider = Provider.of<AppProvider>(context, listen: false);
    _symptoms = provider.getSymptoms();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _toggleSymptom(int index) {
    setState(() {
      _symptoms[index].isSelected = !_symptoms[index].isSelected;
    });
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done') setState(() => _isListening = false);
        },
        onError: (val) => debugPrint('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            if (val.finalResult) {
              String currentText = _textController.text;
              String newText = val.recognizedWords;
              _textController.text = currentText.isNotEmpty ? "$currentText $newText" : newText;
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _submit() async {
    final selected = _symptoms.where((s) => s.isSelected).toList();
    final text = _textController.text.trim();

    if (selected.isEmpty && text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text("Please select or describe at least one symptom."),
            ],
          ),
          backgroundColor: AppTheme.accentColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
      return;
    }

    final provider = Provider.of<AppProvider>(context, listen: false);
    final result = await provider.submitAssessment(selected, text);
    if (result != null && mounted) {
      Navigator.pushReplacementNamed(context, '/result', arguments: result);
    }
  }

  IconData _getSymptomIcon(String name) {
    final icons = {
      'Fever': Icons.thermostat_rounded,
      'Headache': Icons.psychology_rounded,
      'Cough': Icons.air_rounded,
      'Fatigue': Icons.battery_2_bar_rounded,
      'Nausea': Icons.sick_rounded,
      'Stomach Pain': Icons.healing_rounded,
      'Sore Throat': Icons.mic_off_rounded,
      'Body Ache': Icons.accessibility_new_rounded,
    };
    return icons[name] ?? Icons.help_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AppProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: isLoading
            ? _buildLoadingState()
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        _buildBackButton(),
                        const Expanded(
                          child: Text(
                            "Describe Symptoms",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Symptom Selection
                    Container(
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
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.checklist_rounded, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Select Your Symptoms",
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 10,
                            runSpacing: 12,
                            children: List.generate(_symptoms.length, (index) {
                              return _SymptomPill(
                                symptom: _symptoms[index],
                                color: _symptomColors[index % _symptomColors.length],
                                icon: _getSymptomIcon(_symptoms[index].name),
                                onTap: () => _toggleSymptom(index),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Text Input Section
                    Container(
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
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.accentGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Tell Us More",
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Describe any other symptoms you're experiencing",
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _textController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: "E.g., I've been feeling dizzy since morning...",
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              filled: true,
                              fillColor: AppTheme.backgroundColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Voice Button
                          Center(
                            child: _buildVoiceButton(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Submit Button
                    MouseRegion(
                      onEnter: (_) => setState(() => _isSubmitHovered = true),
                      onExit: (_) => setState(() => _isSubmitHovered = false),
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _submit,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          height: 64,
                          transform: Matrix4.identity()..scale(_isSubmitHovered ? 1.02 : 1.0),
                          decoration: BoxDecoration(
                            gradient: AppTheme.successGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.tealAccent.withAlpha(_isSubmitHovered ? 130 : 80),
                                blurRadius: _isSubmitHovered ? 30 : 20,
                                offset: Offset(0, _isSubmitHovered ? 12 : 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 26),
                              const SizedBox(width: 12),
                              const Text(
                                "Get Health Guidance",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(width: 10),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                transform: Matrix4.translationValues(_isSubmitHovered ? 6 : 0, 0, 0),
                                child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
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

  Widget _buildVoiceButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _listen,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final pulseValue = _pulseController.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              decoration: BoxDecoration(
                gradient: _isListening
                    ? LinearGradient(colors: [AppTheme.accentColor.withAlpha(200), AppTheme.pinkAccent])
                    : LinearGradient(colors: [AppTheme.primaryColor.withAlpha(20), AppTheme.secondaryColor.withAlpha(15)]),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: _isListening ? AppTheme.accentColor : AppTheme.primaryColor,
                  width: 2,
                ),
                boxShadow: _isListening
                    ? [
                        BoxShadow(
                          color: AppTheme.accentColor.withAlpha((80 * pulseValue).toInt()),
                          blurRadius: 30 * pulseValue,
                          spreadRadius: 5 * pulseValue,
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isListening ? Icons.mic : Icons.mic_none_rounded,
                    color: _isListening ? Colors.white : AppTheme.primaryColor,
                    size: 26,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isListening ? "Listening..." : "Tap to Speak",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: _isListening ? Colors.white : AppTheme.primaryColor,
                    ),
                  ),
                  if (_isListening) ...[
                    const SizedBox(width: 12),
                    _buildSoundWave(),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSoundWave() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return Row(
          children: List.generate(4, (index) {
            final delay = index * 0.15;
            final value = (((_waveController.value + delay) % 1.0) * 2 - 1).abs();
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 4,
              height: 10 + value * 15,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppTheme.primaryColor.withAlpha(60), blurRadius: 30),
              ],
            ),
            child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
          ),
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
            child: const Text(
              "Analyzing your symptoms...",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _SymptomPill extends StatefulWidget {
  final Symptom symptom;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _SymptomPill({
    required this.symptom,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_SymptomPill> createState() => _SymptomPillState();
}

class _SymptomPillState extends State<_SymptomPill> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.symptom.isSelected;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(colors: [widget.color, widget.color.withAlpha(200)])
                : null,
            color: isSelected ? null : (_isHovered ? widget.color.withAlpha(15) : AppTheme.backgroundColor),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected ? Colors.transparent : (_isHovered ? widget.color : Colors.grey.shade300),
              width: isSelected ? 0 : 1.5,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: widget.color.withAlpha(60), blurRadius: 15, offset: const Offset(0, 4))]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 18, color: isSelected ? Colors.white : widget.color),
              const SizedBox(width: 8),
              Text(
                widget.symptom.name,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check_circle_rounded, size: 16, color: Colors.white),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
