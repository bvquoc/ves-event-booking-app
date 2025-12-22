import 'package:flutter/material.dart';
import 'package:ves_event_booking/models/category/category_model.dart';
import 'package:ves_event_booking/models/event/event_model.dart';
import 'package:ves_event_booking/models/utils/pagination_request.dart';
import 'package:ves_event_booking/models/voucher/voucher_status_model.dart';
import 'package:ves_event_booking/services/category_service.dart';
import 'package:ves_event_booking/services/event_service.dart';
import 'package:ves_event_booking/services/voucher_service.dart';

class HomeProvider extends ChangeNotifier {
  final EventService _eventService = EventService();
  final VoucherService _voucherService = VoucherService();
  final CategoryService _categoryService = CategoryService();

  bool _isLoading = false;
  String? _errorMessage;
  List<EventModel> _events = [];
  List<VoucherStatusModel> _vouchers = [];
  List<CategoryModel> _categories = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<EventModel> get events => _events;
  List<VoucherStatusModel> get vouchers => _vouchers;
  List<CategoryModel> get categories => _categories;

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
      _events = response.content;
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

  Future<void> fetchCategoties() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _categoryService.getCategories();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
