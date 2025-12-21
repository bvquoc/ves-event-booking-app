import 'package:dio/dio.dart';
import 'package:ves_event_booking/models/notification/notification_model.dart';
import 'package:ves_event_booking/models/utils/api_response.dart';
import 'package:ves_event_booking/models/utils/pagination_request.dart';

class NotificationService {
  final Dio _dio = Dio();

  Future<NotificationModel> getNotifications({
    required PaginationRequest pageable,
    bool unreadOnly = false,
  }) async {
    try {
      final response = await _dio.get(
        '/notifications',
        queryParameters: {
          'unreadOnly': unreadOnly,
          ...pageable.toQueryParams(),
        },
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => NotificationModel.fromJson(json),
      );

      return apiResponse.result;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to fetch notifications',
      );
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _dio.put('/notifications/$notificationId/read');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to mark notification as read',
      );
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      await _dio.put('/notifications/read-all');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            'Failed to mark all notifications as read',
      );
    }
  }
}
