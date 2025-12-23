import 'package:flutter/material.dart';
import 'package:ves_event_booking/models/notification/notification_model.dart';

class OfferDetailScreen extends StatelessWidget {
  final NotificationModel notification;

  const OfferDetailScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Nút quay lại
          },
        ),
        title: const Text(
          'Chi tiết sự kiện',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      // Dùng SingleChildScrollView để nội dung dài có thể cuộn
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Ảnh Header
            _buildHeaderImage(),

            const SizedBox(height: 24.0),

            // 2. Nội dung
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('THÔNG TIN ƯU ĐÃI'),

                    _buildDetailContent(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }

  // Widget cho Ảnh Header
  Widget _buildHeaderImage() {
    final String imageUrl = notification.data['image'];

    return Stack(
      children: [
        Image.network(
          imageUrl,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Container(height: 200, color: Colors.grey),
        ),
        // Lớp gradient mờ
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
        ),
        // Text trên ảnh
        Positioned(
          bottom: 16.0,
          left: 16.0,
          right: 16.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4.0),
              // Tạm thời hardcode ngày tháng
              Text(
                'Ngày: ${notification.createdAt.toString().split(' ')[0]}',
                style: TextStyle(color: Colors.white, fontSize: 14.0),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget cho thanh tiêu đề xanh
  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF005A9C), // Màu xanh dương
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Widget cho nội dung
  Widget _buildDetailContent() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ƯU ĐÃI ĐẶC BIỆT',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            notification.message,
            style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(thickness: 1.0),
          ),

          const Text(
            'LƯU Ý QUAN TRỌNG',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8.0),
          const Text(
            'Mỗi người chỉ được nhận một lần duy nhất.\nƯu đãi có giới hạn số lượng.',
            style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
          ),
        ],
      ),
    );
  }
}
