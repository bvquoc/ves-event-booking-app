import 'package:flutter/material.dart';
import 'package:ves_event_booking/models/booking_request.dart';
import 'package:ves_event_booking/models/event_model.dart';
import 'package:ves_event_booking/widgets/tickets_screen_widgets/ticket_item/selected_zone_item.dart';

class ConcertBookingScreen extends StatefulWidget {
  final EventModel event;

  const ConcertBookingScreen({super.key, required this.event});

  @override
  State<ConcertBookingScreen> createState() =>
      _ConcertBookingScreenState();
}

class _ConcertBookingScreenState extends State<ConcertBookingScreen> {
  late BookingRequest booking;

  @override
  void initState() {
    super.initState();
    booking = BookingRequest(eventId: widget.event.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn khu vực vé')),
      body: Column(
        children: [
          _buildVenueMap(),
          Expanded(child: _buildSelectedZones()),
          _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildVenueMap() {
    return Container(
      height: 250,
      color: Colors.black87,
      alignment: Alignment.center,
      child: const Text(
        'Venue Map (tap zone)',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildSelectedZones() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: widget.event.ticketTypes!.map((zone) {
        final quantity = booking.items[zone.id] ?? 0;

        if (quantity == 0) return const SizedBox();

        return SelectedZoneItem(
          name: zone.name,
          price: zone.price,
          quantity: quantity,
          onAdd: () {
            setState(() {
              booking.items[zone.id] = quantity + 1;
            });
          },
          onRemove: () {
            setState(() {
              if (quantity <= 1) {
                booking.items.remove(zone.id);
              } else {
                booking.items[zone.id] = quantity - 1;
              }
            });
          },
          onDelete: () {
            setState(() {
              booking.items.remove(zone.id);
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildContinueButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: booking.totalQuantity > 0
              ? () {
                  // sang payment
                }
              : null,
          child: const Text('Tiếp tục'),
        ),
      ),
    );
  }
}
