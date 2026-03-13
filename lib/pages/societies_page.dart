import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import '../providers/providers.dart';
import '../widgets/page_header.dart';
import '../widgets/empty_state.dart';
import '../services/api_service.dart';

class SocietiesPage extends ConsumerStatefulWidget {
  const SocietiesPage({super.key});
  @override
  ConsumerState<SocietiesPage> createState() => _SocietiesPageState();
}

class _SocietiesPageState extends ConsumerState<SocietiesPage> {
  @override
  Widget build(BuildContext context) {
    final societiesAsync = ref.watch(allSocietiesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Societies',
          subtitle: 'Onboard and manage societies/apartments',
          icon: Icons.business_outlined,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _showAddSociety(context),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Society', style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0)),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => ref.invalidate(allSocietiesProvider),
                icon: const Icon(Icons.refresh, color: Colors.white54),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: societiesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyState(message: e.toString()),
              data: (societies) {
                if (societies.isEmpty) return const EmptyState(message: 'No societies found. Onboard one!');
                return Card(
                  child: DataTable2(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFF1C2333)),
                    headingTextStyle: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                    dataTextStyle: const TextStyle(color: Colors.white60, fontSize: 12),
                    columns: const [
                      DataColumn2(label: Text('ID'), size: ColumnSize.M),
                      DataColumn2(label: Text('NAME'), size: ColumnSize.L),
                      DataColumn2(label: Text('CITY'), size: ColumnSize.M),
                      DataColumn2(label: Text('STATUS'), size: ColumnSize.S),
                      DataColumn2(label: Text('QR CODE'), size: ColumnSize.S),
                    ],
                    rows: societies.map((s) => DataRow2(cells: [
                      DataCell(Text(s.id, style: const TextStyle(color: Colors.white54, fontSize: 11))),
                      DataCell(Text(s.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500))),
                      DataCell(Text(s.city ?? '-')),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: s.active ? const Color(0xFF4CAF50).withOpacity(0.15) : Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(s.active ? 'ACTIVE' : 'INACTIVE',
                            style: TextStyle(fontSize: 10, color: s.active ? const Color(0xFF4CAF50) : Colors.red)),
                      )),
                      DataCell(IconButton(
                        icon: const Icon(Icons.qr_code_2, color: Color(0xFF1E88E5), size: 20),
                        tooltip: 'Society QR Code',
                        onPressed: () => _generateQR(context, s.id),
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

  void _showAddSociety(BuildContext context) {
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final cityCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C2333),
        title: const Text('Onboard New Society', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: SizedBox(
          width: 320,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _field(nameCtrl, 'Society Name (Required)'),
            const SizedBox(height: 12),
            _field(addressCtrl, 'Full Address'),
            const SizedBox(height: 12),
            _field(cityCtrl, 'City'),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0)),
            onPressed: () async {
              if (nameCtrl.text.isEmpty) return;
              try {
                await ApiService.post('/api/admin/society', {
                  'name': nameCtrl.text,
                  'address': addressCtrl.text,
                  'city': cityCtrl.text,
                  'active': true,
                });
                if (context.mounted) Navigator.pop(context);
                ref.invalidate(allSocietiesProvider);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Onboard'),
          ),
        ],
      ),
    );
  }

  void _generateQR(BuildContext context, String societyId) async {
    try {
      final qrBase64 = await ApiService.get('/api/utils/generate-qr',
          params: {'societyId': societyId}, isJson: false);
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1C2333),
          title: const Text('Society QR Code', style: TextStyle(color: Colors.white)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Scan to submit visitor form', style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: Image.memory(
                Uri.parse('data:image/png;base64,$qrBase64').data!.contentAsBytes(),
                width: 200,
                height: 200,
              ),
            ),
          ]),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
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
