import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'delivery_nav_bar_viewmodel.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';

class DeliveryNavBarView extends StackedView<DeliveryNavBarViewModel> {
  const DeliveryNavBarView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    DeliveryNavBarViewModel viewModel,
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
          const BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: "Courses",
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
      ),
    );
  }

  @override
  DeliveryNavBarViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      DeliveryNavBarViewModel();
}
