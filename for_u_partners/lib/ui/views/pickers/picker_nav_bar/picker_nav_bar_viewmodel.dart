import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/views/pickers/picker_account/picker_account_view.dart';
import 'package:for_u_partners/ui/views/pickers/picker_activities/picker_activities_view.dart';
import 'package:for_u_partners/ui/views/pickers/picker_courses/picker_courses_view.dart';
import 'package:for_u_partners/ui/views/pickers/picker_home/picker_home_view.dart';
import 'package:for_u_partners/ui/views/pickers/picker_notifications/picker_notifications_view.dart';
import 'package:stacked/stacked.dart';

class PickerNavBarViewModel extends BaseViewModel {
  int selectedIndex = 0;

  getViewFromIndex(int index) {
    switch (index) {
      case 0:
        return const PickerHomeView();
      case 1:
        return const PickerActivitiesView();
      case 2:
        return const PickerCoursesView();
      case 3:
        return const PickerNotificationsView();
      case 4:
        return const PickerAccountView();
      default:
        return const PickerHomeView();
    }
  }

  setIndex(int index) {
    selectedIndex = index;
    rebuildUi();
  }

  buildNavItem(String assetName, int index, PickerNavBarViewModel viewModel) {
    return Image.asset(
      assetName,
      height: 22,
      width: 22,
      color: viewModel.selectedIndex == index ? kcPrimaryColor : kcLightGrey,
    );
  }
}
