import 'package:stacked/stacked.dart';
import 'package:flutter/cupertino.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/views/home/home_view.dart';
import 'package:for_u_partners/ui/views/profil/profil_view.dart';
import 'package:for_u_partners/ui/views/courses/courses_view.dart';
import 'package:for_u_partners/ui/views/activity/activity_view.dart';

class HomemainViewModel extends IndexTrackingViewModel {
  getViewFromIndex(int index) {
    switch (index) {
      case 0:
        return const HomeView();
      case 1:
        return const ActivityView();
      case 2:
        return const CoursesView();
      case 3:
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
