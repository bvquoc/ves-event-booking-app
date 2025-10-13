import 'package:flutter/material.dart';
import 'package:ves_event_booking/screens/explore_screen.dart';
import 'package:ves_event_booking/screens/home_screen.dart';
import 'package:ves_event_booking/screens/notifications_screen.dart';
import 'package:ves_event_booking/screens/profile/edit_profile_screen.dart';
import 'package:ves_event_booking/screens/tickets_screen.dart';
import 'package:ves_event_booking/widgets/profile_widgets.dart';

class ProfileDetailScreen extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String dob;

  const ProfileDetailScreen({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.dob,
  });

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailSceenState();
}

class _ProfileDetailSceenState extends State<ProfileDetailScreen> {
  late TextEditingController _nameController = TextEditingController();
  late TextEditingController _emailCotroller = TextEditingController();
  late TextEditingController _phoneController = TextEditingController();
  late TextEditingController _dobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailCotroller = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);
    _dobController = TextEditingController(text: widget.dob);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailCotroller.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bg_image.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.white38,
                    BlendMode.lighten,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 150,
            left: 0,
            right: 0,
            bottom: -40,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 80),
                      const Text(
                        'Nguyễn Văn A',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(34, 0, 20, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Thông tin cá nhân',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () async {
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const EditProfileScreen(),
                                  ),
                                );
                                if (result != null && result is Map) {
                                  setState(() {
                                    _nameController.text =
                                        result['name'] ?? _nameController.text;
                                    _emailCotroller.text =
                                        result['email'] ?? _emailCotroller.text;
                                    _phoneController.text =
                                        result['phone'] ??
                                        _phoneController.text;
                                    _dobController.text =
                                        result['dob'] ?? _dobController.text;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      // const SizedBox(height: 12),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        children: [
                                          InfoItem(
                                            label: 'Họ và tên',
                                            value: _nameController.text,
                                          ),
                                          InfoItem(
                                            label: 'Email',
                                            value: _emailCotroller.text,
                                          ),
                                          InfoItem(
                                            label: 'Số điện thoại',
                                            value: _phoneController.text,
                                          ),
                                          InfoItem(
                                            label: 'Ngày sinh',
                                            value: _dobController.text,
                                          ),

                                          const SizedBox(height: 160),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/bg_image.png'),
                ),
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Thông tin cá nhân',
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
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
                    isActive: true,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
