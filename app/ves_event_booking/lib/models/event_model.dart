class EventModel {
  final String id;
  final String title;
  final String imageUrl;

  EventModel({required this.id, required this.title, required this.imageUrl});
}

class MockEvents {
  final List<EventModel> mockEvents = [
    EventModel(
      id: '1',
      title: 'Thông tin về concert chị đẹp đạp gió rẽ sóng diễn ra tại quận 1',
      imageUrl: 'assets/images/event_image.jpeg',
    ),
    EventModel(
      id: '2',
      title: 'Concert những thành phố mơ màng tổ chưc ở quận Thủ Đức',
      imageUrl: 'assets/images/event_image.jpeg',
    ),
    EventModel(
      id: '3',
      title: 'EXID tổ chức FANCON ở Việt Nam tại TP.HCM vào ngày 20/12/2024',
      imageUrl: 'assets/images/event_image.jpeg',
    ),
    EventModel(
      id: '4',
      title:
          'Đại học quốc gia tổ chức sự kiện School Fest 2025 ở Kí túc xá khu B ĐHQG',
      imageUrl: 'assets/images/event_image.jpeg',
    ),
    // Add more mock events as needed
  ];

  List<EventModel> get events => mockEvents;
}
