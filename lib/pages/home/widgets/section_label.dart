import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SectionLabel extends StatelessWidget {
  final String number;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionLabel({
    super.key,
    required this.number,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(number, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFC8552A), letterSpacing: 2, fontFamily: 'monospace')),
              const SizedBox(width: 6),
              Text('—', style: const TextStyle(fontSize: 11, color: Color(0xFF8B8680), letterSpacing: 2)),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF8B8680), letterSpacing: 2)),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: GoogleFonts.fraunces(
                fontSize: 26,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A1A),
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SectionDivider extends StatelessWidget {
  const SectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      height: 1,
      color: const Color(0xFFDCD5C5),
    );
  }
}
