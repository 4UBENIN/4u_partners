import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:for_u_partners/services/driver_service.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/views/drivers/courses/courses_view.dart';
import 'package:for_u_partners/ui/views/drivers/courses/courses_viewmodel.dart';
import 'package:for_u_partners/ui/views/drivers/profil/profil_view.dart';
import 'package:for_u_partners/ui/views/drivers/activity/activity_view.dart';
import 'package:for_u_partners/ui/views/drivers/notifications/notifications_view.dart';
import 'package:for_u_partners/ui/views/drivers/wallet/wallet_view.dart';
import 'package:stacked_services/stacked_services.dart';
import 'dart:io';

class HomemainViewModel extends IndexTrackingViewModel {
  final _sharedpreferencesService = locator<SharedpreferencesService>();
  final _navigationService = locator<NavigationService>();
  final _driverService = locator<DriverService>();

  // Référence au CoursesViewModel pour notifier les changements de statut
  CoursesViewModel? _coursesViewModel;

  void setCoursesViewModel(CoursesViewModel viewModel) {
    _coursesViewModel = viewModel;
  }

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

  // Notifier le changement de statut en ligne au CoursesViewModel
  Future<void> notifyOnlineStatusChanged(bool isOnline) async {
    _isOnline = isOnline;
    notifyListeners();

    // Notify courses view to start/stop general position tracking
    if (_coursesViewModel != null) {
      await _coursesViewModel!.onDriverOnlineStatusChanged(isOnline);
    }
  }

  getViewFromIndex(int index) {
    switch (index) {
      case 0:
        return const CoursesView();
      case 1:
        return const ActivityView();
      case 2:
        return const WalletView();
      case 3:
        return const NotificationsView();
      case 4:
        return const ProfilView();
      default:
        return const CoursesView();
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
    closeNavigation();

    // Handle special cases (Documents and Logout)
    if (index == 5) {
      // Navigate to Documents
      _navigationService.navigateToDocumentsView();
      return;
    }

    if (index == 6) {
      // Show logout confirmation dialog
      _showLogoutConfirmationDialog();
      return;
    }

    // Handle normal navigation
    if (currentIndex != index) {
      setIndex(index);
    }
  }

  void _showLogoutConfirmationDialog() {
    if (Platform.isIOS) {
      _showCupertinoLogoutDialog();
    } else {
      _showMaterialLogoutDialog();
    }
  }

  Future<void> logOut() async {
    try {
      print("logout: setting status to false");
      await _driverService.updateStatus(false);
      await _sharedpreferencesService.setOnlineStatus(false);
      print("logout: status updated successfully");
    } catch (e) {
      print("logout: error updating status: $e");
    }
    _sharedpreferencesService.removeToken();
    _navigationService.replaceWithLoginView();
  }

  void _showMaterialLogoutDialog() {
    final context = _navigationService.navigatorKey?.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.logout_rounded, color: Colors.red[600], size: 24),
                const SizedBox(width: 12),
                const Text('Déconnexion', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              ],
            ),
            content: const Text(
              'Êtes-vous sûr de vouloir vous déconnecter de votre compte ?',
              style: TextStyle(fontSize: 16),
            ),
            contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text('Annuler', style: TextStyle(fontWeight: FontWeight.w500)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  logOut();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Se déconnecter', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          );
        },
      );
    }
  }

  void _showCupertinoLogoutDialog() {
    final context = _navigationService.navigatorKey?.currentContext;
    context?.let((ctx) {
      showCupertinoDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Déconnexion', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            content: const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Êtes-vous sûr de vouloir vous déconnecter de votre compte ?',
                style: TextStyle(fontSize: 13),
              ),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler', style: TextStyle(color: CupertinoColors.activeBlue, fontWeight: FontWeight.w400)),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.of(context).pop();
                  logOut();
                },
                child: const Text('Se déconnecter', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          );
        },
      );
    });
  }
}

extension NullableContextExtension on BuildContext? {
  void let(void Function(BuildContext) block) {
    if (this != null) {
      block(this!);
    }
  }
}
