import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'notifications_delivery_viewmodel.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/common/text_component.dart';
import 'package:for_u_partners/ui/views/drivers/notifications/widget/notification_widget.dart';

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
        backgroundColor: Colors.white,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            title: const TextComponent(
              "Notifications",
              fontsize: 18,
              textcolor: primaryColor,
              fontweight: FontWeight.bold,
            )),
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
  NotificationsDeliveryViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      NotificationsDeliveryViewModel();
}
