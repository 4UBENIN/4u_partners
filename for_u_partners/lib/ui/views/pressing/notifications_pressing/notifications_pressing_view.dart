import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'notifications_pressing_viewmodel.dart';
import 'package:for_u_partners/ui/common/text_component.dart';
import 'package:for_u_partners/ui/views/drivers/notifications/widget/notification_widget.dart';

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
        backgroundColor: Colors.white,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            title: const TextComponent("Notifications")),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              notificationsCard(
                "Aujourd'hui - 14:20",
                "Simplifiez vos déplacements 👍🏾, utilisez notre service de transport ! 🚙",
              ),
              notificationsCard(
                "Aujourd'hui - 18:20",
                "Votre maison ou tout autre espace a besoin d'entretien 🧐 ? Pas de soucis, nous sommes la ! 🪣",
              )
            ],
          ),
        ));
  }

  @override
  NotificationsPressingViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      NotificationsPressingViewModel();
}
