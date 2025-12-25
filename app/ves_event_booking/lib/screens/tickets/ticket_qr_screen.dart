import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ves_event_booking/models/ticket/ticket_model.dart';

class TicketQRScreen extends StatelessWidget {
  const TicketQRScreen({super.key, required this.ticket});
  final TicketModel ticket;

  String _buildSeatInfo() {
    List<String> parts = [];

    if (ticket.seatSectionName != null && ticket.seatSectionName!.isNotEmpty) {
      parts.add("Khu: ${ticket.seatSectionName}");
    }
    if (ticket.seatRowName != null && ticket.seatRowName!.isNotEmpty) {
      parts.add("Hàng: ${ticket.seatRowName}");
    }
    if (ticket.seatNumber != null && ticket.seatNumber!.isNotEmpty) {
      parts.add("Ghế: ${ticket.seatNumber}");
    }

    if (parts.isEmpty) return "Tự do";
    return parts.join(" - ");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/event_image.jpeg',
              fit: BoxFit.fill,
            ),
          ),

          Center(child: _buildTicketCard()),
        ],
      ),
    );
  }

  Widget _buildTicketCard() {
    final rawDate = ticket.eventStartDate.toString();
    final dateTime = DateTime.parse(rawDate);
    final date = DateFormat('dd/MM/yyyy').format(dateTime);
    final time = DateFormat('HH:mm').format(dateTime);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 30),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 40),

                /// QR CODE
                QrImageView(data: ticket.qrCode, size: 220),

                const SizedBox(height: 20),
                const DottedLine(dashColor: Colors.grey),
                const SizedBox(height: 16),

                Text(
                  ticket.eventName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Ngày giờ
                _infoRow(Icons.calendar_today, date),
                _infoRow(Icons.access_time, time),

                // Loại vé
                _infoRow(Icons.confirmation_number, ticket.ticketTypeName),

                // Thông tin ghế
                _infoRow(Icons.event_seat, _buildSeatInfo()),

                // Địa điểm
                _infoRow(Icons.location_on, ticket.venueName),
              ],
            ),
          ),

          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.asset('assets/images/logo.png'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}
