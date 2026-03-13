import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import 'guard_dashboard.dart';
import 'resident_dashboard.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.security, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 24),
              const Text(
                'Visitor Management',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 48),
              
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(userRoleProvider.notifier).state = UserRole.guard;
                  Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(builder: (_) => const GuardDashboard())
                  );
                },
                icon: const Icon(Icons.local_police, size: 32),
                label: const Text('GUARD LOGIN', style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 24),
              
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(userRoleProvider.notifier).state = UserRole.resident;
                  Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(builder: (_) => const ResidentDashboard())
                  );
                },
                icon: const Icon(Icons.home, size: 32),
                label: const Text('RESIDENT LOGIN', style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
