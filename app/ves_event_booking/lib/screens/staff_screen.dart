import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => StaffScreenState();
}

class StaffScreenState extends State<StaffScreen> {
  bool allowScan = false;

  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // Hàm hiển thị Pop-up kết quả
  void _showResultDialog(String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Kết quả quét"),
          content: Text(code), // Nội dung chuỗi quét được
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng popup
                // Nếu muốn đóng popup xong quét tiếp luôn thì sử dụng:
                // setState(() { allowScan = true; });
              },
              child: const Text("Đóng"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text('Quét mã QR', style: TextStyle(color: Colors.black)),
      ),
      body: Stack(
        children: [
          /// CAMERA PREVIEW
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              // Nếu chưa bấm nút "Bắt đầu" thì không xử lý
              if (!allowScan) return;

              final barcode = capture.barcodes.first;
              final String? value = barcode.rawValue;

              if (value != null) {
                // 1. Ngừng cho phép quét ngay lập tức để tránh mở nhiều popup
                setState(() {
                  allowScan = false;
                });

                // 2. Hiện popup (Kiểm tra mounted để tránh lỗi nếu thoát màn hình nhanh)
                if (mounted) {
                  _showResultDialog(value);
                }
              }
            },
          ),

          /// KHUNG QUÉT (Overlay)
          // Tạo màn che màu đen mờ xung quanh vùng quét
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Viền trắng của khung quét
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),

          /// BUTTON BẮT ĐẦU QUÉT
          Positioned(
            bottom: 100,
            left: 24,
            right: 24,
            child: Column(
              children: [
                if (!allowScan)
                  Container(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: const Text(
                      "Nhấn nút bên dưới để quét",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ElevatedButton(
                  onPressed: allowScan
                      ? null // Nếu đang quét thì disable nút
                      : () {
                          setState(() {
                            allowScan = true; // ⭐ Bật chế độ cho phép quét
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: allowScan ? Colors.grey : Colors.blue,
                  ),
                  child: Text(
                    allowScan ? 'Đang quét...' : 'Bắt đầu quét',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
