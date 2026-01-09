import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/custom_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Not Logged In")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(user.name, style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 32),
            InfoCard(title: "Age", value: "${user.age} Years", icon: Icons.cake, color: Colors.blue),
            InfoCard(title: "Gender", value: user.gender, icon: Icons.person_outline, color: Colors.purple),
            InfoCard(title: "Language", value: user.language, icon: Icons.language, color: Colors.orange),
            const SizedBox(height: 32),
            CustomButton(
              text: "Logout",
              isSecondary: true,
              onPressed: () {
                provider.logout();
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
