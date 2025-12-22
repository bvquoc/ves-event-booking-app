import 'package:ves_event_booking/models/category/category_model.dart';
import 'package:ves_event_booking/models/city/city_model.dart';
import 'package:ves_event_booking/models/ticket/ticket_type_model.dart';
import 'package:ves_event_booking/models/venue/venue_seat_map_model.dart';

class EventModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? longDescription;
  final String? thumbnail;
  final List<String>? images;

  final DateTime startDate;
  final DateTime endDate;

  final CategoryModel? category;
  final CityModel? city;

  final String? venueId;
  final VenueSeatMapModel? venue;
  final String? venueName;
  final String? venueAddress;

  final String? currency;
  final bool? isTrending;

  final String? organizerId;
  final String? organizerName;
  final String? organizerLogo;

  final String? terms;
  final String? cancellationPolicy;

  final List<String>? tags;
  final List<TicketTypeModel>? ticketTypes;

  final double? minPrice;
  final double? maxPrice;
  final int? availableTickets;

  final bool? isFavorite;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  EventModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.longDescription,
    this.thumbnail,
    this.images,
    required this.startDate,
    required this.endDate,
    this.category,
    this.city,
    this.venueId,
    this.venue,
    this.venueName,
    this.venueAddress,
    this.currency,
    this.isTrending,
    this.organizerId,
    this.organizerName,
    this.organizerLogo,
    this.terms,
    this.cancellationPolicy,
    this.tags,
    this.ticketTypes,
    this.minPrice,
    this.maxPrice,
    this.availableTickets,
    this.isFavorite,
    this.createdAt,
    this.updatedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      longDescription: json['longDescription'],
      thumbnail: json['thumbnail'],
      images: (json['images'] as List?)?.cast<String>(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'])
          : null,
      city: json['city'] != null ? CityModel.fromJson(json['city']) : null,
      venueId: json['venueId'],
      venue: json['venue'] != null
          ? VenueSeatMapModel.fromJson(json['venue'])
          : null,
      venueName: json['venueName'],
      venueAddress: json['venueAddress'],
      currency: json['currency'],
      isTrending: json['isTrending'],
      organizerId: json['organizerId'],
      organizerName: json['organizerName'],
      organizerLogo: json['organizerLogo'],
      terms: json['terms'],
      cancellationPolicy: json['cancellationPolicy'],
      tags: (json['tags'] as List?)?.cast<String>(),
      ticketTypes: (json['ticketTypes'] as List?)
          ?.map((e) => TicketTypeModel.fromJson(e))
          .toList(),
      minPrice: (json['minPrice'] as num?)?.toDouble(),
      maxPrice: (json['maxPrice'] as num?)?.toDouble(),
      availableTickets: json['availableTickets'],
      isFavorite: json['isFavorite'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  EventModel copyWith({
    String? id,
    String? name,
    String? slug,
    String? description,
    String? longDescription,
    String? thumbnail,
    List<String>? images,
    DateTime? startDate,
    DateTime? endDate,
    CategoryModel? category,
    CityModel? city,
    String? venueId,
    VenueSeatMapModel? venue,
    String? venueName,
    String? venueAddress,
    String? currency,
    bool? isTrending,
    String? organizerId,
    String? organizerName,
    String? organizerLogo,
    String? terms,
    String? cancellationPolicy,
    List<String>? tags,
    List<TicketTypeModel>? ticketTypes,
    double? minPrice,
    double? maxPrice,
    int? availableTickets,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      longDescription: longDescription ?? this.longDescription,
      thumbnail: thumbnail ?? this.thumbnail,
      images: images ?? this.images,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      category: category ?? this.category,
      city: city ?? this.city,
      venueId: venueId ?? this.venueId,
      venue: venue ?? this.venue,
      venueName: venueName ?? this.venueName,
      venueAddress: venueAddress ?? this.venueAddress,
      currency: currency ?? this.currency,
      isTrending: isTrending ?? this.isTrending,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      organizerLogo: organizerLogo ?? this.organizerLogo,
      terms: terms ?? this.terms,
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
      tags: tags ?? this.tags,
      ticketTypes: ticketTypes ?? this.ticketTypes,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      availableTickets: availableTickets ?? this.availableTickets,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
