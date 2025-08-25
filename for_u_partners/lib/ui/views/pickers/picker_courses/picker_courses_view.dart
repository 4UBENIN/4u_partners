import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'picker_courses_viewmodel.dart';

class PickerCoursesView extends StackedView<PickerCoursesViewModel> {
  const PickerCoursesView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    PickerCoursesViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
        child: const Center(child: Text("PickerCoursesView")),
      ),
    );
  }

  @override
  PickerCoursesViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      PickerCoursesViewModel();
}
