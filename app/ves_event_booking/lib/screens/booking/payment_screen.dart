import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ves_event_booking/models/booking_request.dart';
import 'package:ves_event_booking/models/payment_model.dart';
import 'package:ves_event_booking/models/purchase/purchase_model_request.dart';
import 'package:ves_event_booking/models/ticket/ticket_details_model.dart';
import 'package:ves_event_booking/models/ticket/ticket_type_model.dart';
import 'package:ves_event_booking/models/user/user_model.dart';
import 'package:ves_event_booking/providers/ticket_provider.dart';

class PaymentScreen extends StatefulWidget {
  final EventDetailsModel event;
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
  UserModel? user;

  /// 🔑 DANH SÁCH VÉ ĐÃ CHỌN (MULTI)
  late final List<_PaymentTicketItem> _ticketItems;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TicketProvider>().fetchUserInfo();
    });

    _ticketItems = widget.booking.items.entries.map((entry) {
      final TicketTypeModel ticket = widget.event.ticketTypes.isNotEmpty
          ? widget.event.ticketTypes.firstWhere(
              (t) => t.id == entry.key,
              orElse: () =>
                  throw Exception('TicketType not found for id=${entry.key}'),
            )
          : throw Exception('No ticket types available for this event');

      return _PaymentTicketItem(
        id: ticket.id,
        name: ticket.name,
        price: ticket.price,
        quantity: entry.value,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TicketProvider>(
      builder: (context, provider, _) {
        // ⏳ Loading
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // ❌ Error
        if (provider.errorMessage != null) {
          return Center(
            child: Text(
              provider.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        user = provider.user;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Thanh toán'),
            centerTitle: true,
            backgroundColor: Colors.white,
          ),
          bottomNavigationBar: _bottomBar(provider),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _eventCard(),
                const SizedBox(height: 12),
                _ticketReceiveInfo(),
                const SizedBox(height: 12),
                _ticketDetailCard(), // ✅ ĐÃ SỬA
                const SizedBox(height: 12),
                _buyerInfoCard(user), // ✅ ĐÃ SỬA
                const SizedBox(height: 12),
                _paymentMethodCard(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
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
          _iconText(
            Icons.location_on,
            widget.event.venueName ?? 'Địa điểm chưa xác định',
          ),
          _iconText(Icons.calendar_today, '${widget.event.startDate}'),
        ],
      ),
    );
  }

  Widget _ticketDetailCard() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Thông tin đặt vé'),
          const SizedBox(height: 16),

          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Loại vé',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                'Số lượng',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// LIST TICKET
          ..._ticketItems.expand((item) {
            return [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// LEFT
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${item.price.toStringAsFixed(0)} đ',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),

                  /// RIGHT
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item.quantity.toString().padLeft(2, '0'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${(item.price * item.quantity).toStringAsFixed(0)} đ',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
            ];
          }).toList(),

          _termsText(),
        ],
      ),
    );
  }

  Widget _buyerInfoCard(UserModel? user) {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Thông tin người mua'),
          const SizedBox(height: 8),
          _row(
            'Họ tên',
            // Kiểm tra nếu user là null thì hiện "Đang tải..."
            user == null
                ? 'Đang tải thông tin...'
                : (user.firstName != null && user.lastName != null
                      ? '${user.firstName} ${user.lastName}'
                      : user.username),
          ),
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

  Widget _bottomBar(TicketProvider provider) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
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
                  ),
                ),
                onPressed: () => _onPayPressed(provider),
                child: const Text(
                  'Thanh toán',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== ACTION =====================

  void _onPayPressed(TicketProvider provider) async {
    // await provider.createZalopayOrder(
    //   user!.username,
    //   widget.totalPrice.toInt(),
    // );

    // print('ZaloPay Order: ${provider.zalopayOrder}');

    // Gọi API tạo đơn thanh toán khi đẫ hoàn thành chuyển tiền
    List<Future<void>> futures = [];

    for (final item in _ticketItems) {
      final request = provider.createTicket(
        PurchaseModelRequest(
          eventId: widget.booking.eventId,
          ticketTypeId: item.id,
          quantity: item.quantity,
          seatIds: [],
          voucherCode: "",
          paymentMethod: _selectedMethod.apiValue,
        ),
      );
      futures.add(request);
    }

    await Future.wait(futures);
  }

  // ===================== COMMON UI =====================

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

  Widget _row(String label, String value, {bool bold = false, Color? color}) {
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

/// =====================
/// UI-ONLY HELPER MODEL
/// =====================
class _PaymentTicketItem {
  final String id;
  final String name;
  final double price;
  final int quantity;

  _PaymentTicketItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });
}

// =====================
// GIỮ NGUYÊN
// =====================

Widget _termsText() {
  return Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Text.rich(
      TextSpan(
        text: 'Bằng việc tiến hành đặt mua, bạn đã đồng ý với ',
        children: [
          TextSpan(
            text: 'Điều khoản của Ves',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
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
      color: const Color(0xFFDCE8F6),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Thông tin nhận vé',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
