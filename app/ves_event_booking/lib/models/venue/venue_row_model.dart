import 'package:ves_event_booking/models/venue/venue_seat_model.dart';

class VenueRowModel {
  final String rowName;
  final List<VenueSeatModel> seats;

  VenueRowModel({required this.rowName, required this.seats});

  factory VenueRowModel.fromJson(Map<String, dynamic> json) {
    return VenueRowModel(
      rowName: json['rowName'] as String,
      seats: (json['seats'] as List)
          .map((e) => VenueSeatModel.fromJson(e))
          .toList(),
    );
  }
}
