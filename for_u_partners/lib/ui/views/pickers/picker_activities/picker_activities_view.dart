import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'picker_activities_viewmodel.dart';

class PickerActivitiesView extends StackedView<PickerActivitiesViewModel> {
  const PickerActivitiesView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    PickerActivitiesViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
        child: const Center(child: Text("PickerActivitiesView")),
      ),
    );
  }

  @override
  PickerActivitiesViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      PickerActivitiesViewModel();
}
