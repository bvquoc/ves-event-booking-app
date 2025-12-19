import 'package:ves_event_booking/models/ticket_type_model.dart';

class EventModelRequest {
  final String name;
  final String slug;
  final String description;
  final String longDescription;
  final String categoryId;
  final String thumbnail;
  final List<String> images;
  final DateTime startDate;
  final DateTime endDate;
  final String cityId;
  final String venueId;
  final String venueName;
  final String venueAddress;
  final String currency;
  final bool isTrending;
  final String organizerId;
  final String organizerName;
  final String organizerLogo;
  final String terms;
  final String cancellationPolicy;
  final List<String> tags;
  final List<TicketTypeModel> ticketTypes;

  EventModelRequest({
    required this.name,
    required this.slug,
    required this.description,
    required this.longDescription,
    required this.categoryId,
    required this.thumbnail,
    required this.images,
    required this.startDate,
    required this.endDate,
    required this.cityId,
    required this.venueId,
    required this.venueName,
    required this.venueAddress,
    required this.currency,
    required this.isTrending,
    required this.organizerId,
    required this.organizerName,
    required this.organizerLogo,
    required this.terms,
    required this.cancellationPolicy,
    required this.tags,
    required this.ticketTypes,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'slug': slug,
      'description': description,
      'longDescription': longDescription,
      'categoryId': categoryId,
      'thumbnail': thumbnail,
      'images': images,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'cityId': cityId,
      'venueId': venueId,
      'venueName': venueName,
      'venueAddress': venueAddress,
      'currency': currency,
      'isTrending': isTrending,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'organizerLogo': organizerLogo,
      'terms': terms,
      'cancellationPolicy': cancellationPolicy,
      'tags': tags,
      'ticketTypes': ticketTypes.map((e) => e.toJson()).toList(),
    };
  }
}
