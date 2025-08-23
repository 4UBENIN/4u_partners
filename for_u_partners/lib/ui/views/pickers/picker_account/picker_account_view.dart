import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'picker_account_viewmodel.dart';

class PickerAccountView extends StackedView<PickerAccountViewModel> {
  const PickerAccountView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    PickerAccountViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
        child: const Center(child: Text("PickerAccountView")),
      ),
    );
  }

  @override
  PickerAccountViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      PickerAccountViewModel();
}
