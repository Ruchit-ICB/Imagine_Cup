import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/app_provider.dart';
import 'models/data_models.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/symptom_input_screen.dart';
import 'screens/assessment_result_screen.dart';
import 'screens/referral_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const MediConnectApp());
}

class MediConnectApp extends StatelessWidget {
  const MediConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: MaterialApp(
        title: 'MediConnect',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/symptom_input': (context) => const SymptomInputScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/result') {
            final args = settings.arguments as HealthAssessment;
            return MaterialPageRoute(builder: (_) => AssessmentResultScreen(assessment: args));
          }
          if (settings.name == '/referral') {
             final args = settings.arguments as HealthAssessment;
            return MaterialPageRoute(builder: (_) => ReferralScreen(assessment: args));
          }
          return null;
        },
      ),
    );
  }
}
