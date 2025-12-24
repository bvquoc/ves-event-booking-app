import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ves_event_booking/models/event/event_model.dart';

final formatter = NumberFormat('#,###', 'vi_VN');

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _EventImage(
            imageUrl: event.thumbnail ?? '',
            isFavorite: event.isFavorite != null && event.isFavorite == true,
            onFavoriteTap: onFavoriteTap,
          ),

          const SizedBox(height: 6),
          Expanded(child: _EventContent(event: event)),
        ],
      ),
    );
  }
}

class _EventImage extends StatelessWidget {
  final String imageUrl;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  const _EventImage({
    required this.imageUrl,
    required this.isFavorite,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Image(
            height: 100,
            width: double.infinity,
            fit: BoxFit.cover,
            image: imageUrl.startsWith('http')
                ? NetworkImage(imageUrl)
                : AssetImage(imageUrl) as ImageProvider,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 100,
                width: double.infinity,
                color: Colors.grey[300], // Màu nền xám nhạt
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.broken_image, color: Colors.grey, size: 24),
                    SizedBox(height: 4),
                    Text(
                      "img not found",
                      style: TextStyle(
                        color: Colors.grey, // Chữ màu xám đậm
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onFavoriteTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 16,
                  color: Colors.blue.shade900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventContent extends StatelessWidget {
  final EventModel event;

  const _EventContent({required this.event});

  String formatPrice(num price) {
    if (price >= 1000000) {
      final million = price / 1000000;
      // Nếu là số tròn → không hiển thị .0
      if (million == million.roundToDouble()) {
        return '${million.toInt()} Triệu';
      }
      return '${million.toStringAsFixed(1)} Triệu';
    }

    return '${formatter.format(price.toInt())}đ';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          event.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),

        Row(
          children: [
            const Icon(Icons.access_time_filled, size: 14),
            const SizedBox(width: 2),
            Text(
              _formatDate(event.startDate),
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
            const Spacer(),
            Text(
              'Từ ${formatPrice(event.minPrice ?? 0)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Color(0xff0007ab),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
