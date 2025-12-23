// screens/booking/seat_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:ves_event_booking/models/ticket/ticket_type_model.dart';
import 'package:ves_event_booking/models/venue/venue_seat_map_model.dart';
import 'package:ves_event_booking/models/venue/venue_seat_model.dart';
import 'package:ves_event_booking/services/venue_service.dart';

class SeatSelectionScreen extends StatefulWidget {
  final String eventId;
  final String venueId;

  // Nhận vào Map số lượng vé cần chọn: { 'ticketTypeId': quantity }
  final Map<String, int> requiredQuantities;

  // Nhận danh sách thông tin loại vé để hiển thị tên (VIP, Thường...)
  final List<TicketTypeModel> ticketTypes;

  const SeatSelectionScreen({
    super.key,
    required this.eventId,
    required this.venueId,
    required this.requiredQuantities,
    required this.ticketTypes,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final VenueService _venueService = VenueService();
  bool _isLoading = true;
  String? _errorMessage;
  VenueSeatMapModel? _seatMap;

  // State lưu trữ: { 'ticketTypeId': [List các ghế đã chọn] }
  final Map<String, List<String>> _selectedSeatsByTicket = {};

  // Biến xác định đang chọn ghế cho loại vé nào
  String? _currentActiveTicketTypeId;

  @override
  void initState() {
    super.initState();
    // Khởi tạo map rỗng cho các key
    widget.requiredQuantities.forEach((key, value) {
      if (value > 0) _selectedSeatsByTicket[key] = [];
    });

    _updateActiveTicketType(); // Xác định loại vé cần chọn đầu tiên
    _fetchSeatMap();
  }

  // Logic tự động chuyển sang loại vé tiếp theo nếu loại hiện tại đã chọn đủ
  void _updateActiveTicketType() {
    String? nextType;
    // Duyệt qua các loại vé cần mua
    for (var entry in widget.requiredQuantities.entries) {
      final typeId = entry.key;
      final requiredQty = entry.value;
      final currentSelected = _selectedSeatsByTicket[typeId]?.length ?? 0;

      // Nếu loại này chưa chọn đủ -> Set làm active để chọn tiếp
      if (currentSelected < requiredQty) {
        nextType = typeId;
        break;
      }
    }
    setState(() {
      _currentActiveTicketTypeId = nextType;
    });
  }

  Future<void> _fetchSeatMap() async {
    try {
      final map = await _venueService.getVenueSeats(
        venueId: widget.venueId,
        eventId: widget.eventId,
      );
      setState(() {
        _seatMap = map;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _toggleSeat(String seatId, String status) {
    if (status != 'AVAILABLE') return;

    // 1. Kiểm tra xem ghế này đã được chọn bởi loại vé nào chưa (để bỏ chọn)
    String? typeIdContainingSeat;
    _selectedSeatsByTicket.forEach((key, list) {
      if (list.contains(seatId)) typeIdContainingSeat = key;
    });

    setState(() {
      if (typeIdContainingSeat != null) {
        // ==> Trường hợp BỎ CHỌN ghế
        _selectedSeatsByTicket[typeIdContainingSeat]!.remove(seatId);
        // Sau khi bỏ chọn, có thể cần quay lại chọn tiếp cho loại vé này
        _updateActiveTicketType();
      } else {
        // ==> Trường hợp CHỌN MỚI
        if (_currentActiveTicketTypeId != null) {
          _selectedSeatsByTicket[_currentActiveTicketTypeId]!.add(seatId);
          // Kiểm tra xem đã đủ chưa để chuyển loại
          _updateActiveTicketType();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bạn đã chọn đủ tất cả các ghế!')),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sơ đồ ghế'), centerTitle: true),
      body: Column(
        children: [
          _buildInstructionBar(), // Thanh hướng dẫn trạng thái
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  // Widget hiển thị: "Đang chọn ghế cho vé VIP (1/2)"
  Widget _buildInstructionBar() {
    if (_currentActiveTicketTypeId == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        color: Colors.green.shade100,
        child: const Text(
          "Đã chọn đủ ghế. Bấm xác nhận để tiếp tục.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
      );
    }

    final ticketName = widget.ticketTypes
        .firstWhere((t) => t.id == _currentActiveTicketTypeId)
        .name;
    final current =
        _selectedSeatsByTicket[_currentActiveTicketTypeId]?.length ?? 0;
    final total = widget.requiredQuantities[_currentActiveTicketTypeId] ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.blue.shade50,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 16),
          children: [
            const TextSpan(text: "Vui lòng chọn ghế cho: "),
            TextSpan(
              text: "$ticketName ",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            TextSpan(
              text: "($current/$total)",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Text(_errorMessage!));
    if (_seatMap == null) return const Center(child: Text("No data"));

    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 3.0,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              // Sân khấu
              Container(
                margin: const EdgeInsets.only(bottom: 30),
                width: 300,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ),
              const Text(
                "SÂN KHẤU",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // Sections
              ..._seatMap!.sections.map((section) {
                final sortedRows = List.of(section.rows)
                  ..sort((a, b) => a.rowName.compareTo(b.rowName));

                return Column(
                  children: [
                    Text(
                      section.sectionName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    ...sortedRows.map((row) {
                      final sortedSeats = List.of(row.seats)
                        ..sort((a, b) {
                          final aNum = int.tryParse(a.seatNumber) ?? 0;
                          final bNum = int.tryParse(b.seatNumber) ?? 0;
                          return aNum.compareTo(bNum);
                        });

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 30,
                              child: Text(
                                row.rowName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ...sortedSeats.map((seat) => _buildSeatItem(seat)),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeatItem(VenueSeatModel seat) {
    // Kiểm tra ghế này có đang được chọn không
    bool isSelected = false;
    _selectedSeatsByTicket.forEach((_, list) {
      if (list.contains(seat.id)) isSelected = true;
    });

    bool isAvailable = seat.status == 'AVAILABLE';

    Color seatColor;
    if (isSelected) {
      seatColor = Colors.orange; // Màu đã chọn
    } else if (isAvailable) {
      seatColor = Colors.white;
    } else {
      seatColor = Colors.grey.shade300;
    }

    return GestureDetector(
      onTap: () => _toggleSeat(seat.id, seat.status),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: seatColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade400,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          seat.seatNumber,
          style: TextStyle(
            fontSize: 10,
            color: isSelected
                ? Colors.white
                : (isAvailable ? Colors.black : Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    // Kiểm tra đã chọn hết tất cả chưa
    bool isDone = _currentActiveTicketTypeId == null;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isDone
              ? () {
                  Navigator.pop(context, _selectedSeatsByTicket);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade900,
            disabledBackgroundColor: Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Text(
            isDone ? 'Xác nhận' : 'Vui lòng chọn đủ ghế',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
