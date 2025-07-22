import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'compte_pressing_viewmodel.dart';

class ComptePressingView extends StackedView<ComptePressingViewModel> {
  const ComptePressingView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ComptePressingViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
        child: const Center(child: Text("ComptePressingView")),
      ),
    );
  }

  @override
  ComptePressingViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ComptePressingViewModel();
}
