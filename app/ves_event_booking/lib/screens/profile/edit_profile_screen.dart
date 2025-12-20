import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ves_event_booking/models/user/user_model.dart';
import 'package:ves_event_booking/models/user/user_model_update_request.dart';
import 'package:ves_event_booking/providers/user_provider.dart';
import 'package:ves_event_booking/screens/explore/explore_screen.dart';
import 'package:ves_event_booking/screens/home_screen.dart';
import 'package:ves_event_booking/screens/notifications/notifications_screen.dart';
import 'package:ves_event_booking/screens/tickets/tickets_screen.dart';
import 'package:ves_event_booking/widgets/profile_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() {
    return _EditProfileScreenState();
  }
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailCotroller = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  void setInitialValues(UserModel user) {
    _nameController.text = user.username;
    _emailCotroller.text = user.firstName ?? '';
    _phoneController.text = user.lastName ?? '';
    _dobController.text = user.dob != null
        ? '${user.dob!.day}/${user.dob!.month}/${user.dob!.year}'
        : '';
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
    return Consumer<UserProvider>(
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

        final user = provider.user;
        if (user != null) {
          setInitialValues(user);
        }

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

                          const SizedBox(height: 20),
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
                                          margin: const EdgeInsets.fromLTRB(
                                            16,
                                            16,
                                            16,
                                            120,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Form(
                                                key: _formKey,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                      ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      EditInfo(
                                                        label: 'Họ và tên',
                                                        controller:
                                                            _nameController,
                                                        hintText:
                                                            'Nguyễn Văn A',
                                                      ),
                                                      EditInfo(
                                                        label: 'Email',
                                                        controller:
                                                            _emailCotroller,
                                                        hintText:
                                                            'abc@gmail.com',
                                                      ),
                                                      EditInfo(
                                                        label: 'Số điện thoại',
                                                        controller:
                                                            _phoneController,
                                                        hintText:
                                                            '+84987654321',
                                                      ),
                                                      EditInfo(
                                                        label: 'Ngày sinh',
                                                        controller:
                                                            _dobController,
                                                        hintText: '24/12/2004',
                                                      ),

                                                      // const SizedBox(height: 12),
                                                      Center(
                                                        child: SizedBox(
                                                          width: 100,
                                                          child: ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  Colors
                                                                      .blue
                                                                      .shade900,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      16,
                                                                    ),
                                                              ),
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    vertical:
                                                                        16,
                                                                  ),
                                                            ),
                                                            onPressed: () async {
                                                              if (_formKey
                                                                  .currentState!
                                                                  .validate()) {
                                                                await provider.updateProfile(
                                                                  UserModelUpdateRequest(
                                                                    firstName:
                                                                        _emailCotroller
                                                                            .text,
                                                                    lastName:
                                                                        _phoneController
                                                                            .text,
                                                                    dob: DateTime.tryParse(
                                                                      _dobController
                                                                          .text,
                                                                    ),
                                                                  ),
                                                                );
                                                                if (!mounted) {
                                                                  return; // ✅ REQUIRED
                                                                }

                                                                Navigator.pop(
                                                                  context,
                                                                );
                                                              }
                                                            },
                                                            child: const Text(
                                                              'Lưu',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
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
                            'Chỉnh sửa thông tin',
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
                  margin: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 32,
                  ),
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
            ],
          ),
        );
      },
    );
  }
}
