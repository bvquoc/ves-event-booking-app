import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ves_event_booking/models/utils/pagination_request.dart';
import 'package:ves_event_booking/providers/home_provider.dart';
import 'package:ves_event_booking/screens/explore/explore_screen.dart';
import 'package:ves_event_booking/screens/explore/filtered_events_screen.dart';
import 'package:ves_event_booking/screens/notifications/notifications_screen.dart';
import 'package:ves_event_booking/screens/profile/profile_creen.dart';
import 'package:ves_event_booking/screens/tickets/tickets_screen.dart';
import 'package:ves_event_booking/widgets/home_screen_widgets/event_section.dart';
import 'package:ves_event_booking/widgets/home_screen_widgets/home_header.dart';
import 'package:ves_event_booking/widgets/home_screen_widgets/voucher_section.dart';
import 'package:ves_event_booking/widgets/profile_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HomeProvider>().fetchMyVouchers();
      context.read<HomeProvider>().fetchEvents(
        pageable: PaginationRequest(page: 0, size: 50),
      );
      context.read<HomeProvider>().fetchCategoties();
      context.read<HomeProvider>().fetchFavoriteEventIds(
        pageable: PaginationRequest(page: 0, size: 50),
      );
    });
  }

  void _onSearchSubmitted(String keyword) {
    context.read<HomeProvider>().fetchEvents(
      pageable: PaginationRequest(page: 0, size: 50),
      search: keyword,
    );
  }

  void _onViewAllEvents(String categorySlug) {
    final categories = context.read<HomeProvider>().categories;

    try {
      final category = categories.firstWhere((cat) => cat.slug == categorySlug);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FilteredEventsScreen(
            title: category.name,
            categoryId: category.id,
          ),
        ),
      );
    } catch (e) {
      SnackBar(content: Text('Không tìm thấy danh mục sự kiện.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
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

        final listVoucherStatus = provider.vouchers;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  children: [
                    // --- PHẦN HEADER & BANNER (LUÔN HIỂN THỊ) ---
                    Stack(
                      children: [
                        Container(
                          height: 440,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: const AssetImage(
                                'assets/images/image 85.png',
                              ),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                const Color.fromARGB(175, 39, 39, 39),
                                BlendMode.lighten,
                              ),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            HomeHeader(
                              onSearch: (value) => _onSearchSubmitted(value),
                            ),
                            const SizedBox(height: 20),
                            const PosterCard(),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- PHẦN VOUCHER (LUÔN HIỂN THỊ) ---
                    VoucherSection(voucherStatusList: listVoucherStatus),
                    const SizedBox(height: 20),

                    // --- PHẦN SỰ KIỆN (THAY ĐỔI THEO TRẠNG THÁI LOADING) ---
                    // Kiểm tra: Nếu đang loading thì hiện vòng xoay
                    if (provider.isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    // Kiểm tra: Nếu có lỗi thì hiện thông báo lỗi ở đây
                    else if (provider.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Center(
                          child: Text(
                            provider.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      )
                    // Loading thành công: hiện danh sách Event
                    else
                      Column(
                        children: [
                          EventSection(
                            title: 'Buổi hòa nhạc',
                            events: provider.events
                                .where((e) => e.category?.slug == 'hoa-nhac')
                                .toList(),
                            onViewAll: () => _onViewAllEvents('hoa-nhac'),
                            onFavoriteToggle: (eventId) {
                              provider.toggleFavorite(eventId);
                            },
                          ),
                          const SizedBox(height: 20),
                          EventSection(
                            title: 'Sân khấu kịch',
                            events: provider.events
                                .where(
                                  (e) => e.category?.slug == 'san-khau-kich',
                                )
                                .toList(),
                            onViewAll: () => _onViewAllEvents('san-khau-kich'),
                            onFavoriteToggle: (eventId) {
                              provider.toggleFavorite(eventId);
                            },
                          ),
                          const SizedBox(height: 20),
                          EventSection(
                            title: 'Thể thao',
                            events: provider.events
                                .where((e) => e.category?.slug == 'the-thao')
                                .toList(),
                            onViewAll: () => _onViewAllEvents('the-thao'),
                            onFavoriteToggle: (eventId) {
                              provider.toggleFavorite(eventId);
                            },
                          ),
                          const SizedBox(height: 20),
                          EventSection(
                            title: 'Triển lãm',
                            events: provider.events
                                .where((e) => e.category?.slug == 'trien-lam')
                                .toList(),
                            onViewAll: () => _onViewAllEvents('trien-lam'),
                            onFavoriteToggle: (eventId) {
                              provider.toggleFavorite(eventId);
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                  ],
                ),
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 32,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0f0c29),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      NavItem(
                        icon: Icons.home_rounded,
                        isActive: true,
                        onTap: () {},
                      ),
                      NavItem(
                        icon: Icons.confirmation_num_rounded,
                        isActive: false,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TicketsScreen(),
                            ),
                          );
                        },
                      ),
                      NavItem(
                        icon: Icons.grid_view_rounded,
                        isActive: false,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ExploreScreen(),
                            ),
                          );
                        },
                      ),
                      NavItem(
                        icon: Icons.notifications_rounded,
                        isActive: false,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsScreen(),
                            ),
                          );
                        },
                      ),
                      NavItem(
                        icon: Icons.person_2_rounded,
                        isActive: false,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
