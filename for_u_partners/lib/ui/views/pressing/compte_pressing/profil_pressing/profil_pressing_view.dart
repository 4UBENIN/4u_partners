import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/common/text_component.dart';
import 'package:stacked/stacked.dart';

import 'profil_pressing_viewmodel.dart';

class ProfilPressingView extends StackedView<ProfilPressingViewModel> {
  const ProfilPressingView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ProfilPressingViewModel viewModel,
    Widget? child,
  ) {
    if (viewModel.isBusy) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pressing = viewModel.pressing;

    if (pressing == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
            title: const Text("Profil Pressing"),
            backgroundColor: backgroundColor),
        body: const Center(child: Text("Aucune information trouvée")),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
          title: const Text("Profil Pressing"),
          backgroundColor: backgroundColor),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextComponent("Nom : ${pressing.nom}", fontsize: 18),
            const SizedBox(height: 10),
            TextComponent("Email : ${pressing.email}"),
            const SizedBox(height: 10),
            TextComponent("Téléphone : ${pressing.telephone}"),
            const SizedBox(height: 10),
            TextComponent("Adresse : ${pressing.adresse}"),
            const SizedBox(height: 10),
            TextComponent(
                "Statut : ${pressing.statutValidation.toUpperCase()}"),
            const SizedBox(height: 10),
            TextComponent("Inscrit le : ${pressing.createdAt}"),
          ],
        ),
      ),
    );
  }

  @override
  ProfilPressingViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ProfilPressingViewModel();
}
