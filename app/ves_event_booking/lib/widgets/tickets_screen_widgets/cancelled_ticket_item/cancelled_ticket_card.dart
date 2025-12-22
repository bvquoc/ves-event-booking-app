import 'package:flutter/material.dart';
import 'package:ves_event_booking/models/ticket/ticket_model.dart';
import 'package:ves_event_booking/screens/tickets/cancelled_ticket_details_screen.dart';
// import 'package:ves_event_booking/widgets/tickets_screen_widgets/cancelled_ticket_item/ticket_clipper.dart';

class CancelledTicketCard extends StatelessWidget {
  final TicketModel ticket;
  const CancelledTicketCard({super.key, required this.ticket});

  // HÀM HELPER LẤY MÀU NỀN
  Color _getBackgroundColor(String? refundStatus) {
    if (refundStatus == 'completed') {
      return Colors.green[600]!;
    } else if (refundStatus == 'processing') {
      return Colors.yellow[700]!;
    } else {
      return Colors.grey[600]!; // requested hoặc mặc định
    }
  }

  // HÀM HELPER LẤY VĂN BẢN
  String _getStatusText(String? refundStatus) {
    if (refundStatus == 'completed') {
      return 'Đã hoàn tiền';
    } else if (refundStatus == 'processing') {
      return 'Đang xử lý';
    } else {
      return 'Đang xác nhận';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CancelledTicketDetailScreen(ticket: ticket),
          ),
        );
      },
      child: ClipRect(
        // Đổi sang ClipPath và sử dụng clipper bên dưới để tạo hình răng cưa (tạm thời vô hiệu do emulator yếu)
        //clipper: TicketClipper(),
        child: Stack(
          children: [
            Image.network(
              ticket.eventThumbnail ?? '',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(height: 180, color: Colors.grey),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),

            // Nội dung
            Positioned(
              bottom: 16,
              left: 26,
              right: 26,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Tên sự kiện
                  Expanded(
                    child: Text(
                      ticket.eventName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                    ),
                  ),

                  // --- PHẦN CẬP NHẬT TAG TRẠNG THÁI ---
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      // Dùng hàm helper
                      color: _getBackgroundColor(ticket.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      // Dùng hàm helper
                      _getStatusText(ticket.status),
                      style: TextStyle(
                        // Dùng hàm helper
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
