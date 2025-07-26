import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'nav_bar_pressing_viewmodel.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';


class NavBarPressingView extends StackedView<NavBarPressingViewModel> {
  const NavBarPressingView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    NavBarPressingViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      body: viewModel.getViewFromIndex(viewModel.selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: kcWhiteColors,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kcPrimaryColor,
        unselectedItemColor: kcLightGrey,
        selectedFontSize: 13,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(),
        currentIndex: viewModel.selectedIndex,
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
              icon: viewModel.buildNavItem("assets/Bell.png", 2, viewModel),
              label: "Notifications",
            ),
            BottomNavigationBarItem(
              icon: viewModel.buildNavItem("assets/user.png", 3, viewModel),
              label: "Compte",
            ),
        ],
        onTap: viewModel.setIndex,
      ),
    );
  }

  @override
  NavBarPressingViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      NavBarPressingViewModel();
}
