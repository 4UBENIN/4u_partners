import 'profil_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';

class ProfilView extends StackedView<ProfilViewModel> {
  const ProfilView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ProfilViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
        child: const Center(child: Text("ProfilView")),
      ),
    );
  }

  @override
  ProfilViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ProfilViewModel();
}
