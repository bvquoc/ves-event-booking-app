class VoucherModel {
  final String id;
  final String code;
  final String title;
  final String? description;
  final String discountType;
  final double discountValue;
  final double minOrderAmount;
  final double maxDiscount;
  final DateTime startDate;
  final DateTime endDate;
  final int usageLimit;
  final int usedCount;
  final List<String> applicableEvents;
  final List<String> applicableCategories;
  final bool isPublic;

  VoucherModel({
    required this.id,
    required this.code,
    required this.title,
    this.description,
    required this.discountType,
    required this.discountValue,
    required this.minOrderAmount,
    required this.maxDiscount,
    required this.startDate,
    required this.endDate,
    required this.usageLimit,
    required this.usedCount,
    required this.applicableEvents,
    required this.applicableCategories,
    required this.isPublic,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: json['id'],
      code: json['code'],
      title: json['title'],
      description: json['description'],
      discountType: json['discountType'],
      discountValue: (json['discountValue'] as num).toDouble(),
      minOrderAmount: (json['minOrderAmount'] as num).toDouble(),
      maxDiscount: (json['maxDiscount'] as num).toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      usageLimit: json['usageLimit'],
      usedCount: json['usedCount'],
      applicableEvents: List<String>.from(json['applicableEvents'] ?? []),
      applicableCategories: List<String>.from(
        json['applicableCategories'] ?? [],
      ),
      isPublic: json['isPublic'],
    );
  }
}
