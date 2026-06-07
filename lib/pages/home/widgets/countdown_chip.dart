import 'dart:async';
import 'package:flutter/material.dart';
import '../alpine_theme.dart';

class CountdownChip extends StatefulWidget {
  final DateTime endsAt;
  final Color color;

  const CountdownChip({super.key, required this.endsAt, this.color = AlpineTheme.terracotta});

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AlpineTheme.charcoal,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, size: 12, color: widget.color),
          const SizedBox(width: 6),
          Text(
            '$h:$m:$s',
            style: AlpineTheme.mono(size: 12, color: widget.color, weight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
