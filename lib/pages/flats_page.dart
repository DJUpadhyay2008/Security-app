import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import '../providers/providers.dart';
import '../widgets/page_header.dart';
import '../widgets/empty_state.dart';
import '../services/api_service.dart';

class FlatsPage extends ConsumerStatefulWidget {
  const FlatsPage({super.key});
  @override
  ConsumerState<FlatsPage> createState() => _FlatsPageState();
}

class _FlatsPageState extends ConsumerState<FlatsPage> {
  @override
  Widget build(BuildContext context) {
    final societyId = ref.watch(societyIdProvider);
    final flatsAsync = ref.watch(flatsBySocietyProvider(societyId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(title: 'Flats', subtitle: 'Manage flats and generate QR codes', icon: Icons.apartment_outlined),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: societyId.isEmpty ? null : () => _showAdd(context, societyId),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Flat', style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0)),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => ref.invalidate(flatsBySocietyProvider(societyId)),
                icon: const Icon(Icons.refresh, color: Colors.white54),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: flatsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyState(message: societyId.isEmpty ? 'Select a society first' : e.toString()),
              data: (flats) {
                if (flats.isEmpty) return const EmptyState(message: 'No flats found. Add one!');
                return Card(
                  child: DataTable2(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFF1C2333)),
                    headingTextStyle: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                    dataTextStyle: const TextStyle(color: Colors.white60, fontSize: 12),
                    columns: const [
                      DataColumn2(label: Text('FLAT NO.'), size: ColumnSize.M),
                      DataColumn2(label: Text('WING'), size: ColumnSize.S),
                      DataColumn2(label: Text('OWNER'), size: ColumnSize.L),
                      DataColumn2(label: Text('STATUS'), size: ColumnSize.S),
                    ],
                    rows: flats.map((f) => DataRow2(cells: [
                      DataCell(Text(f.flatNumber, style: const TextStyle(color: Colors.white))),
                      DataCell(Text(f.wing ?? '-')),
                      DataCell(Text(f.ownerName ?? '-')),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: f.active ? const Color(0xFF4CAF50).withOpacity(0.15) : Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(f.active ? 'ACTIVE' : 'INACTIVE',
                            style: TextStyle(fontSize: 10, color: f.active ? const Color(0xFF4CAF50) : Colors.red)),
                      )),
                    ])).toList(),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showAdd(BuildContext context, String societyId) {
    final flatCtrl = TextEditingController();
    final wingCtrl = TextEditingController();
    final ownerCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C2333),
        title: const Text('Add New Flat', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: SizedBox(
          width: 320,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _field(flatCtrl, 'Flat Number (e.g. A-101)'),
            const SizedBox(height: 12),
            _field(wingCtrl, 'Wing (e.g. A)'),
            const SizedBox(height: 12),
            _field(ownerCtrl, 'Owner Name'),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0)),
            onPressed: () async {
              try {
                await ApiService.post('/api/admin/flat', {
                  'flatNumber': flatCtrl.text,
                  'wing': wingCtrl.text,
                  'ownerName': ownerCtrl.text,
                  'societyId': societyId,
                });
                if (context.mounted) Navigator.pop(context);
                ref.invalidate(flatsBySocietyProvider(societyId));
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint) => TextField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
          filled: true,
          fillColor: const Color(0xFF0D1117),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF30363D))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF30363D))),
        ),
      );
}
