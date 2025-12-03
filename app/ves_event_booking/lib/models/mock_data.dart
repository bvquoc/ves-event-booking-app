import '../models/event_model.dart';
import '../models/organizer_model.dart';
import '../models/ticket_model.dart';
import '../models/ticket_type_model.dart';
import '../models/notification_model.dart';

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

// Sự kiện 1: TƯƠNG LAI (Dùng cho Tab Upcoming & Cancelled)
final EventModel _eventFuture = EventModel(
  id: 'evt_future_01',
  name: 'Concert Hà Anh Tuấn - Chân Trời Rực Rỡ',
  slug: 'concert-ha-anh-tuan',
  description: 'Đêm nhạc acoustic lãng mạn tại Đà Lạt.',
  longDescription: '...',
  category: 'concert',
  thumbnail: 'https://picsum.photos/id/453/800/400', // Ảnh demo
  startDate: DateTime.now().add(const Duration(days: 15)), // 15 ngày tới
  endDate: DateTime.now().add(const Duration(days: 15, hours: 4)),
  city: 'Đà Lạt',
  venueName: 'Trung tâm Hội nghị Đà Lạt',
  venueId: 'ven_dalat',
  venueAddress: 'Số 1, Phù Đổng Thiên Vương',
  minPrice: 800000,
  maxPrice: 3000000,
  currency: 'VND',
  availableTickets: 500,
  ticketTypes: [_typeVip, _typeStandard],
  organizer: _mockOrganizer,
  isTrending: true,
);

// Sự kiện 2: QUÁ KHỨ (Dùng cho Tab Past)
final EventModel _eventPast = EventModel(
  id: 'evt_past_01',
  name: 'Triển lãm Van Gogh Art Lighting',
  slug: 'van-gogh-expo',
  description: 'Trải nghiệm nghệ thuật ánh sáng đa giác quan.',
  longDescription: '...',
  category: 'exhibition',
  thumbnail: 'https://picsum.photos/id/1040/800/400', // Ảnh demo
  startDate: DateTime.now().subtract(const Duration(days: 30)), // 30 ngày trước
  endDate: DateTime.now().subtract(const Duration(days: 30, hours: 2)),
  city: 'TP. Hồ Chí Minh',
  venueName: 'Gigamall Thủ Đức',
  venueId: 'ven_giga',
  venueAddress: 'Phạm Văn Đồng, Thủ Đức',
  minPrice: 300000,
  maxPrice: 600000,
  currency: 'VND',
  availableTickets: 0,
  ticketTypes: [_typeStandard],
  organizer: _mockOrganizer,
);

// ==========================================
// 3. MOCK TICKETS (Vé) - Dữ liệu chính để test UI
// ==========================================

// --- List 1: UPCOMING TICKETS (Vé sắp tới - Status: active) ---
final List<TicketModel> mockUpcomingTickets = [
  TicketModel(
    id: 'tkt_up_01',
    orderId: 'ord_001',
    event: _eventFuture,
    ticketType: _typeVip,
    qrCode: 'QR_UPCOMING_01',
    status: 'active',
    purchaseDate: DateTime.now().subtract(const Duration(days: 2)),
    seatNumber: 'A-12',
  ),
  TicketModel(
    id: 'tkt_up_02',
    orderId: 'ord_001', // Cùng 1 đơn hàng mua 2 vé
    event: _eventFuture,
    ticketType: _typeVip,
    qrCode: 'QR_UPCOMING_02',
    status: 'active',
    purchaseDate: DateTime.now().subtract(const Duration(days: 2)),
    seatNumber: 'A-13',
  ),
];

// --- List 2: PAST TICKETS (Vé đã qua/đã dùng - Status: used/completed) ---
final List<TicketModel> mockPastTickets = [
  TicketModel(
    id: 'tkt_past_01',
    orderId: 'ord_old_01',
    event: _eventPast,
    ticketType: _typeStandard,
    qrCode: 'QR_PAST_01',
    status: 'used', // Đã sử dụng
    purchaseDate: DateTime.now().subtract(const Duration(days: 35)),
    seatNumber: null, // Vé đứng/tự do
    checkedInAt: _eventPast.startDate.add(const Duration(minutes: 15)),
  ),
];

// --- List 3: CANCELLED TICKETS (Vé đã hủy - Status: cancelled) ---
final List<TicketModel> mockCancelledTickets = [
  TicketModel(
    id: 'tkt_cancel_01',
    orderId: 'ord_cancel_01',
    event: _eventFuture, // Hủy vé của sự kiện tương lai
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
