import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardShell extends ConsumerWidget {
  final Widget child;
  const DashboardShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();

    return Scaffold(
      body: Row(
        children: [
          _Sidebar(currentLocation: location),
          Expanded(
            child: Column(
              children: [
                _TopBar(),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final societiesAsync = ref.watch(allSocietiesProvider);
    final selectedId = ref.watch(societyIdProvider);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        border: Border(bottom: BorderSide(color: Color(0xFF30363D))),
      ),
      child: Row(
        children: [
          const Icon(Icons.security, color: Color(0xFF1565C0), size: 22),
          const SizedBox(width: 8),
          Text('Visitor Management',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white70, fontSize: 15)),
          const Spacer(),
          societiesAsync.when(
            data: (societies) => DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedId.isEmpty ? null : selectedId,
                hint: const Text('Select Society', style: TextStyle(color: Colors.white54, fontSize: 13)),
                dropdownColor: const Color(0xFF1C2333),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                icon: const Icon(Icons.expand_more, color: Colors.white54, size: 18),
                items: societies
                    .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                    .toList(),
                onChanged: ref.watch(userRoleProvider) == UserRole.societySecretary
                    ? null // Locked for secretaries
                    : (v) {
                        if (v != null) ref.read(societyIdProvider.notifier).state = v;
                      },
              ),
            ),
            loading: () => const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
            error: (_, __) => const Text('No societies', style: TextStyle(color: Colors.red, fontSize: 12)),
          ),
          const SizedBox(width: 16),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFF1565C0),
            child: Icon(Icons.admin_panel_settings, size: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends ConsumerWidget {
  final String currentLocation;
  const _Sidebar({required this.currentLocation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(userRoleProvider);
    final items = [
      if (role == UserRole.superAdmin)
        _NavItem(icon: Icons.business_outlined, label: 'Societies', route: '/societies'),
      _NavItem(icon: Icons.people_alt_outlined, label: 'Visitors', route: '/visitors'),
      _NavItem(icon: Icons.home_outlined, label: 'Residents', route: '/residents'),
      _NavItem(icon: Icons.apartment_outlined, label: 'Flats', route: '/flats'),
      _NavItem(icon: Icons.security_outlined, label: 'Guards', route: '/guards'),
      _NavItem(icon: Icons.access_time_outlined, label: 'Attendance', route: '/attendance'),
      _NavItem(icon: Icons.calendar_month_outlined, label: 'Roster', route: '/roster'),
      _NavItem(icon: Icons.bar_chart_outlined, label: 'Analytics', route: '/analytics'),
    ];

    return Container(
      width: 200,
      color: const Color(0xFF0D1117),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text('ADMIN', style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1565C0),
                  letterSpacing: 2,
                )),
              ],
            ),
          ),
          const Divider(color: Color(0xFF21262D), height: 1),
          const SizedBox(height: 8),
          ...items.map((item) => _SidebarTile(
                item: item,
                isSelected: currentLocation.startsWith(item.route),
              )),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  const _NavItem({required this.icon, required this.label, required this.route});
}

class _SidebarTile extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  const _SidebarTile({required this.item, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: isSelected ? const Color(0xFF1565C0).withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => context.go(item.route),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(item.icon,
                    size: 18,
                    color: isSelected ? const Color(0xFF1E88E5) : Colors.white38),
                const SizedBox(width: 10),
                Text(item.label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? Colors.white : Colors.white54,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
