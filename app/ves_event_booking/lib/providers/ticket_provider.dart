import 'package:flutter/material.dart';
import 'package:ves_event_booking/enums/ticket_status.dart';
import 'package:ves_event_booking/models/ticket/ticket_model.dart';
import 'package:ves_event_booking/models/user/user_model.dart';
import 'package:ves_event_booking/models/utils/pagination_request.dart';
import 'package:ves_event_booking/models/zalopay/zalopay_model_request.dart';
import 'package:ves_event_booking/models/zalopay/zalopay_response.dart';
import 'package:ves_event_booking/services/ticket_service.dart';
import 'package:ves_event_booking/services/user_service.dart';

class TicketProvider extends ChangeNotifier {
  final TicketService _ticketService = TicketService();
  final UserService _userService = UserService();

  bool _isLoading = false;
  String? _errorMessage;
  List<TicketModel> _tickets = [];
  UserModel? _user;
  ZalopayResponse? _zalopayOrder;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TicketModel> get tickets => _tickets;
  UserModel? get user => _user;
  ZalopayResponse? get zalopayOrder => _zalopayOrder;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchTickets(TicketStatus ticketStatus) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _ticketService.getTickets(
        ticketStatus,
        PaginationRequest(page: 0, size: 20),
      );
      _tickets = response.content;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserInfo() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _userService.getMyInfo();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createZalopayOrder(ZalopayModelRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    _zalopayOrder = null;
    notifyListeners();

    try {
      _zalopayOrder = await _ticketService.purchaseTicket(request);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
