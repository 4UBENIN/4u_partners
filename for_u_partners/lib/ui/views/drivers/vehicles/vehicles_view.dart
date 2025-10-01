import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/views/drivers/vehicles/vehicles_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked_annotations.dart';

@StackedApp(
  routes: [
    MaterialRoute(page: VehiclesView, initial: true),
  ],
)
class VehiclesView extends StackedView<VehiclesViewModel> {
  const VehiclesView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    VehiclesViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes véhicules'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: const Center(
        child: Text('Gestion des véhicules'),
      ),
    );
  }

  @override
  VehiclesViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      VehiclesViewModel();
}
