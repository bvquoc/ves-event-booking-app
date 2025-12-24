import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => StaffScreenSate();
}

class StaffScreenSate extends State<StaffScreen> {
  String? qrResult;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text('Quét mã QR', style: TextStyle(color: Colors.black)),
      ),
      body: Stack(
        children: [
          /// CAMERA PREVIEW
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (!allowScan) return;

              final barcode = capture.barcodes.first;
              final String? value = barcode.rawValue;

              if (value != null) {
                setState(() {
                  qrResult = value;
                  allowScan = false;
                });
              }
            },
          ),

          /// KHUNG QUÉT
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

          /// BUTTON SCAN
          Positioned(
            bottom: 140,
            left: 24,
            right: 24,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  qrResult = null;
                  allowScan = true; // ⭐ bật scan
                });
              },
              child: const Text('Bắt đầu quét'),
            ),
          ),

          /// KẾT QUẢ
          if (qrResult != null)
            Positioned(
              bottom: 60,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  qrResult!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
