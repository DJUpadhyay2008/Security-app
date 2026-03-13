import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../widgets/page_header.dart';
import '../services/api_service.dart';

class RosterPage extends ConsumerStatefulWidget {
  const RosterPage({super.key});
  @override
  ConsumerState<RosterPage> createState() => _RosterPageState();
}

class _RosterPageState extends ConsumerState<RosterPage> {
  final _guardCtrl = TextEditingController();
  final _shiftStartCtrl = TextEditingController(text: '08:00');
  final _shiftEndCtrl = TextEditingController(text: '20:00');
  final _dateCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final societyId = ref.watch(societyIdProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(title: 'Guard Roster', subtitle: 'Assign guard shifts', icon: Icons.calendar_month_outlined),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 380,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Assign New Shift', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                          const SizedBox(height: 20),
                          _field(_guardCtrl, 'Guard ID', Icons.person_outline),
                          const SizedBox(height: 12),
                          Row(children: [
                            Expanded(child: _field(_shiftStartCtrl, 'Shift Start (HH:mm)', Icons.schedule)),
                            const SizedBox(width: 8),
                            Expanded(child: _field(_shiftEndCtrl, 'Shift End (HH:mm)', Icons.schedule_outlined)),
                          ]),
                          const SizedBox(height: 12),
                          _field(_dateCtrl, 'Date (YYYY-MM-DD)', Icons.calendar_today_outlined),
                          const SizedBox(height: 20),
                          if (_error != null) Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1565C0),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: _loading || societyId.isEmpty ? null : () => _assignRoster(societyId),
                              child: _loading
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('Assign Roster', style: TextStyle(fontSize: 14)),
                            ),
                          ),
                          if (societyId.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text('Please select a society first', style: TextStyle(color: Colors.orange, fontSize: 11)),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _assignRoster(String societyId) async {
    setState(() { _loading = true; _error = null; });
    try {
      await ApiService.post('/api/admin/assign-roster', {
        'guardId': _guardCtrl.text,
        'societyId': societyId,
        'shiftStart': _shiftStartCtrl.text,
        'shiftEnd': _shiftEndCtrl.text,
        'date': _dateCtrl.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Roster assigned successfully'), backgroundColor: Color(0xFF4CAF50)),
        );
        _guardCtrl.clear();
        _dateCtrl.clear();
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon) => TextField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
          prefixIcon: Icon(icon, size: 16, color: Colors.white38),
          filled: true,
          fillColor: const Color(0xFF0D1117),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF30363D))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF30363D))),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        ),
      );
}
