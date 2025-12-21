import 'package:ves_event_booking/models/voucher/voucher_model.dart';

class VoucherValidateModel {
  final bool isValid;
  final String message;
  final double orderAmount;
  final double discountAmount;
  final double finalAmount;
  final VoucherModel? voucher;

  VoucherValidateModel({
    required this.isValid,
    required this.message,
    required this.orderAmount,
    required this.discountAmount,
    required this.finalAmount,
    this.voucher,
  });

  factory VoucherValidateModel.fromJson(Map<String, dynamic> json) {
    return VoucherValidateModel(
      isValid: json['isValid'],
      message: json['message'],
      orderAmount: (json['orderAmount'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      finalAmount: (json['finalAmount'] as num).toDouble(),
      voucher: json['voucher'] != null
          ? VoucherModel.fromJson(json['voucher'])
          : null,
    );
  }
}
