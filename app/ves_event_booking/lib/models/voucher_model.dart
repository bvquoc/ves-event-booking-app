class VoucherModel {
  final String id;
  final String code;
  final String title;
  final String description;
  final String discountType; // fixed_amount, percentage
  final double discountValue;
  final double minOrderAmount;
  final DateTime startDate;
  final DateTime endDate;
  final bool? isUsed; // Chỉ có ở endpoint 'my-vouchers'

  VoucherModel({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.minOrderAmount,
    required this.startDate,
    required this.endDate,
    this.isUsed,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: json['id'] as String,
      code: json['code'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      discountType: json['discountType'] as String,
      discountValue: (json['discountValue'] as num).toDouble(),
      minOrderAmount: (json['minOrderAmount'] as num).toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isUsed: json['isUsed'] as bool?,
    );
  }
}
