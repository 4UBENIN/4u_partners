import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'nav_bar_pressing_viewmodel.dart';

class NavBarPressingView extends StackedView<NavBarPressingViewModel> {
  const NavBarPressingView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    NavBarPressingViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
        child: const Center(child: Text("NavBarPressingView")),
      ),
    );
  }

  @override
  NavBarPressingViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      NavBarPressingViewModel();
}
