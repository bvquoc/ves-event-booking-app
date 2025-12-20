// lib/models/ticket_type_model.dart

class TicketTypeModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final int available;
  final int maxPerOrder;
  final List<String> benefits;
  final bool requiresSeatSelection;

  TicketTypeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.available,
    required this.maxPerOrder,
    required this.benefits,
    required this.requiresSeatSelection,
  });

  factory TicketTypeModel.fromJson(Map<String, dynamic> json) {
    return TicketTypeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      available: json['available'] as int,
      maxPerOrder: json['maxPerOrder'] as int,
      benefits: json['benefits'] != null
          ? List<String>.from(json['benefits'])
          : [],
      requiresSeatSelection: json['requiresSeatSelection'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
