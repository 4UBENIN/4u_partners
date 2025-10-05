// mes_vehicules_view.dart
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../../ui/common/app_colors.dart';

class VehiclesView extends StackedView<MesVehiculesViewModel> {
  const VehiclesView({Key? key}) : super(key: key);

  @override
  MesVehiculesViewModel viewModelBuilder(BuildContext context) {
    final viewModel = MesVehiculesViewModel();
    viewModel.initialise();
    return viewModel;
  }

  @override
  Widget builder(
    BuildContext context,
    MesVehiculesViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header avec image
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, primaryColorDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          bottom: -10,
                          child: Icon(
                            Icons.directions_car,
                            size: 140,
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Mes Véhicules',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Gérez vos véhicules et les services qui y sont liés.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Véhicule actif
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Véhicule actif',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildActiveVehicleCard(viewModel),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Véhicules approuvés
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Véhicules approuvés',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${viewModel.vehiculesApprouves.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(
                                viewModel.isApprovedExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                              ),
                              onPressed: viewModel.toggleApprovedExpanded,
                            ),
                          ],
                        ),
                        if (viewModel.isApprovedExpanded) ...[
                          const SizedBox(height: 12),
                          ...viewModel.vehiculesApprouves
                              .map((vehicle) => _buildApprovedVehicleCard(vehicle))
                              .toList(),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
      floatingActionButton: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          onPressed: viewModel.addNewVehicle,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: const Text(
            'Ajouter un nouveau véhicule',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildActiveVehicleCard(MesVehiculesViewModel viewModel) {
    if (viewModel.vehiculeActif == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text('Aucun véhicule actif'),
        ),
      );
    }

    final vehicle = viewModel.vehiculeActif!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.model,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vehicle.immatriculation,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: primaryColor,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          _buildServiceToggle(
            icon: Icons.schedule,
            label: 'Course à l\'heure',
            isActive: vehicle.courseHeure,
            onToggle: (value) => viewModel.toggleCourseHeure(value),
          ),
          const SizedBox(height: 16),
          _buildServiceOption(
            icon: Icons.local_taxi,
            label: 'Basic',
            hasInfo: true,
            isLocked: true,
          ),
          const SizedBox(height: 16),
          _buildServiceToggle(
            icon: Icons.ac_unit,
            label: 'Clim',
            isActive: vehicle.clim,
            hasInfo: true,
            onToggle: (value) => viewModel.toggleClim(value),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovedVehicleCard(Vehicle vehicle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.model,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  vehicle.immatriculation,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!, width: 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceToggle({
    required IconData icon,
    required String label,
    required bool isActive,
    bool hasInfo = false,
    required Function(bool) onToggle,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 15),
        ),
        if (hasInfo) ...[
          const SizedBox(width: 4),
          Icon(Icons.info_outline, size: 16, color: primaryColor.withOpacity(0.8)),
        ],
        const Spacer(),
        Switch(
          value: isActive,
          onChanged: onToggle,
          activeColor: primaryColor,
        ),
      ],
    );
  }

  Widget _buildServiceOption({
    required IconData icon,
    required String label,
    bool hasInfo = false,
    bool isLocked = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 15),
        ),
        if (hasInfo) ...[
          const SizedBox(width: 4),
          Icon(Icons.info_outline, size: 16, color: Colors.blue[400]),
        ],
        const Spacer(),
        if (isLocked)
          Icon(Icons.lock_outline, size: 20, color: Colors.grey[400]),
      ],
    );
  }

}

// mes_vehicules_viewmodel.dart
class MesVehiculesViewModel extends BaseViewModel {
  Vehicle? _vehiculeActif;
  List<Vehicle> _vehiculesApprouves = [];
  bool _isApprovedExpanded = true;

  Vehicle? get vehiculeActif => _vehiculeActif;
  List<Vehicle> get vehiculesApprouves => _vehiculesApprouves;
  bool get isApprovedExpanded => _isApprovedExpanded;

  Future<void> initialise() async {
    setBusy(true);
    // Ici vous appellerez votre API pour récupérer les données
    // Exemple:
    // _vehiculeActif = await _apiService.getVehiculeActif();
    // _vehiculesApprouves = await _apiService.getVehiculesApprouves();
    setBusy(false);
  }

  void toggleApprovedExpanded() {
    _isApprovedExpanded = !_isApprovedExpanded;
    notifyListeners();
  }

  void toggleCourseHeure(bool value) {
    if (_vehiculeActif != null) {
      _vehiculeActif!.courseHeure = value;
      notifyListeners();
      // Appel API pour mettre à jour
    }
  }

  void toggleClim(bool value) {
    if (_vehiculeActif != null) {
      _vehiculeActif!.clim = value;
      notifyListeners();
      // Appel API pour mettre à jour
    }
  }

  void addNewVehicle() {
    // Navigation vers la page d'ajout de véhicule
    print('Ajouter un nouveau véhicule');
  }
}

// vehicle_model.dart
class Vehicle {
  final String id;
  final String model;
  final String immatriculation;
  bool courseHeure;
  bool clim;

  Vehicle({
    required this.id,
    required this.model,
    required this.immatriculation,
    this.courseHeure = false,
    this.clim = false,
  });
}