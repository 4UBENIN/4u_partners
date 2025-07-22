import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'notifications_pressing_viewmodel.dart';

class NotificationsPressingView
    extends StackedView<NotificationsPressingViewModel> {
  const NotificationsPressingView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    NotificationsPressingViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
        child: const Center(child: Text("NotificationsPressingView")),
      ),
    );
  }

  @override
  NotificationsPressingViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      NotificationsPressingViewModel();
}
