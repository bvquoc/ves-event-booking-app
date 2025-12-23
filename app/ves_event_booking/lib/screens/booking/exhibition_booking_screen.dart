import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ves_event_booking/models/event/event_details_model.dart';
import 'package:ves_event_booking/models/ticket/ticket_model.dart';
import 'package:ves_event_booking/models/ticket/ticket_type_model.dart';
import 'package:ves_event_booking/screens/booking/payment_screen.dart';
import 'package:ves_event_booking/screens/booking/seat_selection_screen.dart';
import 'package:ves_event_booking/widgets/tickets_screen_widgets/ticket_item/ticket_card.dart';
import '../../models/booking_request.dart';
import '../../widgets/event/event_info_card.dart';

class ExhibitionBookingScreen extends StatefulWidget {
  final EventDetailsModel event;

  const ExhibitionBookingScreen({super.key, required this.event});

  @override
  State<ExhibitionBookingScreen> createState() =>
      _ExhibitionBookingScreenState();
}

class _ExhibitionBookingScreenState extends State<ExhibitionBookingScreen> {
  late BookingRequest booking;
  late TicketModel selectedTicket;

  @override
  void initState() {
    super.initState();
    booking = BookingRequest(eventId: widget.event.id);
  }

  double _calculateTotalPrice() {
    double total = 0;

    for (final entry in booking.items.entries) {
      final ticketId = entry.key;
      final quantity = entry.value;

      final ticket = widget.event.ticketTypes.firstWhere(
        (t) => t.id == ticketId,
      );

      total += ticket.price * quantity;
    }

    return total;
  }

  void _showTicketDetail(BuildContext context, TicketTypeModel ticket) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Title
                Text(
                  ticket.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                /// Price
                Text(
                  '${ticket.price.toStringAsFixed(0)} VND',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                /// Description
                Text(ticket.description ?? 'Không có mô tả'),

                const SizedBox(height: 12),

                /// Benefits
                if (ticket.benefits != null && ticket.benefits!.isNotEmpty) ...[
                  const Text(
                    'Quyền lợi:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  ...ticket.benefits!.map(
                    (b) => Row(
                      children: [
                        const Icon(Icons.check, size: 16, color: Colors.green),
                        const SizedBox(width: 6),
                        Expanded(child: Text(b)),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                /// Close button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'ĐÓNG',
                      style: TextStyle(
                        color: Color.fromARGB(255, 28, 39, 86),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String formatPrice(double price) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(price)} VNĐ';
  }

  void _printBookingDebug() {
    print('========== BOOKING DEBUG ==========');

    // Event info
    print('Event ID: ${widget.event.id}');
    print('Event Name: ${widget.event.name}');

    print('--- Tickets ---');

    booking.items.forEach((ticketId, quantity) {
      final ticket = widget.event.ticketTypes!.firstWhere(
        (t) => t.id == ticketId,
      );

      print(
        'Ticket: ${ticket.name} | '
        'Price: ${ticket.price} | '
        'Quantity: $quantity | '
        'Subtotal: ${ticket.price * quantity}',
      );
    });

    // Total price
    final total = _calculateTotalPrice();
    print('--- Total Price ---');
    print('$total VND');

    // User (test)
    print('--- User Info (TEST) ---');
    print('User Name: TEST USER');
    print('User ID: 123');

    print('===================================');
  }

  Widget _buildBottomBar(BuildContext context) {
    final totalPrice = _calculateTotalPrice();

    final toltalQuantity = booking.totalQuantity;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tổng tiền',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  formatPrice(totalPrice),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: totalPrice > 0
                  ? () {
                      _handleNextStep(totalPrice, toltalQuantity);
                    }
                  : null,

              // onPressed: totalPrice > 0
              //     ? () {
              //         _printBookingDebug();
              //       }
              //     : null,

              // onPressed: totalPrice > 0
              //     ? () {
              //         Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (_) => PaymentScreen(
              //               event: widget.event,
              //               booking: booking,
              //             ),
              //           ),
              //         );
              //       }
              //     : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Tiếp tục', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNextStep(double totalPrice, int totalQuantity) async {
    if (widget.event.venueId != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SeatSelectionScreen(
            eventId: widget.event.id,
            venueId: widget.event.venueId!,
            requiredQuantities: booking.items,
            ticketTypes: widget.event.ticketTypes,
          ),
        ),
      );

      if (result != null && result is Map<String, List<String>>) {
        // Lưu danh sách ghế đã chọn vào booking
        booking.ticketSeatMap = result;

        // Kiểm tra widget còn mounted không trước khi dùng context
        if (!mounted) return;

        // Chuyển sang màn hình thanh toán
        _goToPayment(totalPrice);
      }
    } else {
      _goToPayment(totalPrice);
    }
  }

  void _goToPayment(double totalPrice) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          event: widget.event,
          booking: booking,
          totalPrice: totalPrice,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tickets = widget.event.ticketTypes;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chọn loại vé'),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Thông tin sự kiện
          EventInfoCard(event: widget.event),

          // Danh sách vé
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: tickets.length,
              itemBuilder: (_, index) {
                final ticket = tickets[index];
                final quantity = booking.items[ticket.id] ?? 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: ClipRRect(
                    child: Stack(
                      children: [
                        /// BACKGROUND IMAGE
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/exhibition_bg.png',
                            fit: BoxFit.cover,
                          ),
                        ),

                        /// OVERLAY (để chữ dễ đọc)
                        Positioned.fill(
                          child: Container(
                            color: Colors.white.withOpacity(0.55),
                          ),
                        ),

                        /// CONTENT
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: TicketCard(
                            title: ticket.name,
                            description: ticket.description ?? '',
                            price: ticket.price,
                            quantity: quantity,
                            onAdd: () {
                              setState(() {
                                booking.items[ticket.id] = quantity + 1;
                              });
                            },
                            onRemove: () {
                              setState(() {
                                if (quantity <= 1) {
                                  booking.items.remove(ticket.id);
                                } else {
                                  booking.items[ticket.id] = quantity - 1;
                                }
                              });
                            },
                            onViewDetail: () {
                              _showTicketDetail(context, ticket);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom tổng tiền
          _buildBottomBar(context),
        ],
      ),
    );
  }
}
