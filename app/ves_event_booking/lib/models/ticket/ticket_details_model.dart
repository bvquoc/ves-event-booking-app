import 'package:ves_event_booking/models/ticket/ticket_type_model.dart'; // Import model TicketType cũ của bạn

class EventDetailsModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? longDescription;
  final String? thumbnail;
  final List<String> images;
  final DateTime startDate;
  final DateTime endDate;

  // Nested Objects (Category & City)
  final EventCategory? category;
  final EventCity? city;

  // Venue Info
  final String? venueId;
  final String? venueName;
  final String? venueAddress;

  // Organizer Info
  final String? organizerName;
  final String? organizerLogo;

  // Policy & Terms
  final String? terms;
  final String? cancellationPolicy;

  // Stats & Price
  final double? minPrice;
  final double? maxPrice;
  final int availableTickets;
  final bool isFavorite;
  final bool isTrending;
  final List<String> tags;

  final List<TicketTypeModel> ticketTypes;

  EventDetailsModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.longDescription,
    this.thumbnail,
    this.images = const [],
    required this.startDate,
    required this.endDate,
    this.category,
    this.city,
    this.venueId,
    this.venueName,
    this.venueAddress,
    this.organizerName,
    this.organizerLogo,
    this.terms,
    this.cancellationPolicy,
    this.minPrice,
    this.maxPrice,
    this.availableTickets = 0,
    this.isFavorite = false,
    this.isTrending = false,
    this.tags = const [],
    this.ticketTypes = const [],
  });

  factory EventDetailsModel.fromJson(Map<String, dynamic> json) {
    return EventDetailsModel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      longDescription: json['longDescription'],
      thumbnail: json['thumbnail'],
      images: (json['images'] as List?)?.cast<String>() ?? [],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),

      // Parse Category nested
      category: json['category'] != null
          ? EventCategory.fromJson(json['category'])
          : null,

      // Parse City nested
      city: json['city'] != null ? EventCity.fromJson(json['city']) : null,

      venueId: json['venueId'],
      venueName: json['venueName'],
      venueAddress: json['venueAddress'],

      organizerName: json['organizerName'],
      organizerLogo: json['organizerLogo'],

      terms: json['terms'],
      cancellationPolicy: json['cancellationPolicy'],

      minPrice: (json['minPrice'] as num?)?.toDouble(),
      maxPrice: (json['maxPrice'] as num?)?.toDouble(),
      availableTickets: json['availableTickets'] ?? 0,

      isFavorite: json['isFavorite'] ?? false,
      isTrending: json['isTrending'] ?? false,

      tags: (json['tags'] as List?)?.cast<String>() ?? [],

      // Map TicketTypes từ JSON sang List<TicketTypeModel>
      ticketTypes: json['ticketTypes'] != null
          ? (json['ticketTypes'] as List)
                .map((e) => TicketTypeModel.fromJson(e))
                .toList()
          : [],
    );
  }
}

class EventCategory {
  final String id;
  final String name;
  final String slug;
  final String? icon;

  EventCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
  });

  factory EventCategory.fromJson(Map<String, dynamic> json) {
    return EventCategory(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      icon: json['icon'],
    );
  }
}

class EventCity {
  final String id;
  final String name;
  final String slug;

  EventCity({required this.id, required this.name, required this.slug});

  factory EventCity.fromJson(Map<String, dynamic> json) {
    return EventCity(id: json['id'], name: json['name'], slug: json['slug']);
  }
}
