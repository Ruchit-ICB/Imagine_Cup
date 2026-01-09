import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
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
  Uint8List? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    final provider = Provider.of<AppProvider>(context, listen: false);
    _symptoms = provider.getSymptoms();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => _selectedImage = bytes);
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) {
          if (val.finalResult) {
            _textController.text = "${_textController.text} ${val.recognizedWords}";
          }
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _submit() async {
    final selected = _symptoms.where((s) => s.isSelected).toList();
    if (selected.isEmpty && _textController.text.isEmpty && _selectedImage == null) return;

    final provider = Provider.of<AppProvider>(context, listen: false);
    final result = await provider.submitAssessment(
      selectedSymptoms: selected,
      otherSymptoms: _textController.text,
      imageBytes: _selectedImage,
    );

    if (result != null && mounted) {
      Navigator.pushReplacementNamed(context, '/result', arguments: result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AppProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("AI Agent Analysis", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                
                // CV Section
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primaryColor.withAlpha(50)),
                    ),
                    child: _selectedImage != null 
                      ? ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.memory(_selectedImage!, fit: BoxFit.cover))
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_rounded, size: 50, color: AppTheme.primaryColor),
                            SizedBox(height: 10),
                            Text("Add Photo for CV Analysis", style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                            Text("(Skin rashes, prescriptions, etc.)", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                  ),
                ),

                const SizedBox(height: 24),

                // Symptoms Wrap
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _symptoms.map((s) => FilterChip(
                    label: Text(s.name),
                    selected: s.isSelected,
                    onSelected: (val) => setState(() => s.isSelected = val),
                    selectedColor: AppTheme.primaryColor.withAlpha(50),
                  )).toList(),
                ),

                const SizedBox(height: 24),

                TextField(
                  controller: _textController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Describe your feeling...",
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: AppTheme.primaryColor),
                      onPressed: _listen,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text("Run Agentic AI Analysis", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
      ),
    );
  }
}
