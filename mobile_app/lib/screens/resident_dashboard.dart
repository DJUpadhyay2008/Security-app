import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/providers.dart';
import '../core/api.dart';
import 'login.dart';

class ResidentDashboard extends ConsumerWidget {
  const ResidentDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allVisitors = ref.watch(allVisitorsProvider);
    final societyId = ref.watch(societyIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MY RESIDENCE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _updatePreferences(context, societyId),
          ),
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
      body: Stack(
        children: [
          // Background soft decor
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF10B981).withAlpha(15),
              ),
            ),
          ),
          
          RefreshIndicator(
            onRefresh: () async => ref.invalidate(allVisitorsProvider),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'VISIT HISTORY',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const Icon(Icons.history_rounded, size: 20, color: Color(0xFF94A3B8)),
                    ],
                  ).animate().fadeIn(),
                ),
                
                Expanded(
                  child: allVisitors.when(
                    data: (visitors) {
                      if (visitors.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.history_rounded, size: 64, color: Color(0xFFCBD5E1)),
                              SizedBox(height: 16),
                              Text('No visitors yet', style: TextStyle(color: Color(0xFF64748B), fontSize: 18, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                        itemCount: visitors.length,
                        itemBuilder: (context, index) {
                          final v = visitors[index];
                          final time = DateFormat('MMM dd • hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(v.entryTimestamp));
                          return _HistoryCard(v: v, time: time);
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.teal),
                            const SizedBox(height: 16),
                            const Text('Can\'t load history', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B))),
                            const SizedBox(height: 8),
                            const Text(
                              'Ensure your device can reach the server IP.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                            ),
                            const SizedBox(height: 24),
                            TextButton.icon(
                              onPressed: () => ref.invalidate(allVisitorsProvider),
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Try Again'),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updatePreferences(BuildContext context, String societyId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(32, 20, 32, 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
             Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Entry Preferences', 
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))
            ),
            const Text(
              'Define how the gate should handle your visitors', 
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500)
            ),
            const SizedBox(height: 32),
            _PrefOption(
               title: 'Auto Allow',
               desc: 'Guests can enter without my intervention',
               icon: Icons.bolt_rounded,
               color: const Color(0xFF10B981),
               onTap: () => _handlePref(context, 'AUTO_ALLOW', ctx),
            ),
            const SizedBox(height: 16),
            _PrefOption(
               title: 'Ask Me',
               desc: 'Guard must call or notify me first',
               icon: Icons.notifications_active_rounded,
               color: const Color(0xFFF59E0B),
               onTap: () => _handlePref(context, 'CALL_BEFORE_ENTRY', ctx),
            ),
            const SizedBox(height: 16),
            _PrefOption(
               title: 'Deny Unknowns',
               desc: 'Block anyone not on my whitelist',
               icon: Icons.block_flipped,
               color: const Color(0xFFF43F5E),
               onTap: () => _handlePref(context, 'DENY_UNKNOWN_VISITORS', ctx),
            ),
          ],
        ),
      )
    );
  }

  Future<void> _handlePref(BuildContext outerCtx, String pref, BuildContext modalCtx) async {
    Navigator.pop(modalCtx);
    try {
      await ApiService.put('/api/resident/preference', {'flatId': '101', 'preference': pref});
      if (outerCtx.mounted) {
        ScaffoldMessenger.of(outerCtx).showSnackBar(
          SnackBar(
            content: Text('Preference updated: $pref'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF6366F1),
          )
        );
      }
    } catch (e) {
      if (outerCtx.mounted) {
        ScaffoldMessenger.of(outerCtx).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }
}

class _HistoryCard extends StatelessWidget {
  final dynamic v;
  final String time;

  const _HistoryCard({required this.v, required this.time});

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.orange;
    IconData statusIcon = Icons.pending_rounded;
    if (v.status == 'EXITED') { statusColor = const Color(0xFF10B981); statusIcon = Icons.check_circle_rounded; }
    if (v.status == 'DENIED') { statusColor = const Color(0xFFF43F5E); statusIcon = Icons.cancel_rounded; }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: statusColor.withAlpha(25), shape: BoxShape.circle),
          child: Icon(statusIcon, color: statusColor, size: 20),
        ),
        title: Text(v.visitorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
        subtitle: Text('$time\nPurpose: ${v.purpose}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500)),
        isThreeLine: true,
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }
}

class _PrefOption extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PrefOption({required this.title, required this.desc, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: color.withAlpha(15), blurRadius: 15, offset: const Offset(0, 4))
        ],
        border: Border.all(color: color.withAlpha(20)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: color.withAlpha(25), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                      Text(desc, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
