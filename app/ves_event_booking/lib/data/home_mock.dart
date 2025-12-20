import '../models/event_model.dart';

final mockEvents = [
  EventModel(
    id: 'evt_1',
    name: 'School Fest 2024',
    slug: 'school-fest-2024',
    description: '',
    category: 'concert',
    thumbnail: 'assets/images/image 106.png',
    startDate: DateTime(2024, 11, 16),
    city: 'Ho Chi Minh',
    venueName: 'Nhà thi đấu',
    minPrice: 250000,
    maxPrice: 500000,
    currency: 'VND',
    availableTickets: 200,
  ),
  EventModel(
    id: 'evt_2',
    name: 'Anh Trai Vượt Ngàn Chông Gai',
    slug: 'anh-trai',
    description: '',
    category: 'concert',
    thumbnail: 'assets/images/image 106.png',
    startDate: DateTime(2024, 11, 16),
    city: 'Ho Chi Minh',
    venueName: 'Nhà hát',
    minPrice: 250000,
    maxPrice: 500000,
    currency: 'VND',
    availableTickets: 150,
  ),
];
