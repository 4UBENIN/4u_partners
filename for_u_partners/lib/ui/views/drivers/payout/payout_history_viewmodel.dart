import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/services/payout_service.dart';
import 'package:for_u_partners/app/models/payout_model.dart';

class PayoutHistoryViewModel extends BaseViewModel {
  final _payoutService = locator<PayoutService>();
  final _navigationService = locator<NavigationService>();

  List<PayoutModel> _payouts = [];
  List<PayoutModel> get payouts => _payouts;

  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMoreData = false;
  bool get hasMoreData => _hasMoreData;

  String? _selectedStatusFilter;
  String? get selectedStatusFilter => _selectedStatusFilter;

  final List<Map<String, String>> statusFilters = [
    {'value': '', 'label': 'Tous'},
    {'value': 'pending', 'label': 'En attente'},
    {'value': 'started', 'label': 'En cours'},
    {'value': 'sent', 'label': 'Envoyé'},
    {'value': 'success', 'label': 'Réussi'},
    {'value': 'failed', 'label': 'Échoué'},
  ];

  Future<void> initialize() async {
    await loadPayouts();
  }

  Future<void> loadPayouts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _payouts = [];
    }

    setBusy(true);
    try {
      final response = await _payoutService.listPayouts(
        page: _currentPage,
        perPage: 20,
        status: _selectedStatusFilter,
        live: false,
      );

      if (refresh) {
        _payouts = response.data;
      } else {
        _payouts.addAll(response.data);
      }

      _totalPages = (response.total / response.perPage).ceil();
      _hasMoreData = _currentPage < _totalPages;

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading payouts: $e');
      // Error will be shown in UI or can be handled differently
      // We don't have context here, so we can't show toast
    } finally {
      setBusy(false);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMoreData || isBusy) return;

    _currentPage++;
    await loadPayouts();
  }

  Future<void> refresh() async {
    await loadPayouts(refresh: true);
  }

  void setStatusFilter(String? status) {
    _selectedStatusFilter = status;
    notifyListeners();
    loadPayouts(refresh: true);
  }

  void navigateToCreatePayout() {
    _navigationService.navigateTo(Routes.createPayoutView);
  }

  void navigateToPayoutDetails(PayoutModel payout) {
    // Navigate to payout details view with live data
    // You can implement this later if needed
    debugPrint('Navigate to payout details: ${payout.id}');
  }

  Color getStatusColor(PayoutModel payout) {
    if (payout.isSuccess) return const Color(0xFF34C759);
    if (payout.isFailed) return const Color(0xFFFF3B30);
    if (payout.isSent) return const Color(0xFF007AFF);
    if (payout.isStarted) return const Color(0xFFFF9500);
    return const Color(0xFF8E8E93);
  }

  IconData getStatusIcon(PayoutModel payout) {
    if (payout.isSuccess) return Icons.check_circle;
    if (payout.isFailed) return Icons.error;
    if (payout.isSent) return Icons.send;
    if (payout.isStarted) return Icons.pending;
    return Icons.pending;
  }
}
