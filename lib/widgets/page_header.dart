import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const PageHeader({super.key, required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF1E88E5), size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
              Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: Colors.white38)),
            ],
          ),
        ],
      ),
    );
  }
}
