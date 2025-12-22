import 'package:flutter/material.dart';
import 'package:ves_event_booking/models/category/category_model.dart';
import 'package:ves_event_booking/models/city/city_model.dart';
import 'package:ves_event_booking/models/event/event_model.dart';
import 'package:ves_event_booking/models/ticket/ticket_details_model.dart';
import 'package:ves_event_booking/models/utils/pagination_request.dart';
import 'package:ves_event_booking/services/category_service.dart';
import 'package:ves_event_booking/services/city_service.dart';
import 'package:ves_event_booking/services/event_service.dart';
import 'package:ves_event_booking/services/favorite_service.dart';

class EventProvider extends ChangeNotifier {
  final EventService _eventService = EventService();
  final CategoryService _categoryService = CategoryService();
  final CityService _cityService = CityService();
  final FavoriteService _favoriteService = FavoriteService();

  bool _isLoading = false;
  String? _errorMessage;
  List<EventModel> _events = [];
  List<CategoryModel> _categories = [];
  List<CityModel> _cities = [];
  EventDetailsModel? _event;
  Set<String> _favoriteEventIds = {};

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<EventModel> get events => _events;
  List<CategoryModel> get categories => _categories;
  List<CityModel> get cities => _cities;
  EventDetailsModel? get event => _event;

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

  Future<void> fetchEventById(String eventId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final responseData = await _eventService.getEvent(eventId);
      // Lưu ý: service của bạn cần trả về EventDetailsModel thay vì EventModel
      _event = responseData;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCategotiesAndCities() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final responses = await Future.wait([
        _categoryService.getCategories(),
        _cityService.getCities(),
      ]);

      _categories = responses[0] as List<CategoryModel>;
      _cities = responses[1] as List<CityModel>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFavoriteEventIds({
    required PaginationRequest pageable,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final pageResult = await _favoriteService.getFavoriteEvents(
        pageable: pageable,
      );

      _favoriteEventIds = pageResult.content.map((event) => event.id).toSet();
      _syncFavoriteStatus();
    } catch (e) {
      _favoriteEventIds = {};
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _syncFavoriteStatus() {
    // Duyệt qua tất cả event đang hiển thị
    // Nếu ID của event nằm trong _favoriteEventIds -> set isFavorite = true
    _events = _events.map((event) {
      final isFav = _favoriteEventIds.contains(event.id);
      return event.copyWith(isFavorite: isFav);
    }).toList();
  }

  Future<void> toggleFavorite(String eventId) async {
    // 1. Lưu trạng thái cũ để revert nếu lỗi
    final bool wasFavorite = _favoriteEventIds.contains(eventId);

    // 2. OPTIMISTIC UPDATE: Cập nhật UI ngay lập tức trước khi gọi API
    if (wasFavorite) {
      _favoriteEventIds.remove(eventId); // Xóa khỏi bộ nhớ local
    } else {
      _favoriteEventIds.add(eventId); // Thêm vào bộ nhớ local
    }

    // Đồng bộ lại UI list events và báo view vẽ lại
    _syncFavoriteStatus();
    notifyListeners();

    try {
      // 3. Gọi API thực tế
      if (wasFavorite) {
        // Đang thích -> Gọi API Bỏ thích (DELETE)
        await _favoriteService.removeFromFavorites(eventId);
      } else {
        // Chưa thích -> Gọi API Thích (POST)
        await _favoriteService.addToFavorites(eventId);
      }
    } catch (e) {
      // 4. REVERT: Nếu API lỗi, trả lại trạng thái cũ
      if (wasFavorite) {
        _favoriteEventIds.add(eventId); // Trả lại ID
      } else {
        _favoriteEventIds.remove(eventId); // Xóa lại ID
      }

      // Update lại UI về như cũ
      _syncFavoriteStatus();
      notifyListeners();
    }
  }
}
