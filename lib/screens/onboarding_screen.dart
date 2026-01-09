import 'package:flutter/material.dart';
import '../widgets/custom_widgets.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.health_and_safety,
                  size: 64,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "MEDICONNECT",
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  color: Theme.of(context).primaryColor,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Your Personal AI Health Assistant.\nAccessible healthcare for everyone, everywhere.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, height: 1.5, color: Colors.grey),
              ),
              const Spacer(),
              CustomButton(
                text: "Get Started",
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
              const SizedBox(height: 16),
              const Text(
                "Supported by Microsoft Imagine Cup",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
