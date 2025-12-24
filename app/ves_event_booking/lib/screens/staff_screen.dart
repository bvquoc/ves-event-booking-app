import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ves_event_booking/services/check_in_service.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => StaffScreenState();
}

class StaffScreenState extends State<StaffScreen> {
  final CheckInService _checkInService = CheckInService();

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

  void _showCheckInDialog(String qrCodeValue) {
    isDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isLoading = false;
        bool isChecked = false;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            String displayContent = "Mã vé: $qrCodeValue";
            Color statusColor = Colors.black;

            Future<void> handleCheckIn() async {
              setStateDialog(() {
                isLoading = true;
              });

              try {
                final result = await _checkInService.checkInTicket(qrCodeValue);

                setStateDialog(() {
                  isLoading = false;
                  isChecked = true;
                  statusColor = Colors.green;

                  displayContent =
                      """
✅ CHECK-IN THÀNH CÔNG!

Khách hàng: ${result.ticketDetails?.user?.fullName ?? 'N/A'}
Sự kiện: ${result.ticketDetails?.event?.name ?? 'N/A'}
Loại vé: ${result.ticketDetails?.ticketType?.name ?? 'N/A'}
Ghế: ${result.ticketDetails?.seat?.seatNumber ?? 'Tự do'}

Thông báo: ${result.message ?? 'Hợp lệ'}
""";
                });
              } catch (e) {
                setStateDialog(() {
                  isLoading = false;
                  isChecked = true;
                  statusColor = Colors.red;
                  displayContent =
                      "❌ CHECK-IN THẤT BẠI\n\nLỗi: ${e.toString().replaceAll('Exception: ', '')}";
                });
              }
            }

            // --- GIAO DIỆN DIALOG ---
            return AlertDialog(
              title: const Text('Thông tin Check-in'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayContent,
                    style: TextStyle(
                      fontSize: 16,
                      color: statusColor,
                      fontWeight: isChecked
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              actions: [
                // Nút Check-in hoặc Loading hoặc Đóng
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.only(right: 16, bottom: 8),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else if (!isChecked)
                  ElevatedButton(
                    onPressed: handleCheckIn, // Gọi hàm check-in
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      'Check-in',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                else
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context); // Đóng Dialog
                      isDialogShowing = false;

                      // Restart camera để quét vé tiếp theo
                      await controller.stop();
                      await controller.start();
                    },
                    child: const Text('Đóng (Quét tiếp)'),
                  ),
              ],
            );
          },
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
        title: const Text(
          'Quét vé vào cửa',
          style: TextStyle(color: Colors.black),
        ),
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
                _showCheckInDialog(value);
              }
            },
          ),

          /// OVERLAY (Màn che)
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
