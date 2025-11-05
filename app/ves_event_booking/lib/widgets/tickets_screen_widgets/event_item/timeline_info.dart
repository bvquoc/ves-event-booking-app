import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimelineInfo extends StatelessWidget {
  final DateTime date;
  const TimelineInfo({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    // Định dạng ngày tháng
    final day = DateFormat('dd').format(date);
    // 'ThgM' sẽ cho ra 'Thg3', 'Thg4', v.v.
    final month = DateFormat("'Thg'M", 'vi_VN').format(date);
    final time = DateFormat('HH:mm').format(date);

    return Container(
      // Fixed width
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Text(
            month,
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Text(
            time,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
