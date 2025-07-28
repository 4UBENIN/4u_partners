import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'compte_delivery_viewmodel.dart';

class CompteDeliveryView extends StackedView<CompteDeliveryViewModel> {
  const CompteDeliveryView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    CompteDeliveryViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
        child: const Center(child: Text("CompteDeliveryView")),
      ),
    );
  }

  @override
  CompteDeliveryViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      CompteDeliveryViewModel();
}
