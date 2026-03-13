import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../widgets/page_header.dart';
import '../widgets/empty_state.dart';

class AttendancePage extends ConsumerWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final societyId = ref.watch(societyIdProvider);
    final attendanceAsync = ref.watch(guardAttendanceProvider(societyId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(title: 'Guard Attendance', subtitle: 'Check-in and checkout records', icon: Icons.access_time_outlined),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          child: Row(
            children: [
              const Spacer(),
              IconButton(
                onPressed: () => ref.refresh(guardAttendanceProvider(societyId)),
                icon: const Icon(Icons.refresh, color: Colors.white54),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: attendanceAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyState(message: societyId.isEmpty ? 'Select a society first' : e.toString()),
              data: (records) {
                if (records.isEmpty) return const EmptyState(message: 'No attendance records found');
                return Card(
                  child: DataTable2(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFF1C2333)),
                    headingTextStyle: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                    dataTextStyle: const TextStyle(color: Colors.white60, fontSize: 12),
                    columns: const [
                      DataColumn2(label: Text('GUARD ID'), size: ColumnSize.M),
                      DataColumn2(label: Text('CHECK IN'), size: ColumnSize.L),
                      DataColumn2(label: Text('CHECK OUT'), size: ColumnSize.L),
                      DataColumn2(label: Text('DURATION'), size: ColumnSize.M),
                    ],
                    rows: records.map((r) {
                      final checkIn = DateFormat('dd MMM, hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(r.checkInTime));
                      final checkOut = r.checkOutTime != null
                          ? DateFormat('dd MMM, hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(r.checkOutTime!))
                          : '-';
                      String duration = '-';
                      if (r.checkOutTime != null) {
                        final diff = r.checkOutTime! - r.checkInTime;
                        final hours = diff ~/ 3600000;
                        final mins = (diff % 3600000) ~/ 60000;
                        duration = '${hours}h ${mins}m';
                      }
                      return DataRow2(cells: [
                        DataCell(Text(r.guardId, style: const TextStyle(color: Colors.white))),
                        DataCell(Text(checkIn)),
                        DataCell(Text(checkOut)),
                        DataCell(Text(duration, style: TextStyle(color: r.checkOutTime != null ? const Color(0xFF4CAF50) : Colors.orange))),
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
