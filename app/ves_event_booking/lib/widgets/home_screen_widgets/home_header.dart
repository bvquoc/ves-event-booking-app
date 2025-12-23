import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:ves_event_booking/screens/profile/profile_creen.dart';

class HomeHeader extends StatefulWidget {
  final Function(String) onSearch;
  const HomeHeader({super.key, required this.onSearch});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  final TextEditingController _searchController = TextEditingController();

  void _handleSearch(String value) {
    widget.onSearch(value);
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/images/logo.png'),
                IconButton(
                  iconSize: 60,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                  icon: Icon(Icons.account_circle, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bạn đang ở:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Thành phố Hồ Chí Minh',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  radius: Radius.circular(8),
                  color: Colors.white,
                  strokeWidth: 2,
                  dashPattern: <double>[10, 10],
                ),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'Chọn vị trí',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (value) => _handleSearch(value),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Tìm kiếm',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10,
                            ), // Căn giữa text
                            isDense: true,
                          ),
                        ),
                      ),
                      Icon(Icons.mic, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PosterCard extends StatelessWidget {
  const PosterCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          // IMAGE (kích thước quyết định Stack)
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              'assets/images/image 90.png',
              width: 300,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),

          // POSITIONED THEO ẢNH
          Positioned(
            left: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'The Spark',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 6, color: Colors.black)],
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '16/11/2024',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
