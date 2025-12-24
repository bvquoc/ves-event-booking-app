import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => StaffScreenState();
}

class StaffScreenState extends State<StaffScreen> {
  bool isDialogShowing = false;

  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _showQrResultDialog(String qrValue) {
    isDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false, // bắt buộc bấm nút đóng
      builder: (_) {
        return AlertDialog(
          title: const Text('Thông tin QR'),
          content: Text(
            qrValue,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                isDialogShowing = false;

                await controller.stop(); // ⭐ stop camera
                await controller.start(); // ⭐ start lại → cho scan lại cùng QR
              },
              child: const Text('Đóng'),
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
          /// CAMERA
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (isDialogShowing) return;

              final barcode = capture.barcodes.first;
              final String? value = barcode.rawValue;

              if (value != null) {
                _showQrResultDialog(value);
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
        ],
      ),
    );
  }
}
