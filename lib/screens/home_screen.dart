import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/custom_widgets.dart';
import '../models/data_models.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("MediConnect"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hello, ${user?.name ?? 'Guest'}!", style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 8),
              const Text("How are you feeling today?", style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 24),
              
              // Main Action Card
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/symptom_input'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.medical_services_outlined, size: 48, color: Colors.white),
                      SizedBox(height: 16),
                      Text("Start New Consultation", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text("Get AI-powered health guidance in minutes", style: TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              const Text("Recent Consultations", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              if (provider.history.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text("No recent consultations.", style: TextStyle(color: Colors.grey)),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.history.length,
                  itemBuilder: (context, index) {
                    final item = provider.history[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getRiskColor(item.riskLevel).withOpacity(0.1),
                          child: Icon(Icons.history, color: _getRiskColor(item.riskLevel)),
                        ),
                        title: Text(item.possibleCondition, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(DateFormat('MMM d, yyyy').format(item.date)),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
                        onTap: () {
                          // Show details (could reuse result screen or show a dialog)
                          // For MVP, just show a dialog
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(item.possibleCondition),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.description),
                                  const SizedBox(height: 16),
                                  const Text("Recommendation:", style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(item.recommendation),
                                ],
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close")),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRiskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.high: return Colors.red;
      case RiskLevel.medium: return Colors.orange;
      case RiskLevel.low: return Colors.green;
    }
  }
}
