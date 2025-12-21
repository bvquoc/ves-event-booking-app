import 'package:ves_event_booking/models/event/event_model.dart';
import 'package:ves_event_booking/models/category/category_model.dart';
import 'package:ves_event_booking/models/city/city_model.dart';
import 'package:ves_event_booking/models/venue/venue_model.dart';
import 'package:ves_event_booking/models/ticket/ticket_type_model.dart';

/// =====================
/// Mock base data
/// =====================

final hoChiMinhCity = CityModel(
  id: 'city_hcm',
  name: 'Ho Chi Minh',
  slug: 'ho-chi-minh',
  eventCount: 10,
);

final concertCategory = CategoryModel(
  id: 'cat_concert',
  name: 'Concert',
  slug: 'concert',
  icon: '🎵',
  eventCount: 12,
);

final nhaThiDauVenue = VenueModel(
  id: 'venue_1',
  name: 'Nhà thi đấu Phú Thọ',
  address: '221 Lý Thường Kiệt, Quận 11',
  capacity: 5000,
  city: hoChiMinhCity,
);

final nhaHatVenue = VenueModel(
  id: 'venue_2',
  name: 'Nhà hát Hòa Bình',
  address: '240 Đường 3/2, Quận 10',
  capacity: 3000,
  city: hoChiMinhCity,
);

/// =====================
/// Ticket Types
/// =====================

final vipTicket = TicketTypeModel(
  id: 'ticket_vip',
  name: 'VIP',
  description: 'Vé VIP, khu vực gần sân khấu',
  price: 500000,
  currency: 'VND',
  available: 100,
  maxPerOrder: 4,
  benefits: ['Vị trí đẹp', 'Check-in riêng', 'Quà lưu niệm'],
  requiresSeatSelection: true,
);

final standardTicket = TicketTypeModel(
  id: 'ticket_standard',
  name: 'Standard',
  description: 'Vé tiêu chuẩn',
  price: 250000,
  currency: 'VND',
  available: 300,
  maxPerOrder: 6,
  benefits: ['Vào cổng tiêu chuẩn'],
  requiresSeatSelection: false,
);

/// =====================
/// Mock Events
/// =====================

final List<EventModel> mockEvents = [
  EventModel(
    id: 'evt_1',
    name: 'School Fest 2024',
    slug: 'school-fest-2024',
    description: 'Lễ hội âm nhạc dành cho học sinh – sinh viên',
    longDescription:
        'School Fest 2024 là lễ hội âm nhạc sôi động với sự góp mặt của nhiều nghệ sĩ trẻ nổi tiếng.',
    thumbnail: 'assets/images/image 106.png',
    images: ['assets/images/image 106.png', 'assets/images/image_107.png'],
    startDate: DateTime(2024, 11, 16, 18, 0),
    endDate: DateTime(2024, 11, 16, 22, 0),
    category: concertCategory,
    city: hoChiMinhCity,
    venueId: nhaThiDauVenue.id,
    venue: nhaThiDauVenue,
    venueName: nhaThiDauVenue.name,
    venueAddress: nhaThiDauVenue.address,
    currency: 'VND',
    isTrending: true,
    organizerId: 'org_1',
    organizerName: 'VES Entertainment',
    organizerLogo: 'assets/images/logo.png',
    terms: 'Không hoàn tiền sau khi mua vé.',
    cancellationPolicy: 'Hủy trước 48 giờ để được hoàn tiền 50%.',
    tags: ['music', 'festival', 'student'],
    ticketTypes: [vipTicket, standardTicket],
    minPrice: 250000,
    maxPrice: 500000,
    availableTickets: 400,
    isFavorite: false,
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
    updatedAt: DateTime.now(),
  ),

  EventModel(
    id: 'evt_2',
    name: 'Anh Trai Vượt Ngàn Chông Gai',
    slug: 'anh-trai-vuot-ngan-chong-gai',
    description: 'Concert chủ đề truyền cảm hứng',
    longDescription:
        'Một đêm nhạc đầy cảm xúc với các ca khúc truyền cảm hứng về hành trình vượt khó.',
    thumbnail: 'assets/images/image 106.png',
    images: ['assets/images/image_108.png', 'assets/images/image_109.png'],
    startDate: DateTime(2024, 11, 20, 19, 0),
    endDate: DateTime(2024, 11, 20, 22, 30),
    category: concertCategory,
    city: hoChiMinhCity,
    venueId: nhaHatVenue.id,
    venue: nhaHatVenue,
    venueName: nhaHatVenue.name,
    venueAddress: nhaHatVenue.address,
    currency: 'VND',
    isTrending: false,
    organizerId: 'org_2',
    organizerName: 'Galaxy Music',
    organizerLogo: 'assets/images/galaxy_logo.png',
    terms: 'Vé đã mua không được đổi trả.',
    cancellationPolicy: 'Không hỗ trợ hủy vé.',
    tags: ['concert', 'inspiration'],
    ticketTypes: [vipTicket, standardTicket],
    minPrice: 250000,
    maxPrice: 500000,
    availableTickets: 300,
    isFavorite: true,
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    updatedAt: DateTime.now(),
  ),
];
