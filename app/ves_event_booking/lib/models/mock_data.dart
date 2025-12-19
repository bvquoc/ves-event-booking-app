import 'package:ves_event_booking/models/venue_model.dart';

import '../models/event_model.dart';
import '../models/organizer_model.dart';
import '../models/ticket_model.dart';
import '../models/ticket_type_model.dart';
import '../models/notification_model.dart';
import '../models/category_model.dart';
import '../models/city_model.dart';

// Data after change models
final CategoryModel _mockCategory = CategoryModel(
  id: '58842857-6151-4586-b056-8a881b5a9951',
  name: 'Hòa nhạc',
  slug: 'hoa-nhac',
  icon: 'music_note',
  eventCount: 12,
);

final CityModel _mockCity = CityModel(
  id: 'c1a2b3d4-5678-90ab-cdef-1234567890ab',
  name: 'TP. Hồ Chí Minh',
  slug: 'tp-ho-chi-minh',
  eventCount: 24,
);

// ==========================================
// 1. DATA PHỤ TRỢ (Organizer, TicketType)
// ==========================================

final OrganizerModel _mockOrganizer = OrganizerModel(
  id: 'org_001',
  name: 'Viet Event Corp',
  logo: 'https://i.pravatar.cc/150?u=org_001',
);

// Các loại vé mẫu
final TicketTypeModel _typeVip = TicketTypeModel(
  id: 'tt_vip',
  name: 'VIP TICKET',
  description: 'Ghế ngồi gần sân khấu, lối đi riêng',
  price: 2500000,
  currency: 'VND',
  available: 10,
  maxPerOrder: 4,
  benefits: ['Check-in ưu tiên', 'Tặng nước uống', 'Gần sân khấu'],
  requiresSeatSelection: true,
);

final TicketTypeModel _typeStandard = TicketTypeModel(
  id: 'tt_std',
  name: 'STANDARD',
  description: 'Vé tiêu chuẩn, chỗ ngồi tự chọn',
  price: 800000,
  currency: 'VND',
  available: 100,
  maxPerOrder: 10,
  benefits: ['Vào cửa tự do'],
  requiresSeatSelection: false,
);

// ==========================================
// 2. MOCK EVENTS (Sự kiện)
// ==========================================

final EventModel _mockEvent = EventModel(
  id: 'evt-001',
  name: 'Live Concert 2025',
  slug: 'live-concert-2025',
  description: 'A spectacular live music concert.',
  longDescription:
      'Experience an unforgettable night with top artists, live band performances, and amazing sound systems.',
  thumbnail: 'https://example.com/images/event-thumbnail.jpg',
  images: [
    'https://example.com/images/event-1.jpg',
    'https://example.com/images/event-2.jpg',
  ],
  startDate: DateTime.parse('2025-06-20T19:00:00Z'),
  endDate: DateTime.parse('2025-06-20T22:00:00Z'),

  category: CategoryModel(
    id: 'cat-001',
    name: 'Hòa nhạc',
    slug: 'hoa-nhac',
    icon: 'music_note',
    eventCount: 12,
  ),

  city: CityModel(
    id: 'city-001',
    name: 'TP. Hồ Chí Minh',
    slug: 'tp-ho-chi-minh',
    eventCount: 24,
  ),

  venueId: 'venue-001',
  venue: VenueModel(
    name: 'Saigon Opera House',
    address: '07 Công Trường Lam Sơn, Quận 1',
    capacity: 1800,
    cityId: 'city-001',
  ),

  venueName: 'Saigon Opera House',
  venueAddress: '07 Công Trường Lam Sơn, Quận 1',
  currency: 'VND',
  isTrending: true,

  organizerId: 'org-001',
  organizerName: 'VES Entertainment',
  organizerLogo: 'https://example.com/images/org-logo.png',

  terms: 'No late entry allowed.',
  cancellationPolicy: 'Tickets are non-refundable.',
  tags: ['concert', 'live-music', '2025'],

  ticketTypes: [
    TicketTypeModel(
      id: 'ticket-001',
      name: 'VIP',
      description: 'Front row seating with complimentary drinks',
      price: 1500000,
      currency: 'VND',
      available: 50,
      maxPerOrder: 4,
      benefits: ['Free drink', 'Backstage access'],
      requiresSeatSelection: true,
    ),
  ],

  minPrice: 500000,
  maxPrice: 1500000,
  availableTickets: 500,
  isFavorite: false,

  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

// ==========================================
// 3. MOCK TICKETS (Vé) - Dữ liệu chính để test UI
// ==========================================

// --- List 1: UPCOMING TICKETS (Vé sắp tới - Status: active) ---
final List<TicketModel> mockUpcomingTickets = [
  TicketModel(
    id: 'tkt_up_01',
    orderId: 'ord_001',
    event: _mockEvent,
    ticketType: _typeVip,
    qrCode: 'QR_UPCOMING_01',
    status: 'active',
    purchaseDate: DateTime.now().subtract(const Duration(days: 2)),
    seatNumber: 'A-12',
  ),
  TicketModel(
    id: 'tkt_up_02',
    orderId: 'ord_001',
    event: _mockEvent,
    ticketType: _typeVip,
    qrCode: 'QR_UPCOMING_02',
    status: 'active',
    purchaseDate: DateTime.now().subtract(const Duration(days: 2)),
    seatNumber: 'A-13',
  ),
  TicketModel(
    id: 'tkt_up_03',
    orderId: 'ord_001', // Cùng 1 đơn hàng mua 3 vé
    event: _mockEvent,
    ticketType: _typeVip,
    qrCode: 'QR_UPCOMING_03',
    status: 'active',
    purchaseDate: DateTime.now().subtract(const Duration(days: 2)),
    seatNumber: 'A-14',
  ),
];

// --- List 2: PAST TICKETS (Vé đã qua/đã dùng - Status: used/completed) ---
final List<TicketModel> mockPastTickets = [
  TicketModel(
    id: 'tkt_past_01',
    orderId: 'ord_old_01',
    event: _mockEvent,
    ticketType: _typeStandard,
    qrCode: 'QR_PAST_01',
    status: 'used', // Đã sử dụng
    purchaseDate: DateTime.now().subtract(const Duration(days: 35)),
    seatNumber: null, // Vé đứng/tự do
    checkedInAt: _mockEvent.startDate.add(const Duration(minutes: 15)),
  ),
];

// --- List 3: CANCELLED TICKETS (Vé đã hủy - Status: cancelled) ---
final List<TicketModel> mockCancelledTickets = [
  TicketModel(
    id: 'tkt_cancel_01',
    orderId: 'ord_cancel_01',
    event: _mockEvent, // Hủy vé của sự kiện tương lai
    ticketType: _typeStandard,
    qrCode: 'QR_CANCEL_01',
    status: 'cancelled',
    purchaseDate: DateTime.now().subtract(const Duration(days: 5)),
    seatNumber: 'C-05',
    cancellationReason: 'Bận việc đột xuất',
    refundAmount: 720000, // Hoàn 90%
    refundStatus: 'completed',
  ),
];

// --- TỔNG HỢP ---
final List<TicketModel> allMockTickets = [
  ...mockUpcomingTickets,
  ...mockPastTickets,
  ...mockCancelledTickets,
];

final List<NotificationModel> mockNotifications = [
  // --- THÔNG BÁO SỰ KIỆN (Event Tab) ---
  NotificationModel(
    id: 'ntf_01',
    type: 'event_reminder',
    title: 'Thông tin mới về Concert Chị Đẹp Đạp Gió Rẽ Sóng',
    message:
        'Concert sắp diễn ra vào ngày 16/11. Hãy kiểm tra lại vé và tư trang trước khi đến nhé!',
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    data: {
      'image': 'https://picsum.photos/id/10/800/400', // Ảnh minh họa
      'eventId': 'evt_future_01',
    },
  ),
  NotificationModel(
    id: 'ntf_02',
    type: 'system',
    title: 'EXID tổ chức FANCON ở Việt Nam tại TP.HCM',
    message:
        'Sự kiện hot nhất tháng đã chính thức mở bán vé. Đặt ngay để có vị trí đẹp nhất.',
    isRead: true,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    data: {
      'image': 'https://picsum.photos/id/20/800/400',
      'eventId': 'evt_exid',
    },
  ),
  NotificationModel(
    id: 'ntf_03',
    type: 'event_cancelled',
    title: 'Concert 5 Anh Trai Say Hi thay đổi địa điểm',
    message:
        'Do điều kiện thời tiết, địa điểm tổ chức đã được dời sang nhà thi đấu...',
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    data: {
      'image': 'https://picsum.photos/id/30/800/400',
      'eventId': 'evt_sayhi',
    },
  ),

  // --- THÔNG BÁO ƯU ĐÃI (Offer Tab) ---
  NotificationModel(
    id: 'ntf_promo_01',
    type: 'promotion',
    title: 'Giảm 20% khi thanh toán qua thẻ VISA',
    message:
        'Nhập mã VISA20 để được giảm ngay 20% tối đa 100k cho mọi đơn hàng.',
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    data: {
      'image': 'https://picsum.photos/id/40/800/400',
      'voucherId': 'vch_visa',
    },
  ),
  NotificationModel(
    id: 'ntf_promo_02',
    type: 'promotion',
    title: 'Mua 1 tặng 1 vé sự kiện Art Exhibition',
    message: 'Ưu đãi đặc biệt dành cho cặp đôi nhân ngày Valentine.',
    isRead: true,
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    data: {
      'image': 'https://picsum.photos/id/50/800/400',
      'voucherId': 'vch_b1g1',
    },
  ),
];

// ==========================================
// 5. MOCK CATEGORIES & CITIES (Khám phá)
// ==========================================

final List<CategoryModel> mockCategories = [
  CategoryModel(
    id: 'cat_sports',
    name: 'THỂ THAO',
    slug: 'sports',
    // Dùng ảnh placeholder đẹp thay vì icon
    icon:
        'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?q=80&w=800&auto=format&fit=crop',
    eventCount: 45,
  ),
  CategoryModel(
    id: 'cat_music',
    name: 'HOÀ NHẠC',
    slug: 'music',
    icon:
        'https://images.unsplash.com/photo-1459749411177-0473ef71607b?q=80&w=800&auto=format&fit=crop',
    eventCount: 78,
  ),
  CategoryModel(
    id: 'cat_art',
    name: 'TRIỂN LÃM',
    slug: 'art',
    icon:
        'https://images.unsplash.com/photo-1518998053901-5348d3969105?q=80&w=800&auto=format&fit=crop',
    eventCount: 20,
  ),
];

final List<CityModel> mockCities = [
  CityModel(
    id: 'city_hcm',
    name: 'HỒ CHÍ MINH',
    slug: 'ho-chi-minh',
    eventCount: 120,
    // Lưu ý: Model City chưa có trường image,
    // Có thể tạm thời hardcode trong UI hoặc thêm field vào model.
    // Ở đây giả định sẽ truyền URL ảnh trực tiếp khi hiển thị.
  ),
  CityModel(id: 'city_hn', name: 'HÀ NỘI', slug: 'ha-noi', eventCount: 95),
  CityModel(id: 'city_dn', name: 'ĐÀ NẴNG', slug: 'da-nang', eventCount: 40),
];

// Helper map để lấy ảnh cho City (vì model City trong spec cũ không có ảnh)
String getCityImage(String cityId) {
  switch (cityId) {
    case 'city_hcm':
      return 'https://images.unsplash.com/photo-1583417319070-4a69db38a482?q=80&w=800&auto=format&fit=crop';
    case 'city_hn':
      return 'https://images.unsplash.com/photo-1599708153386-7288ebf25b16?q=80&w=800&auto=format&fit=crop';
    case 'city_dn':
      return 'https://images.unsplash.com/photo-1560965386-8d5d45eb7128?q=80&w=800&auto=format&fit=crop';
    default:
      return 'https://via.placeholder.com/300';
  }
}

final List<EventModel> mockEvents = [_mockEvent, _mockEvent];
