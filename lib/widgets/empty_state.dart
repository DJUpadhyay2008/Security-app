import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String message;
  const EmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Colors.white12),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Colors.white38, fontSize: 13)),
        ],
      ),
    );
  }
}
