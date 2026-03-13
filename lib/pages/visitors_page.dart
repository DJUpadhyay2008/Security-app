import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';
import '../providers/providers.dart';
import '../widgets/page_header.dart';
import '../widgets/status_badge.dart';
import '../widgets/empty_state.dart';

class VisitorsPage extends ConsumerStatefulWidget {
  const VisitorsPage({super.key});

  @override
  ConsumerState<VisitorsPage> createState() => _VisitorsPageState();
}

class _VisitorsPageState extends ConsumerState<VisitorsPage> {
  String _statusFilter = 'ALL';
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final societyId = ref.watch(societyIdProvider);
    final visitorsAsync = ref.watch(visitorHistoryProvider(societyId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Visitor Entries',
          subtitle: 'All visitor logs for the selected society',
          icon: Icons.people_alt_outlined,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          child: Row(
            children: [
              SizedBox(
                width: 260,
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search visitor name or flat…',
                    hintStyle: const TextStyle(fontSize: 13, color: Colors.white38),
                    prefixIcon: const Icon(Icons.search, size: 18, color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF161B22),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF30363D)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF30363D)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  style: const TextStyle(fontSize: 13),
                  onChanged: (v) => setState(() => _search = v.toLowerCase()),
                ),
              ),
              const SizedBox(width: 12),
              _FilterChip('ALL', _statusFilter, (v) => setState(() => _statusFilter = v)),
              _FilterChip('PENDING', _statusFilter, (v) => setState(() => _statusFilter = v)),
              _FilterChip('EXITED', _statusFilter, (v) => setState(() => _statusFilter = v)),
              _FilterChip('DENIED', _statusFilter, (v) => setState(() => _statusFilter = v)),
              const Spacer(),
              IconButton(
                onPressed: () => ref.refresh(visitorHistoryProvider(societyId)),
                icon: const Icon(Icons.refresh, color: Colors.white54),
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: visitorsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyState(message: societyId.isEmpty ? 'Select a society to view visitors' : e.toString()),
              data: (visitors) {
                final filtered = visitors.where((v) {
                  final matchStatus = _statusFilter == 'ALL' || v.status == _statusFilter;
                  final matchSearch = _search.isEmpty ||
                      v.visitorName.toLowerCase().contains(_search) ||
                      v.flatId.toLowerCase().contains(_search);
                  return matchStatus && matchSearch;
                }).toList();

                if (filtered.isEmpty) return const EmptyState(message: 'No visitors found');

                return Card(
                  child: DataTable2(
                    columnSpacing: 12,
                    horizontalMargin: 16,
                    headingRowColor: WidgetStateProperty.all(const Color(0xFF1C2333)),
                    headingTextStyle: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                    dataTextStyle: const TextStyle(color: Colors.white60, fontSize: 12),
                    columns: const [
                      DataColumn2(label: Text('NAME'), size: ColumnSize.L),
                      DataColumn2(label: Text('PHONE'), size: ColumnSize.M),
                      DataColumn2(label: Text('PURPOSE'), size: ColumnSize.M),
                      DataColumn2(label: Text('FLAT'), size: ColumnSize.S),
                      DataColumn2(label: Text('ENTRY TIME'), size: ColumnSize.L),
                      DataColumn2(label: Text('STATUS'), size: ColumnSize.S),
                    ],
                    rows: filtered.map((v) {
                      final time = DateFormat('dd MMM, hh:mm a')
                          .format(DateTime.fromMillisecondsSinceEpoch(v.entryTimestamp));
                      return DataRow2(cells: [
                        DataCell(Text(v.visitorName, style: const TextStyle(color: Colors.white))),
                        DataCell(Text(v.phoneNumber)),
                        DataCell(Text(v.purpose)),
                        DataCell(Text(v.flatId)),
                        DataCell(Text(time)),
                        DataCell(StatusBadge(status: v.status)),
                      ]);
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label, current;
  final ValueChanged<String> onTap;
  const _FilterChip(this.label, this.current, this.onTap);

  @override
  Widget build(BuildContext context) {
    final selected = current == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontSize: 11, color: selected ? Colors.white : Colors.white54)),
        selected: selected,
        onSelected: (_) => onTap(label),
        selectedColor: const Color(0xFF1565C0),
        backgroundColor: const Color(0xFF161B22),
        side: BorderSide(color: selected ? const Color(0xFF1565C0) : const Color(0xFF30363D)),
        showCheckmark: false,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
