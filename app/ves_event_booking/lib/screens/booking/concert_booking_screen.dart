import 'package:flutter/material.dart';
import 'package:ves_event_booking/models/booking_request.dart';
import 'package:ves_event_booking/models/event/event_model.dart';
import 'package:ves_event_booking/widgets/event/event_info_card.dart';
import 'payment_screen.dart';

class ConcertBookingScreen extends StatefulWidget {
  final EventModel event;

  const ConcertBookingScreen({
    super.key,
    required this.event,
  });

  @override
  State<ConcertBookingScreen> createState() => _ConcertBookingScreenState();
}

class _ConcertBookingScreenState extends State<ConcertBookingScreen> {
  late final List<_ZoneTicket> zones;
  final Map<String, _ZoneTicket> selectedZones = {};

  @override
  void initState() {
    super.initState();

    zones = widget.event.ticketTypes.map((t) {
      return _ZoneTicket(
        id: t.id,
        name: t.name,
        price: t.price.toInt(),
      );
    }).toList();
  }

  int get totalPrice {
    return selectedZones.values.fold(
      0,
      (sum, z) => sum + z.price * z.quantity,
    );
  }

  void _onContinue() {
    final booking = BookingRequest(
      eventId: widget.event.id,
      items: {
        for (final z in selectedZones.values) z.id: z.quantity,
      },
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          event: widget.event,
          booking: booking,
          totalPrice: totalPrice.toDouble(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Chọn vé concert'), backgroundColor: Colors.white,),
      bottomNavigationBar: _BottomBar(
        totalPrice: totalPrice,
        onContinue: _onContinue,
      ),
      body: Column(
        children: [

          EventInfoCard(event: widget.event),
          
          /// ZONE LIST (MAP)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: zones.map(_buildZoneItem).toList(),
            ),
          ),

          const Divider(),

          /// SELECTED ZONES
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children:
                  selectedZones.values.map(_selectedZoneItem).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneItem(_ZoneTicket zone) {
    final isSelected = selectedZones.containsKey(zone.id);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedZones.remove(zone.id);
          } else {
            selectedZones[zone.id] = _ZoneTicket(
              id: zone.id,
              name: zone.name,
              price: zone.price,
            );
          }
        });
      },
      child: Container(
        width: 140,
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          zone.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _selectedZoneItem(_ZoneTicket zone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            child: Text(zone.quantity.toString()),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zone.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text('${zone.price} VND'),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: zone.quantity > 1
                ? () => setState(() => zone.quantity--)
                : null,
          ),
          Text(zone.quantity.toString()),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => setState(() => zone.quantity++),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () =>
                setState(() => selectedZones.remove(zone.id)),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int totalPrice;
  final VoidCallback onContinue;

  const _BottomBar({
    required this.totalPrice,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Tổng tiền\n$totalPrice VND',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: totalPrice == 0 ? null : onContinue,
            child: const Text('Tiếp tục'),
          ),
        ],
      ),
    );
  }
}

class _ZoneTicket {
  final String id; // ticketTypeId
  final String name;
  final int price;
  int quantity;

  _ZoneTicket({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
  });
}
