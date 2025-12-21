import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final formatter = NumberFormat('#,###', 'vi_VN');

class TicketCard extends StatelessWidget {
  final String title;
  final String description;
  final double price;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onViewDetail;

  const TicketCard({
    super.key,
    required this.title,
    required this.description,
    required this.price,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
    required this.onViewDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(16),
      //   border: Border.all(color: Colors.blue),
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color.fromARGB(255, 28, 39, 86),
            ),
          ),
          const SizedBox(height: 4),
          Text(description),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('${formatter.format(price)} VND'),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: quantity > 0 ? onRemove : null,
              ),
              Text(quantity.toString()),
              IconButton(icon: const Icon(Icons.add), onPressed: onAdd),
            ],
          ),

          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: onViewDetail,
              child: const Text(
                'Xem thông tin vé',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
