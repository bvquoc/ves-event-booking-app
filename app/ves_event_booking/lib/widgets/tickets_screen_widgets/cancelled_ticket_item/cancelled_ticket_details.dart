import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ves_event_booking/models/ticket_model.dart';
import 'package:ves_event_booking/widgets/tickets_screen_widgets/cancelled_ticket_item/cancellation_status_tracker.dart';

class CancelledTicketDetail extends StatelessWidget {
  final TicketModel ticket;
  const CancelledTicketDetail({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    // Body chính là một ListView để có thể cuộn
    return ListView(
      // Padding cho toàn bộ danh sách và chừa chỗ cho BottomNavBar
      padding: const EdgeInsets.all(16.0).copyWith(bottom: 100.0),
      children: [
        _buildStatusHeader(context),
        const SizedBox(height: 16),
        _buildBuyerInfoCard(context),
        const SizedBox(height: 16),
        _buildReasonCard(context),
        const SizedBox(height: 16),
        _buildTotalCard(context),
        const SizedBox(height: 24),
        _buildEventInfo(context),
        const SizedBox(height: 24),
        // Tái sử dụng widget tracker
        CancellationStatusTracker(ticket: ticket),
        const SizedBox(height: 24),
        _buildSupportCard(context),
        const SizedBox(height: 16),
        _buildOrderInfoCard(context),
      ],
    );
  }

  // --- CÁC WIDGET HELPER CHO TỪNG THẺ ---

  // Thẻ "Đã hủy" (màu xanh)
  Widget _buildStatusHeader(BuildContext context) {
    // Hiện chưa có field cancelledDate trong model nên tạm dùng purchaseDate
    final cancelDate = DateFormat('dd/MM/yyyy').format(ticket.purchaseDate);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue[800], // Màu xanh đậm
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Đã hủy vào $cancelDate',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Đã được hủy bởi bạn',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ],
      ),
    );
  }

  // Thẻ "Thông tin người mua" (màu trắng)
  Widget _buildBuyerInfoCard(BuildContext context) {
    return _buildWhiteCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin người mua',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 24, color: Colors.black12),
          _buildInfoRow('Họ và tên', 'userName'),
          _buildInfoRow('Email', 'userEmail'),
          _buildInfoRow('Số điện thoại', 'userPhone'),
          _buildInfoRow('Ngày sinh', 'userDOB'),
        ],
      ),
    );
  }

  // Thẻ "Lý do hủy đơn" (màu trắng)
  Widget _buildReasonCard(BuildContext context) {
    return _buildWhiteCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lý do hủy đơn',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            ticket.cancellationReason ?? 'Không có lý do',
            style: TextStyle(color: Colors.black54, fontSize: 15),
          ),
        ],
      ),
    );
  }

  // Thẻ "Thành tiền" (màu trắng)
  Widget _buildTotalCard(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final amount = ticket.refundAmount ?? 0;

    return _buildWhiteCard(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Số tiền hoàn',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            currencyFormat.format(amount),
            style: TextStyle(
              color: Colors.blue[800],
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Phần "Thông tin sự kiện" (ảnh + text)
  Widget _buildEventInfo(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ảnh sự kiện
        ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Image.network(
            ticket.event.thumbnail,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Container(height: 180, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 16),
        // Tên sự kiện
        Text(
          ticket.event.name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // Hàng 1: Ngày + Giờ
        _buildIconTextRow(
          Icons.calendar_today_outlined,
          dateFormat.format(ticket.event.startDate),
          Icons.access_time_outlined,
          timeFormat.format(ticket.event.startDate),
        ),
        const SizedBox(height: 8),
        // Hàng 2: Địa điểm + Số ghế
        _buildIconTextRow(
          Icons.location_on_outlined,
          ticket.event.venueName,
          Icons.event_seat_outlined,
          ticket.seatNumber ?? 'Tự do',
        ),
      ],
    );
  }

  // Thẻ "Bạn cần hỗ trợ?" (màu trắng)
  Widget _buildSupportCard(BuildContext context) {
    return _buildWhiteCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bạn cần hỗ trợ?',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          _buildSupportRow(Icons.headset_mic_outlined, 'Liên hệ hỗ trợ', () {}),
          _buildSupportRow(Icons.help_outline, 'Trung tâm hỗ trợ', () {}),
        ],
      ),
    );
  }

  // Thẻ "Mã đơn hàng" (màu trắng)
  Widget _buildOrderInfoCard(BuildContext context) {
    final dateFormat = DateFormat('dd-MM-yyyy HH:mm');

    return _buildWhiteCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Mã đơn hàng', ticket.orderId),
          _buildInfoRow(
            'Phương thức thanh toán',
            'Ví điện tử',
          ), // Hiện model chưa có nên hardcore
          _buildInfoRow(
            'Thời gian đặt vé',
            dateFormat.format(ticket.purchaseDate),
          ),
        ],
      ),
    );
  }

  // --- CÁC WIDGET TÁI SỬ DỤNG NỘI BỘ ---

  // Helper cho các thẻ trắng
  Widget _buildWhiteCard(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: child,
    );
  }

  // Helper cho các hàng thông tin (Họ tên, Email...)
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 15)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Helper cho các hàng hỗ trợ
  Widget _buildSupportRow(IconData icon, String text, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.black54),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  // Helper cho hàng Icon + Text
  Widget _buildIconTextRow(
    IconData icon1,
    String text1,
    IconData icon2,
    String text2,
  ) {
    return Row(
      children: [
        Icon(icon1, color: Colors.blue, size: 18),
        const SizedBox(width: 8),
        Text(text1, style: const TextStyle(color: Colors.black, fontSize: 15)),
        const Spacer(),
        Icon(icon2, color: Colors.blue, size: 18),
        const SizedBox(width: 8),
        Text(text2, style: const TextStyle(color: Colors.black, fontSize: 15)),
        const SizedBox(width: 16),
      ],
    );
  }
}
