import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/providers.dart';
import '../core/api.dart';
import 'login.dart';

class GuardDashboard extends ConsumerWidget {
  const GuardDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingVisitors = ref.watch(pendingVisitorsProvider);
    final societyId = ref.watch(societyIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GATE CONTROL'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              ref.read(userRoleProvider.notifier).state = UserRole.none;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(pendingVisitorsProvider),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _ControlCard(
                            label: 'GUARD\nIN',
                            icon: Icons.login_rounded,
                            color: const Color(0xFF10B981),
                            onTap: () => _doGuardInOut(context, societyId, true),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _ControlCard(
                            label: 'GUARD\nOUT',
                            icon: Icons.logout_rounded,
                            color: const Color(0xFFF43F5E),
                            onTap: () => _doGuardInOut(context, societyId, false),
                          ),
                        ),
                      ],
                    ).animate().fadeIn().slideY(begin: 0.1),
                    
                    const SizedBox(height: 40),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PENDING REQUESTS',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: const Color(0xFF6366F1),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withAlpha(30),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: pendingVisitors.when(
                            data: (v) => Text('${v.length} Active', style: const TextStyle(fontSize: 12, color: Color(0xFF6366F1), fontWeight: FontWeight.bold)),
                            loading: () => const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                            error: (_, __) => const Text('0', style: TextStyle(color: Colors.red)),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 200.ms),
                    
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            
            pendingVisitors.when(
              data: (visitors) {
                if (visitors.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 64, color: Colors.white.withAlpha(20)),
                          const SizedBox(height: 16),
                          const Text('Gate is clear', style: TextStyle(color: Colors.white54, fontSize: 18)),
                          const Text('No pending visitor requests', style: TextStyle(color: Colors.white24, fontSize: 14)),
                        ],
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final v = visitors[index];
                        final time = DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(v.entryTimestamp));
                        return _VisitorListItem(v: v, time: time, onRefresh: () => ref.invalidate(pendingVisitorsProvider));
                      },
                      childCount: visitors.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
              error: (e, _) => SliverFillRemaining(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.orange),
                        const SizedBox(height: 20),
                        const Text(
                          'Connection Error',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Cannot reach server. If using a phone, ensure you used your computer\'s IP address in core/api.dart instead of localhost.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => ref.invalidate(pendingVisitorsProvider),
                          child: const Text('Retry Connection'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6366F1),
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Manual Entry Mock'))),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('MANUAL ENTRY', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ).animate().scale(delay: 1.seconds),
    );
  }

  Future<void> _doGuardInOut(BuildContext context, String societyId, bool isCheckIn) async {
    try {
      if (isCheckIn) {
        await ApiService.post('/api/guard/checkin', {'guardId': 'G-882', 'societyId': societyId});
      } else {
        await ApiService.post('/api/guard/checkout', {'attendanceId': 'mock-1'});
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isCheckIn ? 'Guard Checked IN ✅' : 'Guard Checked OUT ✅'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: isCheckIn ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }
}

class _ControlCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ControlCard({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withAlpha(20), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VisitorListItem extends StatelessWidget {
  final dynamic v;
  final String time;
  final VoidCallback onRefresh;

  const _VisitorListItem({required this.v, required this.time, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF6366F1).withAlpha(30),
                  child: Text(v.visitorName[0], style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(v.visitorName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('Flat ${v.flatId} • ${v.purpose}', style: const TextStyle(color: Colors.white54, fontSize: 13)),
                    ],
                  ),
                ),
                Text(time, style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await ApiService.post('/api/visitor/exit', {'visitorId': v.id, 'guardId': 'M-Guard'});
                onRefresh();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981).withAlpha(30),
                foregroundColor: const Color(0xFF10B981),
                elevation: 0,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('APPROVE EXIT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.2)),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.05);
  }
}
