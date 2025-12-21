import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ves_event_booking/data/home_mock.dart';
import 'package:ves_event_booking/models/event/event_model.dart';
import 'package:ves_event_booking/widgets/event_detail/event_bottom_bar.dart';
import '../../widgets/event_detail/event_appbar.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  EventModel? _event;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEventData();
  }

  Future<void> _loadEventData() async {
    setState(() => _isLoading = true);

    // TODO: Replace with actual API call
    // Example:
    // try {
    //   final apiService = ApiService();
    //   final event = await apiService.getEventDetail(widget.eventId);
    //   setState(() {
    //     _event = event;
    //     _isLoading = false;
    //   });
    // } catch (e) {
    //   setState(() => _isLoading = false);
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
    //     );
    //   }
    // }

    // Mock data for now
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _event = _getMockEvent();
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite() async {
    if (_event == null) return;

    // TODO: API call to toggle favorite
    // try {
    //   final apiService = ApiService();
    //   final newStatus = await apiService.toggleFavorite(
    //     _event!.id,
    //     _event!.isFavorite,
    //   );
    //   setState(() {
    //     _event = _event!.copyWith(isFavorite: newStatus);
    //   });
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Lỗi: $e')),
    //   );
    // }

    // Mock for now
    setState(() {
      _event = EventModel(
        id: _event!.id,
        name: _event!.name,
        slug: _event!.slug,
        description: _event!.description,
        longDescription: _event!.longDescription,
        category: _event!.category,
        thumbnail: _event!.thumbnail,
        images: _event!.images,
        startDate: _event!.startDate,
        endDate: _event!.endDate,
        city: _event!.city,
        venueId: _event!.venueId,
        venueName: _event!.venueName,
        venueAddress: _event!.venueAddress,
        minPrice: _event!.minPrice,
        maxPrice: _event!.maxPrice,
        currency: _event!.currency,
        availableTickets: _event!.availableTickets,
        ticketTypes: _event!.ticketTypes,
        isTrending: _event!.isTrending,
        isFavorite: !_event!.isFavorite, // Toggle
        terms: _event!.terms,
        cancellationPolicy: _event!.cancellationPolicy,
        tags: _event!.tags,
        venue: _event!.venue,
        organizerId: _event!.organizerId,
        organizerName: _event!.organizerName,
        organizerLogo: _event!.organizerLogo,
        createdAt: _event!.createdAt,
        updatedAt: _event!.updatedAt,
      );
    });
  }

  String formatCurrency(int amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)}đ';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_event == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy sự kiện')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          EventAppBar(event: _event!, onFavoritePressed: _toggleFavorite),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),

                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Giới thiệu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _getMockEvent().name,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        Container(height: 1, color: Colors.grey.shade500),
                        const SizedBox(height: 12),

                        Text(
                          'THÔNG TIN CHUNG',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),

                        Text(
                          'Thời gian dự kiến: ${_formatDateTime()} \nĐịa điểm: ${_formatLocation()}',
                        ),
                        const SizedBox(height: 12),

                        Container(height: 1, color: Colors.grey.shade500),
                        const SizedBox(height: 12),

                        Text(
                          'TÓM TẮT QUY ĐỊNH VÀ ĐIỀU KHOẢN',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(_getMockEvent().description),
                        const SizedBox(height: 12),

                        Text(_getMockEvent().longDescription!),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Thông tin vé',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade100, Colors.blue.shade900],
                      ),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.all(12),
                      shrinkWrap: true,

                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _getMockEvent().ticketTypes!.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final ticket = _getMockEvent().ticketTypes![index];
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(
                              255,
                              13,
                              32,
                              74,
                            ).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.confirmation_number_outlined,
                              color: Colors.white,
                              size: 30,
                            ),

                            title: Text(
                              ticket.name.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),

                            trailing: Text(
                              formatCurrency(ticket.price.toInt()),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: EventBottomBar(event: _getMockEvent()),
    );
  }

  String _formatDateTime() {
    final dateFormat = DateFormat('HH:mm - dd/MM/yyyy');
    String result = dateFormat.format(_getMockEvent().startDate);

    if (_getMockEvent().endDate != null) {
      result += ' Đến: ${dateFormat.format(_getMockEvent().endDate!)}';
    }

    return result;
  }

  String _formatLocation() {
    String location = _getMockEvent().venueName;
    location += ' ${_getMockEvent().city}';

    if (_getMockEvent().venueAddress != null) {
      location += ', ${_getMockEvent().venueAddress}';
    }

    return location;
  }

  // Mock data - TODO: Remove when integrating with API
  EventModel _getMockEvent() {
    return EventModel(
      id: 'evt_1',
      name: 'School Fest 2024',
      slug: 'school-fest-2024',
      description: 'Lễ hội âm nhạc dành cho học sinh – sinh viên',
      longDescription:
          'School Fest 2024 là lễ hội âm nhạc sôi động với sự góp mặt của nhiều nghệ sĩ trẻ nổi tiếng.',
      thumbnail: 'assets/images/image_106.png',
      images: ['assets/images/image_106.png', 'assets/images/image_107.png'],
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
    );
    ;
  }
}
