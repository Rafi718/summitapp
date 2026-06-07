import 'dart:async';
import 'package:flutter/material.dart';
import '../alpine_theme.dart';

class CountdownChip extends StatefulWidget {
  final DateTime endsAt;
  const CountdownChip({super.key, required this.endsAt});

  @override
  State<CountdownChip> createState() => _CountdownChipState();
}

class _CountdownChipState extends State<CountdownChip> {
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _update();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _update());
  }

  void _update() {
    final now = DateTime.now();
    setState(() {
      _remaining = widget.endsAt.isAfter(now) ? widget.endsAt.difference(now) : Duration.zero;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = _remaining.inHours.toString().padLeft(2, '0');
    final m = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_remaining.inSeconds % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time, size: 12, color: AppColors.textPrimary),
          const SizedBox(width: 4),
          Text(
            '$h:$m:$s',
            style: AppText.caption(size: 11, color: AppColors.textPrimary, weight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
