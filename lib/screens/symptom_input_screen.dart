import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/data_models.dart';
import '../widgets/custom_widgets.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SymptomInputScreen extends StatefulWidget {
  const SymptomInputScreen({super.key});

  @override
  State<SymptomInputScreen> createState() => _SymptomInputScreenState();
}

class _SymptomInputScreenState extends State<SymptomInputScreen> {
  final TextEditingController _textController = TextEditingController();
  List<Symptom> _symptoms = [];
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    final provider = Provider.of<AppProvider>(context, listen: false);
    _symptoms = provider.getSymptoms();
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
          if (val == 'done') {
            setState(() => _isListening = false);
          }
        },
        onError: (val) => debugPrint('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
             // For simplicity, we'll update the controller with the recognized words.
             // In a real app, you might want to handle cursor position and appending more carefully.
             if (val.finalResult) {
                String currentText = _textController.text;
                String newText = val.recognizedWords;
                if (currentText.isNotEmpty) {
                  _textController.text = "$currentText $newText";
                } else {
                  _textController.text = newText;
                }
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
        const SnackBar(content: Text("Please select or describe at least one symptom.")),
      );
      return;
    }

    final provider = Provider.of<AppProvider>(context, listen: false);
    final result = await provider.submitAssessment(selected, text);

    if (result != null && mounted) {
      Navigator.pushReplacementNamed(context, '/result', arguments: result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AppProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text("Enter Symptoms")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Select common symptoms:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    children: List.generate(_symptoms.length, (index) {
                      return SymptomChip(
                        label: _symptoms[index].name,
                        isSelected: _symptoms[index].isSelected,
                        onTap: () => _toggleSymptom(index),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  const Text("Describe other symptoms:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _textController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "E.g., I have been feeling dizzy since morning...",
                      alignLabelWithHint: true,
                      suffixIcon: IconButton(
                        icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                        color: _isListening ? Colors.red : Colors.grey,
                        onPressed: _listen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: _listen,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _isListening ? Colors.red : Theme.of(context).primaryColor,
                        side: BorderSide(color: _isListening ? Colors.red : Theme.of(context).primaryColor),
                      ),
                      icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                      label: Text(_isListening ? "Listening..." : "Tap to Speak"),
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: "Get Health Guidance",
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
    );
  }
}
