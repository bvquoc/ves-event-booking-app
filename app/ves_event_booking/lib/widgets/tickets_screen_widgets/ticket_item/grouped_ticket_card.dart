import 'package:flutter/material.dart';
import 'package:ves_event_booking/models/ticket/ticket_model.dart';
import 'package:ves_event_booking/screens/tickets/ticket_qr_screen.dart';

class GroupedTicketCard extends StatefulWidget {
  final List<TicketModel> tickets;

  const GroupedTicketCard({super.key, required this.tickets});

  @override
  State<GroupedTicketCard> createState() => _GroupedTicketCardState();
}

class _GroupedTicketCardState extends State<GroupedTicketCard> {
  bool _isExpanded = true;

  // Hàm helper để tạo chuỗi hiển thị vị trí ghế
  String _buildSeatInfo(TicketModel ticket) {
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

    if (parts.isEmpty)
      return "Tự do"; // Hoặc chuỗi mặc định nếu không có thông tin ghế

    return parts.join(" - "); // Ví dụ: Khu: A - Hàng: B - Ghế: 10
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tickets.isEmpty) return const SizedBox.shrink();

    final eventInfo = widget.tickets.first;

    return Container(
      margin: const EdgeInsets.only(bottom: 24, left: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(
              children: [
                Image.network(
                  eventInfo.eventThumbnail ?? '',
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eventInfo.eventName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white70,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              eventInfo.venueName,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. DANH SÁCH VÉ
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Danh sách vé (${widget.tickets.length})",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() => _isExpanded = !_isExpanded),
                      child: Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                if (_isExpanded) ...[
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  // Duyệt qua từng vé
                  ...widget.tickets.map((ticket) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TicketQRScreen(ticket: ticket),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.confirmation_num_outlined,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ticket.ticketTypeName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _buildSeatInfo(ticket),
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  // ----------------------------------
                                ],
                              ),
                            ),
                            const Icon(Icons.qr_code, color: Colors.black54),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
