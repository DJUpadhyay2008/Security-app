import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../widgets/page_header.dart';
import '../widgets/empty_state.dart';
import '../services/api_service.dart';

class ResidentsPage extends ConsumerStatefulWidget {
  const ResidentsPage({super.key});
  @override
  ConsumerState<ResidentsPage> createState() => _ResidentsPageState();
}

class _ResidentsPageState extends ConsumerState<ResidentsPage> {
  @override
  Widget build(BuildContext context) {
    final societyId = ref.watch(societyIdProvider);
    final flatsAsync = ref.watch(flatsBySocietyProvider(societyId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(title: 'Residents', subtitle: 'Manage residents and flat assignments', icon: Icons.home_outlined),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          child: Row(children: [
            ElevatedButton.icon(
              onPressed: societyId.isEmpty ? null : () => _showSetPreference(context, societyId),
              icon: const Icon(Icons.tune, size: 16),
              label: const Text('Set Entry Preference', style: TextStyle(fontSize: 13)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0)),
            ),
          ]),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: flatsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyState(message: societyId.isEmpty ? 'Select a society first' : e.toString()),
              data: (flats) {
                if (flats.isEmpty) return const EmptyState(message: 'No flats/residents found');
                return Card(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: flats.length,
                    separatorBuilder: (_, __) => const Divider(color: Color(0xFF21262D), height: 1),
                    itemBuilder: (_, i) {
                      final f = flats[i];
                      return ListTile(
                        leading: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: const Color(0xFF1565C0).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.apartment, color: Color(0xFF1E88E5), size: 20),
                        ),
                        title: Text(f.flatNumber, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                        subtitle: Text(f.ownerName ?? 'No owner assigned', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                        trailing: TextButton(
                          onPressed: () => _showSetPreference(context, societyId, flatId: f.id),
                          child: const Text('Set Preference', style: TextStyle(color: Color(0xFF1E88E5), fontSize: 12)),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showSetPreference(BuildContext context, String societyId, {String? flatId}) {
    String _pref = 'AUTO_ALLOW';
    final flatCtrl = TextEditingController(text: flatId ?? '');
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setSt) => AlertDialog(
        backgroundColor: const Color(0xFF1C2333),
        title: const Text('Entry Preference', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: SizedBox(
          width: 320,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: flatCtrl,
              readOnly: flatId != null,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: _dec('Flat ID'),
            ),
            const SizedBox(height: 16),
            ...['AUTO_ALLOW', 'CALL_BEFORE_ENTRY', 'DENY_UNKNOWN_VISITORS'].map((p) => RadioListTile<String>(
              title: Text(p, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              value: p, groupValue: _pref,
              activeColor: const Color(0xFF1E88E5),
              dense: true,
              onChanged: (v) => setSt(() => _pref = v!),
            )),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0)),
            onPressed: () async {
              try {
                await ApiService.put('/api/resident/preference', {
                  'flatId': flatCtrl.text,
                  'societyId': societyId,
                  'preference': _pref,
                });
                if (ctx.mounted) Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Preference updated'), backgroundColor: Color(0xFF4CAF50)),
                );
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      )),
    );
  }

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint, hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
    filled: true, fillColor: const Color(0xFF0D1117),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF30363D))),
  );
}
