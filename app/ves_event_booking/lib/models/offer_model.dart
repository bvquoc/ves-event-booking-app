class OfferModel {
  final String id;
  final String title;
  final String imageUrl;

  OfferModel({required this.id, required this.title, required this.imageUrl});
}

class MockOffers {
  final List<OfferModel> mockOffers = [
    OfferModel(
      id: '1',
      title: 'Mở thẻ liền tay thả ga sự kiện',
      imageUrl: 'assets/images/event_image.jpeg',
    ),
    OfferModel(
      id: '2',
      title:
          'Dịch vụ ăn uống ưu đãi trong Concert Anh Trai Vượt Ngàn Chông Gai',
      imageUrl: 'assets/images/event_image.jpeg',
    ),
    OfferModel(
      id: '3',
      title:
          'Ưu đãi đặc quyền khi thanh toán bằng Visa, đối tác thanh toán chính thức',
      imageUrl: 'assets/images/event_image.jpeg',
    ),
    OfferModel(
      id: '4',
      title:
          'Thanh toán vé NTPMM Year End Party 2024 bằng ví trả sau nhận ưu đãi hấp dẫn',
      imageUrl: 'assets/images/event_image.jpeg',
    ),
    // Add more mock events as needed
  ];

  List<OfferModel> get offers => mockOffers;
}
