import 'package:ves_event_booking/models/category/category_model.dart';
import 'package:ves_event_booking/models/city/city_model.dart';
import 'package:ves_event_booking/models/ticket/ticket_type_model.dart';
import 'package:ves_event_booking/models/venue/venue_model.dart';

class EventModel {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String? longDescription;
  final String thumbnail;
  final List<String> images;
  final DateTime startDate;
  final DateTime endDate;
  final CategoryModel category;
  final CityModel city;
  final VenueModel? venue;
  final String venueId;
  final String venueName;
  final String venueAddress;
  final String currency;
  final bool isTrending;
  final String organizerId;
  final String organizerName;
  final String organizerLogo;
  final String? terms;
  final String? cancellationPolicy;
  final List<String> tags;
  final List<TicketTypeModel> ticketTypes;
  final double minPrice;
  final double maxPrice;
  final int availableTickets;
  final bool isFavorite;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  EventModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    this.longDescription,
    required this.thumbnail,
    required this.images,
    required this.startDate,
    required this.endDate,
    required this.category,
    required this.city,
    this.venue,
    required this.venueId,
    required this.venueName,
    required this.venueAddress,
    required this.currency,
    required this.isTrending,
    required this.organizerId,
    required this.organizerName,
    required this.organizerLogo,
    this.terms,
    this.cancellationPolicy,
    required this.tags,
    required this.ticketTypes,
    required this.minPrice,
    required this.maxPrice,
    required this.availableTickets,
    required this.isFavorite,
    this.createdAt,
    this.updatedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    List<TicketTypeModel> temp = [];

    return EventModel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      longDescription: json['longDescription'],
      thumbnail: json['thumbnail'],
      images: List<String>.from(json['images']),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      category: CategoryModel.fromJson(json['category']),
      city: CityModel.fromJson(json['city']),
      venueId: json['venueId'],
      venue: VenueModel.fromJson(json['venue']),
      venueName: json['venueName'],
      venueAddress: json['venueAddress'],
      currency: json['currency'],
      isTrending: json['isTrending'],
      organizerId: json['organizerId'],
      organizerName: json['organizerName'],
      organizerLogo: json['organizerLogo'],
      terms: json['terms'],
      cancellationPolicy: json['cancellationPolicy'],
      tags: List<String>.from(json['tags']),
      ticketTypes: json['ticketTypes'] != null
          ? (json['ticketTypes'] as List)
                .map((e) => TicketTypeModel.fromJson(e))
                .toList()
          : temp,
      minPrice: (json['minPrice'] as num).toDouble(),
      maxPrice: (json['maxPrice'] as num).toDouble(),
      availableTickets: json['availableTickets'],
      isFavorite: json['isFavorite'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
