import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/views/drivers/home/home_view.dart';
import 'package:for_u_partners/ui/views/drivers/profil/profil_view.dart';
import 'package:for_u_partners/ui/views/drivers/courses/courses_view.dart';
import 'package:for_u_partners/ui/views/drivers/activity/activity_view.dart';
import 'package:for_u_partners/ui/views/drivers/notifications/notifications_view.dart';

class HomemainViewModel extends IndexTrackingViewModel {
  // Compteur de courses en attente
  int _pendingCoursesCount = 0;

  int get pendingCoursesCount => _pendingCoursesCount;

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
        return const NotificationsView();
      case 4:
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
}
