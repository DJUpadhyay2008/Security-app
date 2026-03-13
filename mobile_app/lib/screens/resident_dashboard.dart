import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text('Resident Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2D2D44),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _updatePreferences(context, societyId),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(userRoleProvider.notifier).state = UserRole.none;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allVisitorsProvider);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'YOUR VISITOR LOGS',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: allVisitors.when(
                  data: (visitors) {
                    if (visitors.isEmpty) {
                      return const Center(child: Text('No visitor history.', style: TextStyle(color: Colors.white54, fontSize: 18)));
                    }
                    return ListView.builder(
                      itemCount: visitors.length,
                      itemBuilder: (context, index) {
                        final v = visitors[index];
                        final time = DateFormat('MMM dd, hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(v.entryTimestamp));
                        
                        Color statusColor = Colors.grey;
                        if (v.status == 'PENDING') statusColor = Colors.orange;
                        if (v.status == 'EXITED') statusColor = Colors.green;
                        if (v.status == 'DENIED') statusColor = Colors.red;

                        return Card(
                          color: const Color(0xFF2D2D44),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            title: Text(v.visitorName, style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                            subtitle: Text('Purpose: ${v.purpose}\nTime: $time', style: const TextStyle(color: Colors.white70)),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: statusColor.withAlpha(51), borderRadius: BorderRadius.circular(12)),
                              child: Text(v.status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                            ),
                          )
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('Error loading history: $e', style: const TextStyle(color: Colors.white))),
                ),
              )
            ],
          ),
        ),
      )
    );
  }

  void _updatePreferences(BuildContext context, String societyId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2D2D44),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Visitor Preferences', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 24),
            _PrefButton(
              title: 'AUTO ALLOW',
              color: Colors.green,
              onTap: () async {
                await _savePref('AUTO_ALLOW');
                if (!context.mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preferences set to Auto Allow')));
              },
            ),
            const SizedBox(height: 12),
            _PrefButton(
              title: 'CALL BEFORE ENTRY',
              color: Colors.orange,
              onTap: () async {
                await _savePref('CALL_BEFORE_ENTRY');
                if (!context.mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preferences set to Call Before Entry')));
              },
            ),
            const SizedBox(height: 12),
            _PrefButton(
              title: 'DENY UNKNOWN VISITORS',
              color: Colors.redAccent,
              onTap: () async {
                await _savePref('DENY_UNKNOWN_VISITORS');
                if (!context.mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preferences set to Deny Unknown')));
              },
            ),
          ],
        ),
      )
    );
  }

  Future<void> _savePref(String pref) async {
    // This connects to the endpoint established previously ResidentPreference
    try {
      await ApiService.post('/api/resident/preference', {
        'residentId': 'mockResident', // Ideally from auth
        'visitorType': 'ALL',
        'preferenceOverride': pref
      });
    } catch(e) {
      debugPrint('Failed to save pref: $e');
    }
  }
}

class _PrefButton extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _PrefButton({required this.title, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withAlpha(38),
        side: BorderSide(color: color, width: 2),
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
      ),
      onPressed: onTap,
      child: Text(title, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}
