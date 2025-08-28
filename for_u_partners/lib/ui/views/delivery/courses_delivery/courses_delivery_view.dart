import 'package:for_u_partners/ui/common/app_textInput.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'courses_delivery_viewmodel.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/app/models/ramasseur_models/ramasseur_demand_model.dart';

class CoursesDeliveryView extends StackedView<CoursesDeliveryViewModel> {
  const CoursesDeliveryView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    CoursesDeliveryViewModel viewModel,
    Widget? child,
  ) {
    const primaryColor = Color(0xFF184E9C);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFE),
      body: viewModel.isBusy || viewModel.isLoadingDemandes
          ? _buildLoadingState()
          : viewModel.userRole == "ramasseur"
              ? _buildRamasseurContent(viewModel, context, primaryColor)
              : _buildEmptyState("Accès non autorisé", Icons.lock_outline),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8FAFE),
            Color(0xFFEEF5FF),
          ],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF184E9C)),
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Chargement des demandes...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF5A6C7D),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //* RAMASSEUR CONTENT
  Widget _buildRamasseurContent(CoursesDeliveryViewModel viewModel,
      BuildContext context, Color primaryColor) {
    return Stack(
      children: [
        // Background avec gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF8FAFE),
                Color(0xFFEEF5FF),
              ],
            ),
          ),
        ),

        // Contenu principal
        SafeArea(
          child: Column(
            children: [
              // Contenu principal
              Expanded(
                child: viewModel.availableDemandes.isEmpty
                    ? _buildEmptyState(
                        "Aucune demande disponible",
                        Icons.inbox_outlined,
                      )
                    : _buildMapPlaceholder(viewModel),
              ),
            ],
          ),
        ),

        // Bottom Sheet
        if (viewModel.currentBottomSheetType != RamassageBottomSheetType.none)
          _buildPickerBottomSheet(viewModel, context),

        // Loading overlay
        if (viewModel.isAcceptingDemande) _buildLoadingOverlay(),
      ],
    );
  }

  Widget _buildPickerBottomSheet(
      CoursesDeliveryViewModel viewModel, BuildContext context) {
    if (viewModel.currentBottomSheetType == RamassageBottomSheetType.none) {
      return const SizedBox.shrink();
    }

    switch (viewModel.currentBottomSheetType) {
      case RamassageBottomSheetType.demandes:
        return _buildDemandesBottomSheet(viewModel, context, primaryColor);

      case RamassageBottomSheetType.details:
        return _buildDetailsBottomSheet(viewModel, context);

      case RamassageBottomSheetType.inProgress:
        return _buildInProgressBottomSheet(viewModel, context);

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMapPlaceholder(CoursesDeliveryViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.9),
                const Color(0xFFF1F5F9).withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.8),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 80,
                  color: Color(0xFF94A3B8),
                ),
                SizedBox(height: 16),
                Text(
                  'Carte des ramassages',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Visualisez vos demandes sur la carte',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8FAFE),
            Color(0xFFEEF5FF),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 60,
                color: const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  //! Bottom sheet pour les détails d'une demande acceptée
  Widget _buildDetailsBottomSheet(
      CoursesDeliveryViewModel viewModel, BuildContext context) {
    const primaryColor = Color(0xFF184E9C);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle moderne
              Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header avec informations de base
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, primaryColor.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.assignment_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Demande N° ${viewModel.currentDemande?.numero ?? viewModel.currentDemande?.numero ?? 'N/A'}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1D29),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Acceptée',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Contenu scrollable
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Adresses
                      _buildDetailSection(
                        title: 'Adresses',
                        icon: Icons.location_on_outlined,
                        child: Column(
                          children: [
                            _buildModernAddressRow(
                              icon: Icons.my_location,
                              label: 'Point de ramassage',
                              address:
                                  viewModel.acceptedDemande?.adresseRamassage ??
                                      'Non spécifiée',
                              color: const Color(0xFF059669),
                            ),
                            const SizedBox(height: 12),
                            _buildModernAddressRow(
                              icon: Icons.local_laundry_service_outlined,
                              label: 'Pressing',
                              address:
                                  '${viewModel.acceptedDemande?.nomPressing ?? 'Non spécifié'} - ${viewModel.acceptedDemande?.adressePressing ?? ''}',
                              color: primaryColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Section Détails de la commande
                      _buildDetailSection(
                        title: 'Détails de la commande',
                        icon: Icons.shopping_bag_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Articles au kilo
                            if (viewModel.acceptedDemande?.vetementsAuKilo
                                    ?.isNotEmpty ??
                                false) ...[
                              const Text(
                                'Articles au kilo',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1D29),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...?viewModel.acceptedDemande?.vetementsAuKilo
                                  ?.map((item) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '• ${item.libelle ?? 'Article'}',
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                            Text(
                                              'x ${item.quantite?.toStringAsFixed(0) ?? '0'}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF1A1D29),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            ],

                            // Section Vêtements spéciaux
                            const SizedBox(height: 16),
                            _buildDetailSection(
                              title: 'Vêtements spéciaux',
                              icon: Icons.checkroom_outlined,
                              child: viewModel.acceptedDemande
                                          ?.vetementsSpeciaux?.isNotEmpty ??
                                      false
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: viewModel
                                          .acceptedDemande!.vetementsSpeciaux!
                                          .map((item) => Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      '• ${item.libelle ?? 'Article spécial'}: ${item.quantite ?? 1}x',
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                              ))
                                          .toList(),
                                    )
                                  : const Text(
                                      'Aucun vêtement spécial',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),

                            // Section Services complémentaires
                            const SizedBox(height: 16),
                            _buildDetailSection(
                              title: 'Services complémentaires',
                              icon: Icons.miscellaneous_services_outlined,
                              child: viewModel
                                          .acceptedDemande
                                          ?.servicesComplementaires
                                          ?.isNotEmpty ??
                                      false
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: viewModel.acceptedDemande!
                                          .servicesComplementaires!
                                          .map((service) => Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      '• ${service.libelle ?? 'Service'}',
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                              ))
                                          .toList(),
                                    )
                                  : const Text(
                                      'Aucun service complémentaire',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),

                            // Message
                            if (viewModel.acceptedDemande?.message != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  viewModel.acceptedDemande!.message!.contains(
                                          'saisissez le poids total pour obtenir le montant estimé')
                                      ? 'Saisissez le poids total pour obtenir le montant estimé.'
                                      : viewModel.acceptedDemande!.message!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF1E40AF),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextInputField(
                                bigLabel: "Poids total",
                                hintText: "ex : 1kg",
                                keyboardType: TextInputType.number,
                              )
                            ],
                            const SizedBox(height: 20),

                            // Prix de ramassage
                            if (viewModel.acceptedDemande?.prixRamassage !=
                                null) ...[
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Frais de ramassage',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    '${viewModel.acceptedDemande?.prixRamassage} FCFA',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A1D29),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Bouton d'action
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Implémenter l'action de confirmation
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Confirmer la récupération',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bouton d'action en bas
              // Container(
              //   padding: const EdgeInsets.all(24),
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.black.withOpacity(0.05),
              //         blurRadius: 10,
              //         offset: const Offset(0, -2),
              //       ),
              //     ],
              //   ),
              //   child: Column(
              //     children: [
              //       // Bouton principal
              //       SizedBox(
              //         width: double.infinity,
              //         child: ElevatedButton(
              //           onPressed: () {
              //             // viewModel.startRamassage();
              //           },
              //           style: ElevatedButton.styleFrom(
              //             backgroundColor: primaryColor,
              //             foregroundColor: Colors.white,
              //             shape: RoundedRectangleBorder(
              //               borderRadius: BorderRadius.circular(16),
              //             ),
              //             padding: const EdgeInsets.symmetric(vertical: 16),
              //             elevation: 0,
              //           ),
              //           child: const Row(
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             children: [
              //               Icon(Icons.play_arrow, size: 20),
              //               SizedBox(width: 8),
              //               Text(
              //                 'Commencer le ramassage',
              //                 style: TextStyle(
              //                   fontSize: 16,
              //                   fontWeight: FontWeight.w600,
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //       ),
              //       const SizedBox(height: 12),
              //       // Bouton secondaire
              //       SizedBox(
              //         width: double.infinity,
              //         child: TextButton(
              //           onPressed: () {
              //             // viewModel.cancelDemande();
              //           },
              //           style: TextButton.styleFrom(
              //             padding: const EdgeInsets.symmetric(vertical: 16),
              //           ),
              //           child: const Text(
              //             'Annuler cette demande',
              //             style: TextStyle(
              //               color: Color(0xFFEF4444),
              //               fontSize: 14,
              //               fontWeight: FontWeight.w500,
              //             ),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }

//* Bottom sheet pour le ramassage en cours
  Widget _buildInProgressBottomSheet(
      CoursesDeliveryViewModel viewModel, BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.25,
      maxChildSize: 0.7,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle moderne
              Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header avec statut en cours
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF059669), Color(0xFF10B981)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.local_shipping,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Demande N° ${viewModel.currentDemande?.numero ?? 'N/A'}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1D29),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Ramassage en cours',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Contenu principal
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Étapes du ramassage
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.withOpacity(0.05),
                              Colors.green.withOpacity(0.02),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildProgressStep(
                              icon: Icons.my_location,
                              title: 'Se rendre au point de ramassage',
                              subtitle:
                                  viewModel.currentDemande?.adresseRamassage ??
                                      'Non spécifiée',
                              isCompleted: true,
                              isActive: false,
                            ),
                            const SizedBox(height: 16),
                            _buildProgressStep(
                              icon: Icons.check_box_outlined,
                              title: 'Récupérer les vêtements',
                              subtitle: 'Vérifiez les éléments avec le client',
                              isCompleted: false,
                              isActive: true,
                            ),
                            const SizedBox(height: 16),
                            _buildProgressStep(
                              icon: Icons.location_on,
                              title: 'Livrer au pressing',
                              subtitle:
                                  viewModel.currentDemande?.adresseLivraison ??
                                      'Non spécifiée',
                              isCompleted: false,
                              isActive: false,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Informations importantes
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'N\'oubliez pas de prendre une photo des vêtements avant le ramassage',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF1E40AF),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 80), // Espace pour les boutons
                    ],
                  ),
                ),
              ),

              // Boutons d'action
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Bouton principal - Facturer
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // viewModel.completeRamassage();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_outlined, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Facturer et terminer',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Bouton secondaire - Problème
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          _showProblemDialog(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFEF4444)),
                          backgroundColor: const Color(0xFFFEF2F2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.report_problem_outlined,
                              size: 20,
                              color: Color(0xFFEF4444),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Signaler un problème',
                              style: TextStyle(
                                color: Color(0xFFEF4444),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

//* Widget helper pour les sections de détails
  Widget _buildDetailSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1D29),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

//* Widget helper pour les informations
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1A1D29),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

//* Widget helper pour les étapes de progression
  Widget _buildProgressStep({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isActive,
  }) {
    Color getColor() {
      if (isCompleted) return const Color(0xFF059669);
      if (isActive) return const Color(0xFF184E9C);
      return const Color(0xFF94A3B8);
    }

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: getColor().withOpacity(isCompleted || isActive ? 0.1 : 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: getColor().withOpacity(0.3),
              width: isActive ? 2 : 1,
            ),
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: getColor(),
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isCompleted || isActive
                      ? const Color(0xFF1A1D29)
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

//* Dialog pour signaler un problème
  void _showProblemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.report_problem_outlined,
              color: Color(0xFFEF4444),
            ),
            SizedBox(width: 8),
            Text('Signaler un problème'),
          ],
        ),
        content: const Text(
          'Décrivez le problème rencontré lors du ramassage. Notre équipe vous contactera rapidement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Logique pour envoyer le rapport
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDemandesBottomSheet(CoursesDeliveryViewModel viewModel,
      BuildContext context, Color primaryColor) {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.2,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle moderne
              Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header du bottom sheet
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, primaryColor.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.local_shipping_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Demandes disponibles',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1D29),
                            ),
                          ),
                          Text(
                            '${viewModel.availableDemandes.length} demande${viewModel.availableDemandes.length > 1 ? 's' : ''} en attente',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        '${viewModel.availableDemandes.length}',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Liste des demandes
              Expanded(
                child: viewModel.availableDemandes.isEmpty
                    ? _buildEmptyDemandesState()
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: viewModel.availableDemandes.length,
                        itemBuilder: (context, index) {
                          final demande = viewModel.availableDemandes[index];
                          return _buildModernDemandeCard(
                              demande, viewModel, context, primaryColor);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyDemandesState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Color(0xFF94A3B8),
          ),
          SizedBox(height: 16),
          Text(
            'Aucune demande disponible',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Les nouvelles demandes apparaîtront ici',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDemandeCard(
      Demandes demande,
      CoursesDeliveryViewModel viewModel,
      BuildContext context,
      Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec numéro et statut
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              viewModel.getDemandeStatusColor(demande.statut),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Demande N° ${demande.numero ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1D29),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: viewModel
                        .getDemandeStatusColor(demande.statut)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: viewModel
                          .getDemandeStatusColor(demande.statut)
                          .withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    viewModel.getDemandeStatusText(demande.statut),
                    style: TextStyle(
                      color: viewModel.getDemandeStatusColor(demande.statut),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Adresses avec design amélioré
            _buildModernAddressRow(
              icon: Icons.my_location,
              label: 'Point de ramassage',
              address: demande.adresseRamassage ?? 'Adresse non spécifiée',
              color: const Color(0xFF059669),
            ),

            const SizedBox(height: 12),

            _buildModernAddressRow(
              icon: Icons.location_on,
              label: 'Destination',
              address: demande.adresseLivraison ?? 'Adresse non spécifiée',
              color: primaryColor,
            ),

            const SizedBox(height: 16),

            // Date avec icône
            if (demande.dateDemande != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule_outlined,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Demandé le ${viewModel.formatDateTime(demande.dateDemande!)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Boutons d'action modernisés
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      backgroundColor: const Color(0xFFFEF2F2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.close,
                          size: 18,
                          color: Color(0xFFEF4444),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Refuser',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      viewModel.acceptDemande(demande);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Accepter',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernAddressRow({
    required IconData icon,
    required String label,
    required String address,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1A1D29),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF184E9C)),
                    strokeWidth: 3,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Traitement en cours...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1D29),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  CoursesDeliveryViewModel viewModelBuilder(BuildContext context) {
    final viewModel = CoursesDeliveryViewModel();
    viewModel.setContext(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.initialize();
    });
    return viewModel;
  }
}
