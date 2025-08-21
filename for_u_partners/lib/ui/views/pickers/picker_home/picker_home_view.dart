import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'picker_home_viewmodel.dart';

class PickerHomeView extends StackedView<PickerHomeViewModel> {
  const PickerHomeView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    PickerHomeViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
        child: const Center(child: Text("PickerHomeView")),
      ),
    );
  }

  @override
  PickerHomeViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      PickerHomeViewModel();
}
