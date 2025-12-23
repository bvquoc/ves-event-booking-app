import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ves_event_booking/providers/event_provider.dart';
import 'package:ves_event_booking/screens/explore/filtered_events_screen.dart';
import 'package:ves_event_booking/screens/home_screen.dart';
import 'package:ves_event_booking/screens/notifications/notifications_screen.dart';
import 'package:ves_event_booking/screens/profile/profile_creen.dart';
import 'package:ves_event_booking/screens/tickets/tickets_screen.dart';
import 'package:ves_event_booking/widgets/profile_widgets.dart';
import 'package:ves_event_booking/config/app_image_config.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => ExploreScreenState();
}

class ExploreScreenState extends State<ExploreScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<EventProvider>().fetchCategotiesAndCities();
    });
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
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(provider.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
            provider.clearError(); // VERY IMPORTANT
          });
        }

        final listCategories = provider.categories;
        final listCities = provider.cities;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Khám phá',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            centerTitle: true,
            automaticallyImplyLeading: false, // Tắt nút back mặc định
          ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100.0, top: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- SECTION 1: THỂ LOẠI ---
                    _buildSectionTitle('Khám phá theo Thể loại'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200, // fix height
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: listCategories.length,
                        itemBuilder: (context, index) {
                          final cat = listCategories[index];
                          return _buildExploreCard(
                            context,
                            title: cat.name,
                            imageUrl: cat
                                .icon, // Mock data đã thêm ảnh vào field icon
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FilteredEventsScreen(
                                    title: cat.name,
                                    categoryId: cat.id,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- SECTION 2: THÀNH PHỐ ---
                    _buildSectionTitle('Khám phá theo Thành phố'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: listCities.length,
                        itemBuilder: (context, index) {
                          final city = listCities[index];
                          return _buildExploreCard(
                            context,
                            title: city.name,
                            // Dùng hàm helper lấy ảnh city
                            imageUrl: "",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FilteredEventsScreen(
                                    title: city.name,
                                    cityId: city.id,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
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
                        isActive: false,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );
                        },
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
                        isActive: true, // Active trang này
                        onTap: () {},
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

  // --- WIDGET CON: Tiêu đề section ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  // --- WIDGET CON: Thẻ Khám Phá (Card Ảnh + Text) ---
  Widget _buildExploreCard(
    BuildContext context, {
    required String title,
    String? imageUrl,
    required VoidCallback onTap,
  }) {
    //String finalImage = (imageUrl != null && imageUrl.isNotEmpty)
    //    ? imageUrl
    //   : AppImages.getFallbackByTitle(title);
    String finalImage = AppImages.getFallbackByTitle(title);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          image: DecorationImage(
            image: NetworkImage(finalImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Title
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.0,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
