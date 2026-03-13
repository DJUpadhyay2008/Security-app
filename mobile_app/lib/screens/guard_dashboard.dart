import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text('Guard Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2D2D44),
        actions: [
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
          ref.invalidate(pendingVisitorsProvider);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                   Expanded(
                    child: _BigActionButton(
                      title: 'CHECK IN\nGUARD',
                      icon: Icons.login,
                      color: Colors.green,
                      onTap: () => _doGuardInOut(context, societyId, true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _BigActionButton(
                      title: 'CHECK OUT\nGUARD',
                      icon: Icons.logout,
                      color: Colors.redAccent,
                      onTap: () => _doGuardInOut(context, societyId, false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'PENDING VISITORS',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: pendingVisitors.when(
                  data: (visitors) {
                    if (visitors.isEmpty) {
                      return const Center(child: Text('No pending visitors right now.', style: TextStyle(color: Colors.white54, fontSize: 18)));
                    }
                    return ListView.builder(
                      itemCount: visitors.length,
                      itemBuilder: (context, index) {
                        final v = visitors[index];
                        final time = DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(v.entryTimestamp));
                        return Card(
                          color: const Color(0xFF2D2D44),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${v.visitorName}  •  Flat ${v.flatId}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 8),
                                Text('Purpose: ${v.purpose}  •  Time: $time', style: const TextStyle(fontSize: 16, color: Colors.white70)),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          await ApiService.post('/api/visitor/exit', {'visitorId': v.id, 'guardId': 'MobileGuard'});
                                          ref.invalidate(pendingVisitorsProvider);
                                        },
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 16)),
                                        child: const Text('MARK EXITED', style: TextStyle(fontSize: 16, color: Colors.white)),
                                      )
                                    )
                                  ],
                                )
                              ],
                            ),
                          )
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('Error loading visitors: $e', style: const TextStyle(color: Colors.white))),
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
           // Basic manual entry mock
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Manual Entry Mode (Mock)')));
        },
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }

  Future<void> _doGuardInOut(BuildContext context, String societyId, bool isCheckIn) async {
    // In a real app we'd get the actual guard ID from auth. For simplicity, mock it.
    try {
      if (isCheckIn) {
        await ApiService.post('/api/guard/checkin', {'guardId': 'MblGrd01', 'societyId': societyId});
      } else {
        await ApiService.post('/api/guard/checkout', {'attendanceId': 'mockId'}); // Need to track ID properly, but leaving as mock
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isCheckIn ? 'Checked IN ✅' : 'Checked OUT ✅')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }
}

class _BigActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _BigActionButton({required this.title, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
