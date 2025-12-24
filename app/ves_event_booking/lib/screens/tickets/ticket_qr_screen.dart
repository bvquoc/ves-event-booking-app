import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ves_event_booking/models/ticket/ticket_model.dart';

class TicketQRScreen extends StatelessWidget {
  const TicketQRScreen({super.key, required this.ticket});
  final TicketModel ticket;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(
          color: Colors.white, // ⭐ đổi màu nút back
        ),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Text(
            "Vé của tôi",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(flex: 2),
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
      padding: const EdgeInsets.symmetric(horizontal: 64),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 30),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 40),

                /// QR CODE
                QrImageView(data: ticket.qrCode, size: 240),

                const SizedBox(height: 20),
                const DottedLine(),

                const SizedBox(height: 16),
                Text(
                  ticket.eventName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),
                _infoRow(Icons.calendar_today, date),

                _infoRow(Icons.access_time, time),
                _infoRow(Icons.confirmation_number, ticket.ticketTypeName),
                _infoRow(Icons.location_on, ticket.venueName),
              ],
            ),
          ),

          /// LOGO TRÒN
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Image.asset('assets/images/logo.png', width: 32),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.visible,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   print(ticket.qrCode);
  //   return Scaffold(
  //     backgroundColor: Colors.white,
  //     appBar: AppBar(
  //       title: Text('QR Code'),
  //       centerTitle: true,
  //       backgroundColor: Colors.white,
  //     ),
  //     body: Column(
  //       children: [
  //         QrImageView(data: ticket.qrCode, size: 300),
  //         Center(child: Text(ticket.eventName)),
  //       ],
  //     ),
  //   );
  // }
}
