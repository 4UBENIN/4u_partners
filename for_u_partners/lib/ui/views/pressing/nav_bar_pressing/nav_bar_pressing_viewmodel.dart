import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/views/pressing/home_pressing/home_pressing_view.dart';
import 'package:for_u_partners/ui/views/pressing/compte_pressing/compte_pressing_view.dart';
import 'package:for_u_partners/ui/views/pressing/activites_pressing/activites_pressing_view.dart';
import 'package:for_u_partners/ui/views/pressing/notifications_pressing/notifications_pressing_view.dart';

class NavBarPressingViewModel extends BaseViewModel {
  int selectedIndex = 0;

  getViewFromIndex(int index) {
    switch (index) {
      case 0:
        return const HomePressingView();
      case 1:
        return const ActivitesPressingView();
      case 2:
        return const NotificationsPressingView();
      case 3:
        return const ComptePressingView();
      default:
        return const HomePressingView();
    }
  }

  setIndex(int index) {
    selectedIndex = index;
    rebuildUi();
  }

  buildNavItem(String assetName, int index, NavBarPressingViewModel viewModel) {
    return Image.asset(
      assetName,
      height: 22,
      width: 22,
      color: viewModel.selectedIndex == index ? kcPrimaryColor : kcLightGrey,
    );
  }
}
