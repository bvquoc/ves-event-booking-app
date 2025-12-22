import 'package:flutter/material.dart';
import 'package:ves_event_booking/models/category/category_model.dart';
import 'package:ves_event_booking/models/city/city_model.dart';
import 'package:ves_event_booking/models/event/event_model.dart';
import 'package:ves_event_booking/models/utils/pagination_request.dart';
import 'package:ves_event_booking/services/category_service.dart';
import 'package:ves_event_booking/services/city_service.dart';
import 'package:ves_event_booking/services/event_service.dart';

class EventProvider extends ChangeNotifier {
  final EventService _eventService = EventService();
  final CategoryService _categoryService = CategoryService();
  final CityService _cityService = CityService();

  bool _isLoading = false;
  String? _errorMessage;
  List<EventModel> _events = [];
  List<CategoryModel> _categories = [];
  List<CityModel> _cities = [];
  EventModel? _event;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<EventModel> get events => _events;
  List<CategoryModel> get categories => _categories;
  List<CityModel> get cities => _cities;
  EventModel? get event => _event;

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
      _event = await _eventService.getEvent(eventId);
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
}
