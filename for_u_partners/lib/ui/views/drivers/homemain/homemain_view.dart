import 'homemain_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:badges/badges.dart' as badges;

class HomemainView extends StackedView<HomemainViewModel> {
  const HomemainView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    HomemainViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
        body: viewModel.getViewFromIndex(viewModel.currentIndex),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: kcWhiteColors,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: kcPrimaryColor,
          unselectedItemColor: kcLightGrey,
          selectedFontSize: 13,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(),
          currentIndex: viewModel.currentIndex,
          items: [
            BottomNavigationBarItem(
              icon: viewModel.buildNavItem("assets/Home.png", 0, viewModel),
              label: "Acceuil",
            ),
            BottomNavigationBarItem(
              icon: viewModel.buildNavItem("assets/refresh.png", 1, viewModel),
              label: "Activités",
            ),
            BottomNavigationBarItem(
              icon: viewModel.pendingCoursesCount > 0
                  ? badges.Badge(
                      position: badges.BadgePosition.topEnd(top: -10, end: -10),
                      badgeContent: Text(
                        '${viewModel.pendingCoursesCount}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                      child: const Icon(Icons.map_outlined, color: kcLightGrey),
                    )
                  : const Icon(Icons.map_outlined, color: kcLightGrey),
              label: "Courses",
              activeIcon: viewModel.pendingCoursesCount > 0
                  ? badges.Badge(
                      position: badges.BadgePosition.topEnd(top: -10, end: -10),
                      badgeContent: Text(
                        '${viewModel.pendingCoursesCount}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                      child:
                          const Icon(Icons.map_outlined, color: kcPrimaryColor),
                    )
                  : const Icon(Icons.map_outlined, color: kcPrimaryColor),
            ),
            BottomNavigationBarItem(
              icon: viewModel.buildNavItem("assets/Bell.png", 3, viewModel),
              label: "Notifications",
            ),
            BottomNavigationBarItem(
              icon: viewModel.buildNavItem("assets/user.png", 4, viewModel),
              label: "Compte",
            ),
          ],
          onTap: viewModel.setIndex,
        ));
  }

  @override
  HomemainViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      HomemainViewModel();
}
