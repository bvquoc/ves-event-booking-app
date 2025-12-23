import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ves_event_booking/providers/user_provider.dart';
import 'package:ves_event_booking/screens/explore/explore_screen.dart';
import 'package:ves_event_booking/screens/favourite_events_screen.dart';
import 'package:ves_event_booking/screens/home_screen.dart';
import 'package:ves_event_booking/screens/login_screen.dart';
import 'package:ves_event_booking/screens/notifications/notifications_screen.dart';
import 'package:ves_event_booking/screens/profile/profile_detail_screen.dart';
import 'package:ves_event_booking/screens/tickets/tickets_screen.dart';
import 'package:ves_event_booking/widgets/profile_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
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

        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              // === PHẦN CỐ ĐỊNH: HEADER + INFO ===
              _buildScrollableMenu(context, provider),
              _buildHeader(context),

              // === PHẦN CUỘN: CHỈ MENU ===
              // Expanded(
              //   child: _buildScrollableMenu(context),
              // ),
            ],
          ),
          bottomNavigationBar: _buildBottomNavBar(context),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg_image.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.white38, BlendMode.lighten),
            ),
          ),
        ),

        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    }
                  },
                ),
                const Expanded(
                  child: Text(
                    'Trang cá nhân',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
        ),

        Positioned(
          top: 150,
          left: 0,
          right: 0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 0),
            padding: const EdgeInsets.only(top: 72, bottom: 0),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                const Text(
                  'Nguyễn Văn A',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade900,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Thành viên hạng Bạc',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildDivider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    StatItem(
                      icon: Icons.star,
                      label: 'Điểm thưởng',
                      value: '0 điểm',
                    ),
                    StatItem(
                      icon: Icons.confirmation_number,
                      label: 'Kho voucher',
                      value: '10+ voucher',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildDivider(),
              ],
            ),
          ),
        ),

        Positioned(
          top: 88,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 124,
              height: 124,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 62,
                backgroundImage: AssetImage('assets/images/bg_image.png'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScrollableMenu(BuildContext context, UserProvider provider) {
    return Container(
      color: const Color.fromARGB(255, 255, 255, 255),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 408, 0, 100),
        child: Column(
          children: [
            _buildMenuSection([
              MenuItem(
                icon: Icons.shopping_bag_outlined,
                title: 'Vé của tôi',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TicketsScreen()),
                  );
                },
              ),
              MenuItem(
                icon: Icons.favorite_border,
                title: 'Mục yêu thích',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const FavoriteEventsScreen(),
                    ),
                  );
                },
              ),
              MenuItem(
                icon: Icons.confirmation_number_outlined,
                title: 'Voucher của tôi',
                onTap: () {},
              ),
            ]),
            _buildDivider(),
            _buildMenuSection([
              MenuItem(
                icon: Icons.edit_outlined,
                title: 'Thông tin cá nhân',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ProfileDetailScreen(),
                    ),
                  );
                },
              ),
              MenuItem(
                icon: Icons.attach_money_outlined,
                title: 'Phương thức thanh toán',
                onTap: () {},
              ),
              MenuItem(
                icon: Icons.settings_outlined,
                title: 'Cài đặt',
                onTap: () {},
              ),
              MenuItem(
                icon: Icons.headset_mic_outlined,
                title: 'Chính sách hỗ trợ',
                onTap: () {},
              ),
            ]),
            _buildDivider(),
            _buildLogoutButton(context, provider),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      height: 1,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildMenuSection(List<Widget> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: items),
    );
  }

  Widget _buildLogoutButton(BuildContext context, UserProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () async {
          await provider.logout();

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.logout_outlined, color: Colors.black, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Đăng xuất',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
          NavItem(
            icon: Icons.confirmation_num_rounded,
            isActive: false,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const TicketsScreen()),
              );
            },
          ),
          NavItem(
            icon: Icons.grid_view_rounded,
            isActive: false,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ExploreScreen()),
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
          NavItem(icon: Icons.person_2_rounded, isActive: true, onTap: () {}),
        ],
      ),
    );
  }
}
