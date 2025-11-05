import 'dart:math' as math;
import 'package:flutter/material.dart';

class TicketClipper extends CustomClipper<Path> {
  // Bán kính của các góc bo
  final double borderRadius;
  // Bán kính của mỗi lỗ "lượn sóng"
  final double scallopRadius;

  TicketClipper({this.borderRadius = 17.0, this.scallopRadius = 10.0});

  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;
    final path = Path();

    // 1. Bắt đầu từ góc trên bên trái (sau khi bo góc)
    path.moveTo(borderRadius, 0);

    // 2. Kẻ cạnh trên
    path.lineTo(width - borderRadius, 0);

    // 3. Bo góc trên bên phải
    path.quadraticBezierTo(width, 0, width, borderRadius);

    // 4. --- VẼ CẠNH PHẢI LƯỢN SÓNG ---
    // Bắt đầu từ điểm Y = bán kính bo góc
    var currentY = borderRadius;
    final scallopDiameter = scallopRadius * 2;

    // Vòng lặp: Vẽ liên tục các vết cắt cho đến khi gần hết
    while (currentY + scallopDiameter < height - borderRadius) {
      path.lineTo(width, currentY); // Di chuyển đến điểm bắt đầu arc

      // Vẽ một cung lõm vào
      path.arcTo(
        Rect.fromCircle(
          center: Offset(width, currentY + scallopRadius),
          radius: scallopRadius,
        ),
        math.pi * 1.5, // 270 độ (bắt đầu từ trên)
        -math.pi, // Quét -180 độ (lõm vào)
        false,
      );
      // Cập nhật vị trí Y cho vòng lặp tiếp theo
      currentY += scallopDiameter + 10;
    }
    // Kẻ đường thẳng cuối cùng đến góc dưới
    path.lineTo(width, height - borderRadius);

    // 5. Bo góc dưới bên phải
    path.quadraticBezierTo(width, height, width - borderRadius, height);

    // 6. Kẻ cạnh dưới
    path.lineTo(borderRadius, height);

    // 7. Bo góc dưới bên trái
    path.quadraticBezierTo(0, height, 0, height - borderRadius);

    // 8. --- VẼ CẠNH TRÁI LƯỢN SÓNG (Ngược lại) ---
    // Bắt đầu từ điểm Y = chiều cao - bán kính bo góc
    currentY = height - borderRadius;

    // Vòng lặp: Vẽ ngược từ dưới lên trên
    while (currentY - scallopDiameter > borderRadius) {
      path.lineTo(0, currentY); // Di chuyển đến điểm bắt đầu arc

      // Vẽ một cung lõm vào
      path.arcTo(
        Rect.fromCircle(
          center: Offset(0, currentY - scallopRadius),
          radius: scallopRadius,
        ),
        math.pi * 0.5, // 90 độ (bắt đầu từ dưới)
        -math.pi, // Quét -180 độ (lõm vào)
        false,
      );
      // Cập nhật Y
      currentY -= scallopDiameter + 10;
    }
    // Kẻ đường thẳng cuối cùng đến góc trên
    path.lineTo(0, borderRadius);

    // 9. Bo góc trên bên trái
    path.quadraticBezierTo(0, 0, borderRadius, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return oldClipper.hashCode != hashCode;
  }
}
