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
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(allVisitorsProvider),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Text(
                    'VISIT HISTORY',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ).animate().fadeIn(),
            ),
            
            Expanded(
              child: allVisitors.when(
                data: (visitors) {
                  if (visitors.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.history_rounded, size: 64, color: Colors.white.withAlpha(20)),
                          const SizedBox(height: 16),
                          const Text('No visitors yet', style: TextStyle(color: Colors.white54, fontSize: 18)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
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
                        const Text('Can\'t load history', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 8),
                        const Text(
                          'Ensure your mobile can reach your computer\'s IP address.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, fontSize: 13),
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
    );
  }

  void _updatePreferences(BuildContext context, String societyId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
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
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 32),
            Text('Entry Preferences', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text('Define how the gate should handle your visitors', style: TextStyle(color: Colors.white54, fontSize: 14)),
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

  Future<void> _handlePref(BuildContext context, String pref, BuildContext bottomSheetContext) async {
    try {
      await ApiService.post('/api/resident/preference', {
        'residentId': 'R-User-01',
        'visitorType': 'ALL',
        'preferenceOverride': pref
      });
      if (context.mounted) {
        Navigator.pop(bottomSheetContext);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Preferences updated to $pref ✨'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF6366F1),
          ),
        );
      }
    } catch(e) {
      debugPrint('Failed to save pref: $e');
    }
  }
}

class _HistoryCard extends StatelessWidget {
  final dynamic v;
  final String time;

  const _HistoryCard({required this.v, required this.time});

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.access_time_rounded;
    if (v.status == 'PENDING') { statusColor = Colors.orange; statusIcon = Icons.pending_rounded; }
    if (v.status == 'EXITED') { statusColor = Colors.green; statusIcon = Icons.check_circle_rounded; }
    if (v.status == 'DENIED') { statusColor = Colors.red; statusIcon = Icons.cancel_rounded; }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: statusColor.withAlpha(20), shape: BoxShape.circle),
          child: Icon(statusIcon, color: statusColor, size: 20),
        ),
        title: Text(v.visitorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text('$time\nPurpose: ${v.purpose}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
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
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(40)),
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
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.white.withAlpha(20)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
