import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ves_event_booking/models/ticket/ticket_model.dart';

class CancellationStatusTracker extends StatelessWidget {
  final TicketModel ticket;
  const CancellationStatusTracker({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Xác định trạng thái active
    final isRequested = true; // Luôn luôn active
    final isProcessing = true;
    final isCompleted = false;

    // Màu sắc
    final activeColor = Colors.blue[700];
    final inactiveColor = Colors.grey[300];

    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. Đường kẻ ngang (nằm dưới cùng)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Row(
            children: [
              // Đường kẻ 1
              Expanded(
                child: Container(
                  height: 3,
                  color: isProcessing ? activeColor : inactiveColor,
                ),
              ),
              // Đường kẻ 2
              Expanded(
                child: Container(
                  height: 3,
                  color: isCompleted ? activeColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),

        // 2. Các bước (Icon + Ngày) (nằm bên trên)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Bước 1: Yêu cầu
            _buildTrackerStep(
              icon: Icons.edit,
              date: ticket.purchaseDate,
              dateFormat: dateFormat,
              isActive: isRequested,
            ),
            // Bước 2: Đang xử lý
            _buildTrackerStep(
              icon: Icons.watch_later_outlined,
              date: isProcessing ? DateTime.now() : null,
              dateFormat: dateFormat,
              isActive: isProcessing,
            ),
            // Bước 3: Hoàn tất
            _buildTrackerStep(
              icon: Icons.check_circle_outline,
              date: isCompleted ? DateTime.now() : null,
              dateFormat: dateFormat,
              isActive: isCompleted,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrackerStep({
    required IconData icon,
    required DateTime? date,
    required DateFormat dateFormat,
    required bool isActive,
  }) {
    final activeColor = Colors.blue[700];
    final inactiveColor = Colors.grey[300];

    return Column(
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        // Ngày tháng
        SizedBox(
          height: 15, // fix height
          child: Text(
            date != null ? dateFormat.format(date) : '', // Hiển thị chuỗi rỗng
            style: TextStyle(color: Colors.black, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
