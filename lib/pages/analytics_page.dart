import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../widgets/page_header.dart';
import '../widgets/empty_state.dart';
import '../models/models.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final societyId = ref.watch(societyIdProvider);
    final visitorsAsync = ref.watch(visitorHistoryProvider(societyId));

    if (societyId.isEmpty) {
      return Column(
        children: [
          PageHeader(title: 'Analytics', subtitle: 'Visitor and guard metrics', icon: Icons.bar_chart_outlined),
          const Expanded(child: EmptyState(message: 'Select a society to view analytics')),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(title: 'Analytics', subtitle: 'Visitor and guard metrics', icon: Icons.bar_chart_outlined),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: visitorsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyState(message: e.toString()),
              data: (visitors) {
                final statCards = _buildStatCards(visitors);
                final dailyCounts = _groupByDay(visitors);
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(children: statCards),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _VisitorChart(dailyCounts: dailyCounts)),
                          const SizedBox(width: 16),
                          Expanded(child: _StatusPieChart(visitors: visitors)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildStatCards(List<VisitorEntry> visitors) {
    final total = visitors.length;
    final pending = visitors.where((v) => v.status == 'PENDING').length;
    final exited = visitors.where((v) => v.status == 'EXITED').length;
    final denied = visitors.where((v) => v.status == 'DENIED').length;

    return [
      _StatCard(label: 'Total Visitors', value: '$total', color: const Color(0xFF1E88E5), icon: Icons.people),
      const SizedBox(width: 16),
      _StatCard(label: 'Pending', value: '$pending', color: const Color(0xFFFF9800), icon: Icons.hourglass_empty),
      const SizedBox(width: 16),
      _StatCard(label: 'Exited', value: '$exited', color: const Color(0xFF4CAF50), icon: Icons.exit_to_app),
      const SizedBox(width: 16),
      _StatCard(label: 'Denied', value: '$denied', color: const Color(0xFFF44336), icon: Icons.block),
    ];
  }

  Map<String, int> _groupByDay(List<VisitorEntry> visitors) {
    final map = <String, int>{};
    for (final v in visitors) {
      final day = DateFormat('dd MMM').format(DateTime.fromMillisecondsSinceEpoch(v.entryTimestamp));
      map[day] = (map[day] ?? 0) + 1;
    }
    return map;
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _StatCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(value, style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.w800)),
                Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12), overflow: TextOverflow.ellipsis),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _VisitorChart extends StatelessWidget {
  final Map<String, int> dailyCounts;
  const _VisitorChart({required this.dailyCounts});

  @override
  Widget build(BuildContext context) {
    final entries = dailyCounts.entries.toList();
    if (entries.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Visitors per Day', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(BarChartData(
                backgroundColor: Colors.transparent,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: true, drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFF21262D), strokeWidth: 1)),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) {
                      final idx = v.toInt();
                      if (idx >= 0 && idx < entries.length) {
                        return Text(entries[idx].key, style: const TextStyle(color: Colors.white38, fontSize: 9));
                      }
                      return const SizedBox.shrink();
                    },
                  )),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
                      getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(color: Colors.white38, fontSize: 9)))),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                barGroups: entries.asMap().entries.map((e) => BarChartGroupData(
                  x: e.key,
                  barRods: [BarChartRodData(toY: e.value.value.toDouble(),
                      color: const Color(0xFF1E88E5), borderRadius: BorderRadius.circular(4), width: 20)],
                )).toList(),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPieChart extends StatelessWidget {
  final List<VisitorEntry> visitors;
  const _StatusPieChart({required this.visitors});

  @override
  Widget build(BuildContext context) {
    final statuses = {'PENDING': const Color(0xFFFF9800), 'EXITED': const Color(0xFF4CAF50), 'DENIED': const Color(0xFFF44336)};
    final sections = statuses.entries.map((e) {
      final count = visitors.where((v) => v.status == e.key).length.toDouble();
      return PieChartSectionData(value: count, color: e.value, title: count > 0 ? '${count.toInt()}' : '',
          radius: 60, titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700));
    }).where((s) => s.value > 0).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Status Distribution', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: sections.isEmpty
                  ? const Center(child: Text('No data', style: TextStyle(color: Colors.white38)))
                  : PieChart(PieChartData(sections: sections, centerSpaceRadius: 40,
                      sectionsSpace: 3, startDegreeOffset: -90)),
            ),
            const SizedBox(height: 12),
            Wrap(spacing: 12, children: statuses.entries.map((e) => Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: e.value, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text(e.key, style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ])).toList()),
          ],
        ),
      ),
    );
  }
}
