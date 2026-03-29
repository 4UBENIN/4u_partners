import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/views/delivery/delivery_home/delivery_home_view.dart';
import 'package:for_u_partners/ui/views/delivery/compte_delivery/compte_delivery_view.dart';
import 'package:for_u_partners/ui/views/delivery/courses_delivery/courses_delivery_view.dart';
import 'package:for_u_partners/ui/views/delivery/activities_delivery/activities_delivery_view.dart';
import 'package:for_u_partners/ui/views/delivery/notifications_delivery/notifications_delivery_view.dart';

class DeliveryNavBarViewModel extends BaseViewModel {
  int selectedIndex = 0;

  getViewFromIndex(int index) {
    switch (index) {
      case 0:
        return const DeliveryHomeView();
      case 1:
        return const ActivitiesDeliveryView();
      case 2:
        return const CoursesDeliveryView();
      case 3:
        return const NotificationsDeliveryView();
      case 4:
        return const CompteDeliveryView();
      default:
        return const DeliveryHomeView();
    }
  }

  setIndex(int index) {
    selectedIndex = index;
    rebuildUi();
  }

  buildNavItem(String assetName, int index, DeliveryNavBarViewModel viewModel) {
    return Image.asset(
      assetName,
      height: 22,
      width: 22,
      color: viewModel.selectedIndex == index ? kcPrimaryColor : kcLightGrey,
    );
  }
}
