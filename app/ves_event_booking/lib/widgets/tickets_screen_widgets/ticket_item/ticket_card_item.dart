import 'package:flutter/material.dart';
import 'package:ves_event_booking/models/ticket/ticket_model.dart';

class TicketCardItem extends StatefulWidget {
  final TicketModel ticket;
  const TicketCardItem({super.key, required this.ticket});

  @override
  State<TicketCardItem> createState() => _EventCardItemState();
}

class _EventCardItemState extends State<TicketCardItem> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('Đã nhấn vào thẻ: ${widget.ticket.eventName}');

        // Khi có màn hình chi tiết (mã qr cho vé đã mua), điều hướng ở đây
        //
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => TicketQRScreen(event: widget.event),
        //   ),
        // );
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 24.0, left: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Stack(
            children: [
              // 1. Ảnh nền
              Image.network(
                widget.ticket.eventThumbnail ?? '',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey,
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.white),
                    ),
                  );
                },
              ),

              // 2. Lớp phủ Gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0, 0.4, 0.6, 1],
                    ),
                  ),
                ),
              ),

              // 3. Icon Trái tim (Yêu thích)
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.white,
                    size: 28,
                  ),
                  onPressed: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                    // call api to update favorite status in backend if needed
                  },
                ),
              ),

              // 4. Nội dung (Tên sự kiện & Vị trí)
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên sự kiện
                    Text(
                      widget.ticket.eventName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Tag vị trí
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min, // Important
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            // widget.ticket.event.city,
                            "",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
