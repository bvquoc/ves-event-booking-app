import 'package:ves_event_booking/models/voucher/voucher_model.dart';

class VoucherStatusModel {
  final String id;
  final VoucherModel voucher;
  final bool isUsed;
  final DateTime? usedAt;
  final String? orderId;
  final DateTime addedAt;

  VoucherStatusModel({
    required this.id,
    required this.voucher,
    required this.isUsed,
    this.usedAt,
    this.orderId,
    required this.addedAt,
  });

  factory VoucherStatusModel.fromJson(Map<String, dynamic> json) {
    return VoucherStatusModel(
      id: json['id'],
      voucher: VoucherModel.fromJson(json['voucher']),
      isUsed: json['isUsed'],
      usedAt: json['usedAt'] != null ? DateTime.parse(json['usedAt']) : null,
      orderId: json['orderId'],
      addedAt: DateTime.parse(json['addedAt']),
    );
  }
}
