import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/providers.dart';
import 'guard_dashboard.dart';
import 'resident_dashboard.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withAlpha(40),
              ),
            ),
          ).animate().fadeIn(duration: 1.seconds).scale(),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(10),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withAlpha(30)),
                      ),
                      child: const Icon(Icons.shield_rounded, size: 80, color: Color(0xFF6366F1)),
                    ),
                  ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3),
                  
                  const SizedBox(height: 32),
                  
                  Text(
                    'SECURITY PASS',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                  
                  Text(
                    'Smarter society management',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: Colors.white60,
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                  
                  const SizedBox(height: 64),
                  
                  _LoginButton(
                    title: 'GUARD PORTAL',
                    subtitle: 'Manage gate & visitors',
                    icon: Icons.security_rounded,
                    color: const Color(0xFF6366F1),
                    onTap: () {
                      ref.read(userRoleProvider.notifier).state = UserRole.guard;
                      Navigator.pushReplacement(
                        context, 
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const GuardDashboard(),
                          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                        )
                      );
                    },
                  ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.1),
                  
                  const SizedBox(height: 20),
                  
                  _LoginButton(
                    title: 'RESIDENT ACCESS',
                    subtitle: 'Logs & preferences',
                    icon: Icons.home_rounded,
                    color: const Color(0xFF10B981),
                    onTap: () {
                      ref.read(userRoleProvider.notifier).state = UserRole.resident;
                      Navigator.pushReplacement(
                        context, 
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const ResidentDashboard(),
                          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                        )
                      );
                    },
                  ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.1),
                  
                  const SizedBox(height: 48),
                  
                  const Text(
                    'Powered by Antigravity OS',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white24, fontSize: 12),
                  ).animate().fadeIn(delay: 1.seconds),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _LoginButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(50),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Material(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withAlpha(40), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
