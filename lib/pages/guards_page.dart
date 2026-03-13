import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../widgets/page_header.dart';
import '../widgets/empty_state.dart';
import '../services/api_service.dart';

class GuardsPage extends ConsumerStatefulWidget {
  const GuardsPage({super.key});
  @override
  ConsumerState<GuardsPage> createState() => _GuardsPageState();
}

class _GuardsPageState extends ConsumerState<GuardsPage> {
  @override
  Widget build(BuildContext context) {
    final societyId = ref.watch(societyIdProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(title: 'Guards', subtitle: 'Manage security guards', icon: Icons.security_outlined),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          child: Row(children: [
            ElevatedButton.icon(
              onPressed: societyId.isEmpty ? null : () => _showCheckin(context, societyId),
              icon: const Icon(Icons.login, size: 16),
              label: const Text('Check In Guard', style: TextStyle(fontSize: 13)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: societyId.isEmpty ? null : () => _showCheckout(context),
              icon: const Icon(Icons.logout, size: 16),
              label: const Text('Check Out Guard', style: TextStyle(fontSize: 13)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF44336)),
            ),
          ]),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: societyId.isEmpty
                ? const EmptyState(message: 'Select a society to manage guards')
                : Card(
                    child: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.security, size: 48, color: Color(0xFF30363D)),
                        const SizedBox(height: 12),
                        const Text('Guard check-in and check-out', style: TextStyle(color: Colors.white38)),
                        const SizedBox(height: 4),
                        const Text('Use the buttons above to record attendance', style: TextStyle(color: Colors.white24, fontSize: 12)),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.findAncestorStateOfType<State>(),
                          child: const Text('→ View Attendance Logs', style: TextStyle(color: Color(0xFF1E88E5))),
                        ),
                      ]),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _showCheckin(BuildContext context, String societyId) {
    final guardCtrl = TextEditingController();
    showDialog(context: context, builder: (dialogContext) => AlertDialog(
      backgroundColor: const Color(0xFF1C2333),
      title: const Text('Guard Check In', style: TextStyle(color: Colors.white)),
      content: TextField(
        controller: guardCtrl,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Guard ID',
          hintStyle: const TextStyle(color: Colors.white38),
          filled: true, fillColor: const Color(0xFF0D1117),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF30363D))),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
          onPressed: () async {
            try {
              final id = await ApiService.post('/api/guard/checkin', {'guardId': guardCtrl.text, 'societyId': societyId});
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('✅ Checked in! Attendance ID: $id'),
                  backgroundColor: const Color(0xFF4CAF50),
                ));
              }
            } catch (e) {
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
            }
          },
          child: const Text('Check In'),
        ),
      ],
    ));
  }

  void _showCheckout(BuildContext context) {
    final idCtrl = TextEditingController();
    showDialog(context: context, builder: (dialogContext) => AlertDialog(
      backgroundColor: const Color(0xFF1C2333),
      title: const Text('Guard Check Out', style: TextStyle(color: Colors.white)),
      content: TextField(
        controller: idCtrl,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Attendance ID (from check-in)',
          hintStyle: const TextStyle(color: Colors.white38),
          filled: true, fillColor: const Color(0xFF0D1117),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF30363D))),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF44336)),
          onPressed: () async {
            try {
              await ApiService.post('/api/guard/checkout', {'attendanceId': idCtrl.text});
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('✅ Checked out successfully'),
                  backgroundColor: Color(0xFF4CAF50),
                ));
              }
            } catch (e) {
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
            }
          },
          child: const Text('Check Out'),
        ),
      ],
    ));
  }
}
