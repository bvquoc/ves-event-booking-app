enum CancelStatus { requested, processing, completed }

class CancelledTicketModel {
  final String id;
  final String eventName;
  final String imageUrl;
  final CancelStatus status;
  final DateTime requestDate;
  final DateTime? processingDate; // Can null
  final DateTime? completedDate; // Can null

  CancelledTicketModel({
    required this.id,
    required this.eventName,
    required this.imageUrl,
    required this.status,
    required this.requestDate,
    this.processingDate,
    this.completedDate,
  });
}

class MockCancelledTickets {
  final List<CancelledTicketModel> mockCancelledTickets = [
    CancelledTicketModel(
      id: '1',
      eventName: 'School Fest',
      imageUrl: 'assets/images/event_image.jpeg',
      status: CancelStatus.requested, // Tới bước 1
      requestDate: DateTime(2024, 4, 12),
      processingDate: null,
      completedDate: null,
    ),
    CancelledTicketModel(
      id: '2',
      eventName: 'Concert Anh Trai "Say Hi"',
      imageUrl: 'assets/images/event_image.jpeg',
      status: CancelStatus.processing, // Tới bước 2
      requestDate: DateTime(2024, 9, 15),
      processingDate: DateTime(2024, 9, 15), // Đang xử lý
      completedDate: null,
    ),
    CancelledTicketModel(
      id: '3',
      eventName: 'Anh Trai Vượt Ngàn Chông Gai',
      imageUrl: 'assets/images/event_image.jpeg',
      status: CancelStatus.completed, // Bước 3 hoàn tất
      requestDate: DateTime(2024, 6, 4),
      processingDate: DateTime(2024, 7, 4),
      completedDate: DateTime(2024, 8, 4), // Hoàn tất
    ),
  ];

  List<CancelledTicketModel> get cancelledTickets => mockCancelledTickets;
}
