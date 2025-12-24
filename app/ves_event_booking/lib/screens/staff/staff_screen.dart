import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ves_event_booking/providers/user_provider.dart';
import 'package:ves_event_booking/screens/login_screen.dart';
import 'package:ves_event_booking/services/check_in_service.dart';
import 'package:provider/provider.dart';

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

  void _showCheckInDialog(String qrCodeValue) async {
    isDialogShowing = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return CheckInDialog(
          qrCode: qrCodeValue,
          checkInService: _checkInService,
        );
      },
    );

    isDialogShowing = false;

    if (mounted) {
      await controller.stop();
      await controller.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, _) {
        // ⏳ Loading
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // ❌ Error
        if (provider.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(provider.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
            provider.clearError(); // VERY IMPORTANT
          });
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () async {
                await provider.logout();
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                }
              },
            ),
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
      },
    );
  }
}

class CheckInDialog extends StatefulWidget {
  final String qrCode;
  final CheckInService checkInService;

  const CheckInDialog({
    super.key,
    required this.qrCode,
    required this.checkInService,
  });

  @override
  State<CheckInDialog> createState() => _CheckInDialogState();
}

class _CheckInDialogState extends State<CheckInDialog> {
  bool isLoading = false;
  bool isChecked = false;
  late String displayContent;
  Color statusColor = Colors.black;

  @override
  void initState() {
    super.initState();
    displayContent = "Mã vé: ${widget.qrCode}";
  }

  Future<void> handleCheckIn() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await widget.checkInService.checkInTicket(widget.qrCode);

      if (!mounted) return;

      setState(() {
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
      if (!mounted) return;

      // Cập nhật UI: Thất bại
      setState(() {
        isLoading = false;
        isChecked = true;
        statusColor = Colors.red;
        displayContent =
            "❌ CHECK-IN THẤT BẠI\n\nLỗi: ${e.toString().replaceAll('Exception: ', '')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thông tin Check-in'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayContent,
              style: TextStyle(
                fontSize: 16,
                color: statusColor,
                fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      actions: [
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
            onPressed: handleCheckIn,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text(
              'Check-in ngay',
              style: TextStyle(color: Colors.white),
            ),
          )
        else
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Đóng (Quét tiếp)'),
          ),
      ],
    );
  }
}
