import 'package:ves_event_booking/models/venue/venue_section_model.dart';

class VenueSeatMapModel {
  final String venueId;
  final String venueName;
  final String eventId;
  final List<VenueSectionModel> sections;

  VenueSeatMapModel({
    required this.venueId,
    required this.venueName,
    required this.eventId,
    required this.sections,
  });

  factory VenueSeatMapModel.fromJson(Map<String, dynamic> json) {
    return VenueSeatMapModel(
      venueId: json['venueId'] as String,
      venueName: json['venueName'] as String,
      eventId: json['eventId'] as String,
      sections: (json['sections'] as List)
          .map((e) => VenueSectionModel.fromJson(e))
          .toList(),
    );
  }
}
