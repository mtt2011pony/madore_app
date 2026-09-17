import 'package:flutter/material.dart';

class TodayHeader extends StatelessWidget {
  final String date;
  final int streak;
  final double completionRate;

  const TodayHeader({
    super.key,
    required this.date,
    required this.streak,
    required this.completionRate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '🔥 $streak',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Completion ${(completionRate * 100).toStringAsFixed(0)}%',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}