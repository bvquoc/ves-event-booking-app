import 'package:flutter/material.dart';

class SelectedZoneItem extends StatelessWidget {
  final String name;
  final double price;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onDelete;

  const SelectedZoneItem({
    super.key,
    required this.name,
    required this.price,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          )
        ],
        color: Colors.white,
      ),
      child: Row(
        children: [
          // Thông tin khu vực
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${price.toStringAsFixed(0)} VND',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          // Nút -
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: quantity > 1 ? onRemove : null,
          ),

          // Số lượng
          Text(
            quantity.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          // Nút +
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: onAdd,
          ),

          // Nút xóa
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
