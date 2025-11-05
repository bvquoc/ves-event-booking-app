class EventModel {
  final String id;
  final String eventName;
  final String locationTag;
  final String imageUrl;
  final DateTime eventDate;
  final bool isFavorite;

  EventModel({
    required this.id,
    required this.eventName,
    required this.locationTag,
    required this.imageUrl,
    required this.eventDate,
    this.isFavorite = false,
  });
}

class MockEvents {
  final List<EventModel> mockEvents = [
    EventModel(
      id: '1',
      eventName: 'Van Gogh',
      locationTag: 'Quận 12',
      imageUrl: 'assets/images/event_image.jpeg',
      eventDate: DateTime(2025, 3, 3, 22, 20), // Thg3, 03, 22:20
    ),
    EventModel(
      id: '2',
      eventName: 'School Fest 2024',
      locationTag: 'Quận Thủ Đức',
      imageUrl: 'assets/images/event_image.jpeg',
      eventDate: DateTime(2025, 6, 15, 17, 30), // Thg6, 15, 17:30
    ),
    EventModel(
      id: '3',
      eventName: 'Anh Trai "Say Hi"',
      locationTag: 'Quận 7',
      imageUrl: 'assets/images/event_image.jpeg',
      eventDate: DateTime(2025, 9, 1, 18, 0), // Thg9, 01, 18:00
    ),
    EventModel(
      id: '4',
      eventName: 'Alan Walker Live',
      locationTag: 'Quận 2',
      imageUrl: 'assets/images/event_image.jpeg',
      eventDate: DateTime(2025, 10, 30, 18, 30), // Thg10, 30, 18:30
    ),
    // Add more mock events as needed
  ];

  List<EventModel> get events => mockEvents;
}
