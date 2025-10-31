import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/views/drivers/home/home_view.dart';
import 'package:for_u_partners/ui/views/drivers/profil/profil_view.dart';
import 'package:for_u_partners/ui/views/drivers/courses/courses_view.dart';
import 'package:for_u_partners/ui/views/drivers/activity/activity_view.dart';
import 'package:for_u_partners/ui/views/drivers/notifications/notifications_view.dart';
import 'package:for_u_partners/ui/views/drivers/wallet/wallet_view.dart';

class HomemainViewModel extends IndexTrackingViewModel {
  final _sharedpreferencesService = locator<SharedpreferencesService>();

  // Compteur de courses en attente
  int _pendingCoursesCount = 0;

  int get pendingCoursesCount => _pendingCoursesCount;
  bool _isNavigationOpen = false;

  bool get isNavigationOpen => _isNavigationOpen;

  // User data
  String? _userName;
  bool _isOnline = false;

  String? get userName => _userName;
  bool get isOnline => _isOnline;

  HomemainViewModel() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _userName = await _sharedpreferencesService.getUserName();
    _isOnline = await _sharedpreferencesService.getOnlineStatus() ?? false;
    notifyListeners();
  }

  // Mettre à jour le compteur de courses en attente
  void updatePendingCoursesCount(int count) {
    _pendingCoursesCount = count;
    notifyListeners();
  }

  getViewFromIndex(int index) {
    switch (index) {
      case 0:
        return const HomeView();
      case 1:
        return const ActivityView();
      case 2:
        return const CoursesView();
      case 3:
        return const WalletView();
      case 4:
        return const NotificationsView();
      case 5:
        return const ProfilView();
      default:
        return const HomeView();
    }
  }

  buildNavItem(String assetName, int index, HomemainViewModel viewModel) {
    return Image.asset(
      assetName,
      height: 22,
      width: 22,
      color: viewModel.currentIndex == index ? kcPrimaryColor : kcLightGrey,
    );
  }

  void toggleNavigation() {
    _isNavigationOpen = !_isNavigationOpen;
    if (_isNavigationOpen) {
      _loadUserData(); // Refresh user data when opening
    }
    notifyListeners();
  }

  void openNavigation() {
    if (_isNavigationOpen) return;
    _isNavigationOpen = true;
    _loadUserData(); // Refresh user data when opening
    notifyListeners();
  }

  void closeNavigation() {
    if (!_isNavigationOpen) return;
    _isNavigationOpen = false;
    notifyListeners();
  }

  void handleNavigationSelection(int index) {
    if (currentIndex != index) {
      setIndex(index);
    }
    closeNavigation();
  }
}
