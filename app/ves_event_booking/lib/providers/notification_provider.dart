import 'package:flutter/material.dart';
import 'package:ves_event_booking/models/notification/notification_model.dart';
import 'package:ves_event_booking/models/utils/pagination_request.dart';
import 'package:ves_event_booking/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  bool _isLoading = false;
  String? _errorMessage;
  List<NotificationModel> _eventNotifications = [];
  List<NotificationModel> _offerNotifications = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<NotificationModel> get eventNotifications => _eventNotifications;
  List<NotificationModel> get offerNotifications => _offerNotifications;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final pageResult = await _notificationService.getNotifications(
        pageable: PaginationRequest(page: 0, size: 20),
      );

      _eventNotifications = pageResult.content
          .where((notification) => notification.type == 'event')
          .toList();

      _offerNotifications = pageResult.content
          .where((notification) => notification.type == 'offer')
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
