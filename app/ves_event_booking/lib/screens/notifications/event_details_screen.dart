import 'package:flutter/material.dart';
import 'package:ves_event_booking/models/event_model.dart';

class EventDetailScreen extends StatelessWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

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
                    _buildSectionHeader('THÔNG TIN SỰ KIỆN'),

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
    return Stack(
      children: [
        // Ảnh nền (hiện chưa có link thật thay thế bằng placeholder)
        // Image.network(
        //   event.imageUrl,
        //   height: 200,
        //   width: double.infinity,
        //   fit: BoxFit.cover,
        // ),
        Image.asset(
          event.imageUrl,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
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
                event.title,
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
              const Text(
                'Hạn: 16/11/2024',
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
    // Tạm thời hardcore nội dung
    const String thongTinLuuY =
        'Độ tuổi tối thiểu: Sự kiện không dành cho người dưới 14 tuổi. Người từ 14 đến 18 tuổi cần có người bảo hộ đi theo.\n'
        'Hạng vé X-Vip không dành cho người dưới 18 tuổi\n'
        'Lối đi chuyên hạng vé thường:\n'
        'Cổng N1 và N2: Dành cho xe ô tô\n'
        'Cổng S3: Dành cho xe máy\n'
        'Lối đi chuyên hạng vé XVIP:\n'
        '  1. Cổng N2: Dành cho xe máy\n'
        '  2. Cổng N3: Dành cho xe ô tô';

    const String luuYQuanTrong =
        'Hệ thống biển chỉ dẫn đã được lắp đặt dọc đường đi.\n'
        'Có đội ngũ nhân sự điều phối của The Global City sẵn sàng hỗ trợ. Nếu không rành đường, hỏi các anh/chị bảo vệ.\n'
        'Lực lượng CSGT cũng sẽ được huy động điều phối giao thông bên ngoài khu vực sự kiện.\n'
        'Bãi giữ xe đã được bố trí thêm nhân sự, gửi xe đỡ tốn nỗ lực để dễ dàng hơn.\n'
        'Phía chương trình đã chuẩn bị các khu vực tiếp nước và dù ở nhà đổi võng để nghỉ ngơi.';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'THÔNG TIN LƯU Ý',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8.0),
          const Text(
            thongTinLuuY,
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
            luuYQuanTrong,
            style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
          ),
        ],
      ),
    );
  }
}
