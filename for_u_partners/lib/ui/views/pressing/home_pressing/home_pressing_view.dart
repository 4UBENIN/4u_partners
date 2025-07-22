import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'home_pressing_viewmodel.dart';

class HomePressingView extends StackedView<HomePressingViewModel> {
  const HomePressingView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    HomePressingViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
        child: const Center(child: Text("HomePressingView")),
      ),
    );
  }

  @override
  HomePressingViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      HomePressingViewModel();
}
