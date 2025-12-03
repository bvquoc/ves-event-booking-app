import 'ticket_type_model.dart';
import 'organizer_model.dart';

class EventModel {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String? longDescription; // Nullable vì List API không trả về
  final String category;
  final String thumbnail;
  final List<String>? images; // Nullable

  // Thời gian
  final DateTime startDate;
  final DateTime? endDate;

  // Địa điểm
  final String city;
  final String? venueId;
  final String venueName;
  final String? venueAddress; // Nullable
  final int? venueCapacity; // Nullable

  // Giá & Vé
  final double minPrice;
  final double maxPrice;
  final String currency;
  final int availableTickets;
  final List<TicketTypeModel>? ticketTypes; // List chi tiết loại vé

  // Trạng thái
  final bool isTrending;
  final bool isFavorite;

  // Thông tin bổ sung
  final OrganizerModel? organizer;
  final String? terms;
  final String? cancellationPolicy;
  final List<String>? tags;

  EventModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    this.longDescription,
    required this.category,
    required this.thumbnail,
    this.images,
    required this.startDate,
    this.endDate,
    required this.city,
    this.venueId,
    required this.venueName,
    this.venueAddress,
    this.venueCapacity,
    required this.minPrice,
    required this.maxPrice,
    required this.currency,
    required this.availableTickets,
    this.ticketTypes,
    this.isTrending = false,
    this.isFavorite = false,
    this.organizer,
    this.terms,
    this.cancellationPolicy,
    this.tags,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String,
      longDescription: json['longDescription'] as String?,
      category: json['category'] as String,
      thumbnail: json['thumbnail'] as String,
      images: json['images'] != null ? List<String>.from(json['images']) : null,

      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,

      city: json['city'] as String,
      venueId: json['venueId'] as String?,
      venueName: json['venueName'] as String,
      venueAddress: json['venueAddress'] as String?,
      venueCapacity: json['venueCapacity'] as int?,

      minPrice: (json['minPrice'] as num).toDouble(),
      maxPrice: (json['maxPrice'] as num).toDouble(),
      currency: json['currency'] as String,
      availableTickets: json['availableTickets'] as int? ?? 0,

      // Parse list ticket types
      ticketTypes: json['ticketTypes'] != null
          ? (json['ticketTypes'] as List)
                .map((e) => TicketTypeModel.fromJson(e))
                .toList()
          : null,

      isTrending: json['isTrending'] ?? false,
      isFavorite: json['isFavorite'] ?? false,

      organizer: json['organizer'] != null
          ? OrganizerModel.fromJson(json['organizer'])
          : null,

      terms: json['terms'] as String?,
      cancellationPolicy: json['cancellationPolicy'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }
}
