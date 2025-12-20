import 'package:ves_event_booking/models/venue/venue_row_model.dart';

class VenueSectionModel {
  final String sectionName;
  final List<VenueRowModel> rows;

  VenueSectionModel({required this.sectionName, required this.rows});

  factory VenueSectionModel.fromJson(Map<String, dynamic> json) {
    return VenueSectionModel(
      sectionName: json['sectionName'] as String,
      rows: (json['rows'] as List)
          .map((e) => VenueRowModel.fromJson(e))
          .toList(),
    );
  }
}
