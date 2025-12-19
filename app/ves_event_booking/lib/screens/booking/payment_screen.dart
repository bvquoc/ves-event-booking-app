import 'package:flutter/material.dart';
import 'package:ves_event_booking/models/booking_request.dart';
import 'package:ves_event_booking/models/event_model.dart';
import 'package:ves_event_booking/models/payment_model.dart';
class PaymentScreen extends StatefulWidget {
  final EventModel event;
  final BookingRequest booking;
  final double totalPrice;

  const PaymentScreen({
    super.key,
    required this.event,
    required this.booking,
    required this.totalPrice,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod _selectedMethod = PaymentMethod.zaloPay;

  late final String ticketTypeId;
  late final String ticketType;
  late final int quantity;

  @override
  void initState() {
    super.initState();
    final entry = widget.booking.items.entries.first;
    ticketTypeId = entry.key;
    quantity = entry.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Thanh toán'),
        centerTitle: true,
      ),
      bottomNavigationBar: _bottomBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _eventCard(),
            const SizedBox(height: 12),
            _ticketReceiveInfo(),
            const SizedBox(height: 12),
            _ticketDetailCard(),
            const SizedBox(height: 12),
            _buyerInfoCard(),
            const SizedBox(height: 12),
            _paymentMethodCard(),
            const SizedBox(height: 80),

          ],
        ),
      ),
    );
  }

  // ===================== UI SECTIONS =====================

  Widget _eventCard() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.event.name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 8),
          _iconText(Icons.location_on, widget.event.venueName),
          _iconText(Icons.calendar_today,
              '${widget.event.startDate}'), // format sau
        ],
      ),
    );
  }


  Widget _ticketDetailCard() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Thông tin vé'),
          const SizedBox(height: 8),
          _row('Loại vé', ticketTypeId),
          _row('Số lượng', quantity.toString()),
          _termsText(),
        ],
      ),
    );
  }

  Widget _buyerInfoCard() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Thông tin người mua'),
          const SizedBox(height: 8),
          _row('Họ tên', 'Nguyễn Văn A'),
          _row('Email', 'nguyenvana@gmail.com'),
          _row('Số điện thoại', '0912 345 678'),
        ],
      ),
    );
  }

  Widget _paymentMethodCard() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Phương thức thanh toán'),
          const SizedBox(height: 8),
          ...PaymentMethod.values.map(
            (method) => RadioListTile<PaymentMethod>(
              contentPadding: EdgeInsets.zero,
              value: method,
              groupValue: _selectedMethod,
              title: Text(method.title),
              onChanged: (value) {
                setState(() => _selectedMethod = value!);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===================== BOTTOM BAR =====================

  Widget _bottomBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _row(
              'Tổng thanh toán',
              '${widget.totalPrice.toStringAsFixed(0)} đ',
              bold: true,
              color: Colors.black,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  )
                ),
                onPressed: _onPayPressed,
                child: const Text(
                  'Thanh toán',
                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== ACTION =====================

  void _onPayPressed() {
    final payload = {
      'eventId': widget.booking.eventId,
      'ticketTypeId': ticketTypeId,
      'quantity': quantity,
      'paymentMethod': _selectedMethod.apiValue,
    };

    // TODO:
    // call /tickets/purchase
    // open paymentUrl / ZaloPay
  }

  // ===================== COMMON UI =====================

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Widget _iconText(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _row(String label, String value,
      {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

Widget _termsText() {
  return Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Text.rich(
      TextSpan(
        text: 'Bằng việc tiến hành đặt mua, bạn đã đồng ý với ',
        children: [
          TextSpan(
            text: 'Điều khoản của Ves',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 13),
    ),
  );
}

Widget _ticketReceiveInfo() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFDCE8F6), // xanh nhạt giống hình
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Thông tin nhận vé',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Vé điện tử sẽ được hiển thị trong mục "Vé của tôi" '
          'của tài khoản abc@gmail.com',
          style: TextStyle(height: 1.4),
        ),
      ],
    ),
  );
}