import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'activities_delivery_viewmodel.dart';

class ActivitiesDeliveryView extends StackedView<ActivitiesDeliveryViewModel> {
  const ActivitiesDeliveryView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ActivitiesDeliveryViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
        child: const Center(child: Text("ActivitiesDeliveryView")),
      ),
    );
  }

  @override
  ActivitiesDeliveryViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ActivitiesDeliveryViewModel();
}
