import 'package:flutter/material.dart';
import 'package:ves_event_booking/enums/ticket_status.dart';
import 'package:ves_event_booking/models/pagination_request.dart';
import 'package:ves_event_booking/models/ticket_model.dart';
import 'package:ves_event_booking/services/ticket_service.dart';

class TicketProvider extends ChangeNotifier {
  final TicketService _ticketService = TicketService();

  bool _isLoading = false;
  String? _errorMessage;
  List<TicketModel> _tickets = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TicketModel> get tickets => _tickets;

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
}
