import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'notifications_delivery_viewmodel.dart';

class NotificationsDeliveryView
    extends StackedView<NotificationsDeliveryViewModel> {
  const NotificationsDeliveryView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    NotificationsDeliveryViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
        child: const Center(child: Text("NotificationsDeliveryView")),
      ),
    );
  }

  @override
  NotificationsDeliveryViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      NotificationsDeliveryViewModel();
}
