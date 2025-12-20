class PurchaseCancelRequest {
  final String reason;

  PurchaseCancelRequest({required this.reason});

  Map<String, dynamic> toJson() {
    return {'reason': reason};
  }
}
