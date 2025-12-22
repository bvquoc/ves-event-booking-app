class TicketTypeModel {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String currency;
  final int available;
  final int maxPerOrder;
  final List<String>? benefits;
  final bool requiresSeatSelection;

  TicketTypeModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.currency,
    required this.available,
    required this.maxPerOrder,
    this.benefits,
    required this.requiresSeatSelection,
  });

  factory TicketTypeModel.fromJson(Map<String, dynamic> json) {
    return TicketTypeModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      currency: json['currency'],
      available: json['available'],
      maxPerOrder: json['maxPerOrder'],
      benefits: (json['benefits'] as List?)?.cast<String>(),
      requiresSeatSelection: json['requiresSeatSelection'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'available': available,
      'maxPerOrder': maxPerOrder,
      'benefits': benefits,
      'requiresSeatSelection': requiresSeatSelection,
    };
  }
}
