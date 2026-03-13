import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  String? _selectedSocietyId;
  bool _isSecretary = false;

  @override
  Widget build(BuildContext context) {
    final societiesAsync = ref.watch(allSocietiesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF30363D)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.security, color: Color(0xFF1565C0), size: 48),
              const SizedBox(height: 16),
              Text(
                'Visitor Management',
                style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to access the dashboard',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 32),
              
              // Role Selection
              Row(
                children: [
                  Expanded(
                    child: _RoleButton(
                      title: 'Super Admin',
                      icon: Icons.admin_panel_settings,
                      isSelected: !_isSecretary,
                      onTap: () => setState(() { _isSecretary = false; _selectedSocietyId = null; }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _RoleButton(
                      title: 'Secretary',
                      icon: Icons.business,
                      isSelected: _isSecretary,
                      onTap: () => setState(() => _isSecretary = true),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),

              if (_isSecretary) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Select Your Society', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1117),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF30363D)),
                  ),
                  child: societiesAsync.when(
                    data: (societies) {
                      if (societies.isEmpty) return const Padding(padding: EdgeInsets.all(12), child: Text('No societies available', style: TextStyle(color: Colors.red)));
                      // Auto-select first if none selected
                      if (_selectedSocietyId == null && societies.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() => _selectedSocietyId = societies.first.id);
                        });
                      }
                      return DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1C2333),
                          value: _selectedSocietyId,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          icon: const Icon(Icons.expand_more, color: Colors.white54),
                          hint: const Text('Choose...', style: TextStyle(color: Colors.white38)),
                          items: societies.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                          onChanged: (v) => setState(() => _selectedSocietyId = v),
                        ),
                      );
                    },
                    loading: () => const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()),
                    error: (e, _) => Padding(padding: const EdgeInsets.all(12), child: Text('Error loading societies', style: TextStyle(color: Colors.red.shade300))),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    if (_isSecretary && _selectedSocietyId == null) {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a society')));
                       return;
                    }

                    if (_isSecretary) {
                      ref.read(userRoleProvider.notifier).state = UserRole.societySecretary;
                      ref.read(societyIdProvider.notifier).state = _selectedSocietyId!;
                      context.go('/visitors');
                    } else {
                      ref.read(userRoleProvider.notifier).state = UserRole.superAdmin;
                      context.go('/societies');
                    }
                  },
                  child: const Text('Login Mock', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleButton({required this.title, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1565C0).withOpacity(0.2) : const Color(0xFF0D1117),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E88E5) : const Color(0xFF30363D),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF1E88E5) : Colors.white54, size: 28),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(
              color: isSelected ? Colors.white : Colors.white54,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            )),
          ],
        ),
      ),
    );
  }
}
