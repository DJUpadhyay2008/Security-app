import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  Color get _color => switch (status) {
        'PENDING' => const Color(0xFFFF9800),
        'APPROVED' => const Color(0xFF4CAF50),
        'EXITED' => const Color(0xFF2196F3),
        'DENIED' => const Color(0xFFF44336),
        _ => Colors.grey,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Text(
        status,
        style: TextStyle(color: _color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}
