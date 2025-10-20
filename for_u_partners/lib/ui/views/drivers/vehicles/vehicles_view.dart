import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'vehicles_viewmodel.dart';
import '../../../../models/vehicle_model.dart';

class MesVehiculesView extends StatelessWidget {
  const MesVehiculesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MesVehiculesViewModel>.reactive(
      viewModelBuilder: () => MesVehiculesViewModel(),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, viewModel, _) => _MesVehiculesViewContent(viewModel: viewModel),
    );
  }
}

class _MesVehiculesViewContent extends StatelessWidget {
  final MesVehiculesViewModel viewModel;

  const _MesVehiculesViewContent({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _MesVehiculesView(viewModel: viewModel);
  }
}

class _MesVehiculesView extends StatelessWidget {
  final MesVehiculesViewModel viewModel;
  
  const _MesVehiculesView({Key? key, required this.viewModel}) : super(key: key);

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'en_attente':
        return 'En attente de validation';
      case 'actif':
      case 'active':
        return 'Actif';
      case 'rejete':
      case 'rejeté':
        return 'Rejeté';
      default:
        return status ?? 'Non spécifié';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mes Véhicules',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: viewModel.isBusy
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF184E9C)))
          : viewModel.errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 60, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          viewModel.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => viewModel.initialise(),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header avec image
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16), // espace à gauche et à droite
                        padding: const EdgeInsets.all(12),
                        height: 170,
                        decoration:  BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF184E9C), Color(0xFF2A5BB8)],
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
                                        color: const Color(0xFF184E9C),
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
                              if (viewModel.vehiculesApprouves.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Icon(Icons.directions_car_outlined,
                                            size: 48, color: Colors.grey[400]),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Aucun véhicule actif',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                ...viewModel.vehiculesApprouves
                                    .map((vehicle) =>
                                        _buildApprovedVehicleCard(vehicle))
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
            backgroundColor: const Color(0xFF184E9C),
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
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.directions_car_outlined,
                  size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'Aucun véhicule actif',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    final vehicle = viewModel.vehiculeActif!;
    final categorie = vehicle.categorie?.toLowerCase();

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
                      '${vehicle.marque} ${vehicle.model}',
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
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.category, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          vehicle.categorie?.toUpperCase() ?? 'N/A',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.color_lens, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          vehicle.couleur?.isNotEmpty == true 
                              ? '${vehicle.couleur![0].toUpperCase()}${vehicle.couleur!.substring(1).toLowerCase()}'
                              : 'N/A',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF184E9C).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF184E9C),
                  size: 24,
                ),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),
          
          // Course à l'heure (toujours visible)
          _buildServiceToggle(
            icon: Icons.schedule,
            label: 'Course à l\'heure',
            isActive: vehicle.courseHeure,
            onToggle: (value) => viewModel.toggleCourseHeure(value),
          ),
          const SizedBox(height: 16),
          
          // Section Basic
          if (categorie == 'vip')
            // VIP : Basic verrouillé
            _buildServiceOption(
              icon: Icons.local_taxi,
              label: 'Basic',
              hasInfo: true,
              isLocked: true,
            )
          else
            // PREMIUM et STANDARD : Basic activable
            _buildServiceToggle(
              icon: Icons.local_taxi,
              label: 'Basic',
              isActive: vehicle.basic ?? false,
              hasInfo: true,
              onToggle: (value) => viewModel.toggleBasic(value),
            ),
          
          // Section Premium (uniquement pour VIP)
          if (categorie == 'vip') ...[
            const SizedBox(height: 16),
            _buildServiceToggle(
              icon: Icons.workspace_premium,
              label: 'Premium',
              isActive: vehicle.premium ?? false,
              hasInfo: true,
              onToggle: (value) => viewModel.togglePremium(value),
            ),
          ],
          
          // Section Clim (PREMIUM et VIP uniquement)
          if (categorie == 'premium' || categorie == 'vip') ...[
            const SizedBox(height: 16),
            _buildServiceToggle(
              icon: Icons.ac_unit,
              label: 'Clim',
              isActive: vehicle.clim,
              hasInfo: true,
              onToggle: (value) => viewModel.toggleClim(value),
            ),
          ],
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${vehicle.marque} ${vehicle.model}',
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
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.category, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    if (vehicle.categorie?.isNotEmpty == true)
                      Text(
                        vehicle.categorie!.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[800],
                        ),
                      ),
                    const SizedBox(width: 12),
                    Icon(Icons.color_lens, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    if (vehicle.couleur?.isNotEmpty == true)
                      Text(
                        '${vehicle.couleur![0].toUpperCase()}${vehicle.couleur!.substring(1).toLowerCase()}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[800],
                        ),
                      ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (vehicle.statut?.toLowerCase() == 'en_attente')
                            ? Colors.orange[50]
                            : Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: (vehicle.statut?.toLowerCase() == 'en_attente')
                              ? Colors.orange[200]!
                              : Colors.green[200]!,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getStatusText(vehicle.statut),
                        style: TextStyle(
                          fontSize: 10,
                          color: (vehicle.statut?.toLowerCase() == 'en_attente')
                              ? Colors.orange[800]
                              : Colors.green[800],
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
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
          Icon(Icons.info_outline, size: 16, color: Colors.blue[400]),
        ],
        const Spacer(),
        Switch(
          value: isActive,
          onChanged: onToggle,
          activeColor: const Color(0xFF184E9C),
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