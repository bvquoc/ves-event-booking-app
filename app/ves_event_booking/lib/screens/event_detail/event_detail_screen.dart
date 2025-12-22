import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ves_event_booking/models/event/event_model.dart';
import 'package:ves_event_booking/providers/event_provider.dart';
import 'package:ves_event_booking/widgets/event_detail/event_bottom_bar.dart';

import '../../widgets/event_detail/event_appbar.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<EventProvider>().fetchEventById(widget.eventId);
    });
  }

  String formatCurrency(int amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)}đ';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        // ⏳ Loading
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // ❌ Error
        if (provider.errorMessage != null) {
          return Center(
            child: Text(
              provider.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final _event = provider.event;

        if (_event == null) {
          return const Scaffold(
            body: Center(child: Text('Không tìm thấy sự kiện')),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              EventAppBar(event: _event!, onFavoritePressed: () {}),
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
                              _event.name,
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
                              'Thời gian dự kiến: ${_formatDateTime(_event)} \nĐịa điểm: ${_formatLocation(_event)}',
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
                            Text(_event.description ?? ''),
                            const SizedBox(height: 12),

                            Text(""),

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
                            colors: [
                              Colors.blue.shade100,
                              Colors.blue.shade900,
                            ],
                          ),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(20),
                          ),
                        ),
                        child: ListView.separated(
                          padding: EdgeInsets.all(12),
                          shrinkWrap: true,

                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 0,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final ticket = _event.ticketTypes![index];
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
          bottomNavigationBar: EventBottomBar(event: _event),
        );
      },
    );
  }

  String _formatDateTime(EventModel event) {
    final dateFormat = DateFormat('HH:mm - dd/MM/yyyy');
    String result = dateFormat.format(event.startDate);

    result += ' Đến: ${dateFormat.format(event.endDate)}';

    return result;
  }

  String _formatLocation(EventModel event) {
    String location = event.venueName ?? '';
    location += ' ${event.city}';

    if (event.venueAddress != null) {
      location += ', ${event.venueAddress}';
    }

    return location;
  }
}
