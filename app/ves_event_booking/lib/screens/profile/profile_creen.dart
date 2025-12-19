
import 'package:flutter/material.dart';
import 'package:ves_event_booking/screens/explore_screen.dart';
import 'package:ves_event_booking/screens/home_screen.dart';
import 'package:ves_event_booking/screens/notifications/notifications_screen.dart';
import 'package:ves_event_booking/screens/profile/profile_detail_screen.dart';
import 'package:ves_event_booking/screens/tickets/tickets_screen.dart';
import 'package:ves_event_booking/widgets/profile_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Stack(
        children: [
          _buildScrollableMenu(context),

          _buildHeader(context),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNavBar(context),
          ),
        ],
      ),
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
              image: const AssetImage('assets/images/bg_image.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.white38,
                BlendMode.lighten,
              ),
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
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    'Trang cá nhân',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
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
            padding: const EdgeInsets.only(top: 72),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
              ),
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
                  children: const [
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
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 62,
                backgroundImage:
                    AssetImage('assets/images/bg_image.png'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScrollableMenu(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 408, 0, 120),
      child: Column(
        children: [
          _buildMenuSection([
            MenuItem(
              icon: Icons.shopping_bag_outlined,
              title: 'Vé của tôi',
              onTap: () {},
            ),
            MenuItem(
              icon: Icons.favorite_border,
              title: 'Mục yêu thích',
              onTap: () {},
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileDetailScreen(
                      name: 'Nguyễn Văn A',
                      email: 'abc@gmail.com',
                      phone: '+84987654321',
                      dob: '24/12/2004',
                    ),
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
          _buildLogoutButton(),
          const SizedBox(height: 40),
        ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: items),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: const [
              Icon(Icons.logout_outlined, size: 24),
              SizedBox(width: 16),
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
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
          ),
          NavItem(
            icon: Icons.confirmation_num_rounded,
            isActive: false,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const TicketsScreen()),
              );
            },
          ),
          NavItem(
            icon: Icons.grid_view_rounded,
            isActive: false,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ExploreScreen()),
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
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
          ),
          NavItem(
            icon: Icons.person_2_rounded,
            isActive: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
