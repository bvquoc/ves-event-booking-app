import 'package:flutter/material.dart';
import 'package:ves_event_booking/models/offer_model.dart';

class OfferDetailScreen extends StatelessWidget {
  final OfferModel offer;

  const OfferDetailScreen({super.key, required this.offer});

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
          offer.imageUrl,
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
                offer.title,
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
    const String uuDaiDacbiet =
        'Thời gian áp dụng: đến hết ngày 16/11/2024\n'
        'Nội dung chương trình:\n'
        'Khi người dùng mở thẻ thanh toán hoặc liên kết ví điện tử lần đầu trên ứng dụng đặt vé sự kiện, sẽ được tặng ngay gói ưu đãi trị giá đến 1.000.000 VNĐ.\n';

    const String cachThamGia =
        '1. Tải hoặc đăng nhập lần đầu ứng dụng đặt vé sự kiện.\n'
        '2. Tiến hành mở thẻ thanh toán liên kết hoặc kết nối ví điện tử lần đầu.\n'
        '3. Ưu đãi sẽ được kích hoạt tự động trong mục "Ưu đãi của tôi".\n';

    const String luuYQuanTrong =
        '1. Mỗi người chỉ được nhận một lần duy nhất.\n'
        '2. Ưu đãi có giới hạn số lượng, hết sớm khi đủ lượt đăng ký.\n'
        '3. Mỗi mã giảm giá đều có giới hạn riêng, vui lòng kiểm tra trước khi sử dụng.\n';

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
          const Text(
            uuDaiDacbiet,
            style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(thickness: 1.0),
          ),
          const Text(
            'CÁCH THAM GIA',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8.0),
          const Text(
            cachThamGia,
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
