import 'package:flutter/material.dart';
import 'package:ves_event_booking/models/event/event_model.dart';
import 'package:ves_event_booking/models/utils/pagination_request.dart';
import 'package:ves_event_booking/models/voucher/voucher_status_model.dart';
import 'package:ves_event_booking/services/event_service.dart';
import 'package:ves_event_booking/services/voucher_service.dart';

class HomeProvider extends ChangeNotifier {
  final EventService _eventService = EventService();
  final VoucherService _voucherService = VoucherService();

  bool _isLoading = false;
  String? _errorMessage;
  List<EventModel> _events = [];
  List<VoucherStatusModel> _vouchers = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<EventModel> get events => _events;
  List<VoucherStatusModel> get vouchers => _vouchers;

  Future<void> fetchEvents({
    required PaginationRequest pageable,
    String? category,
    String? city,
    bool? trending,
    String? startDate,
    String? endDate,
    String? search,
    String? sortBy,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _eventService.getEvents(
        pageable: pageable,
        category: category,
        city: city,
        trending: trending,
        startDate: startDate,
        endDate: endDate,
        search: search,
        sortBy: sortBy,
      );
      _events = response;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyVouchers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _vouchers = await _voucherService.getMyVouchers();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
