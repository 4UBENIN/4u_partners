import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'courses_delivery_viewmodel.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/ui/common/api_constant.dart';
import 'package:for_u_partners/ui/common/enum/bottom_enum.dart';
import 'package:for_u_partners/ui/views/delivery/courses_delivery/recap_view.dart';
import 'package:for_u_partners/ui/views/delivery/courses_delivery/widget/customers_sheet_widget.dart';

class CoursesDeliveryView extends StackedView<CoursesDeliveryViewModel> {
  const CoursesDeliveryView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    CoursesDeliveryViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        color: Colors.white,
        child: viewModel.isLoadingLocation
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Obtention de votre position...'),
                  ],
                ),
              )
            : Stack(
                children: [
                  FlutterMap(
                    mapController: viewModel.mapController,
                    options: MapOptions(
                      center: viewModel.mapCenter,
                      zoom: viewModel.mapZoom,
                      onTap: (tapPosition, point) =>
                          viewModel.onMapTapped(point),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: ApiConstant.mapboxUrl,
                        additionalOptions: {
                          'accessToken': ApiConstant.mapboxprivaToken,
                          'id': 'mapbox.streets',
                        },
                      ),
                      MarkerLayer(
                        markers: viewModel.markers,
                      ),
                    ],
                  ),

                  // Bottom sheet animé
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return SlideTransition(
                        position: animation.drive(
                          Tween(
                            begin: const Offset(0.0, 1.0),
                            end: Offset.zero,
                          ).chain(CurveTween(curve: Curves.easeInOut)),
                        ),
                        child: child,
                      );
                    },
                    child: _buildBottomSheet(viewModel, context),
                  ),

                  // Overlay de chargement
                  viewModel.isBusy
                      ? Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(0.3),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          kcPrimaryColor),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Traitement en cours...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),

                  // Bouton retour
                  Positioned(
                    top: 52,
                    left: 20,
                    child: InkWell(
                      onTap: () => viewModel.navigationService.back(),
                      child: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: viewModel.isAndroid
                              ? const Icon(Icons.arrow_back, size: 20)
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 6),
                                    Icon(Icons.arrow_back_ios, size: 20),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),

                  // Bouton recentrer et rafraîchir
                  Positioned(
                    top: 52,
                    right: 20,
                    child: Column(
                      children: [
                        // Bouton pour recentrer sur la position actuelle
                        InkWell(
                          onTap: () {
                            viewModel.recenterOnUserLocation();
                          },
                          child: Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.my_location,
                              size: 20,
                              color: kcPrimaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Bouton pour rafraîchir les demandes
                        InkWell(
                          onTap: () {
                            viewModel.refreshDeliveries();
                          },
                          child: Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.refresh,
                              size: 20,
                              color: kcPrimaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBottomSheet(CoursesDeliveryViewModel viewModel, BuildContext context) {
    switch (viewModel.currentBottomSheetType) {
      case BottomSheetAppType.clients:
        // Afficher le message si aucune livraison disponible
        if (viewModel.availableDeliveries.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Aucune demande pour l\'instant',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Les nouvelles demandes de livraison apparaîtront ici',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    viewModel.refreshDeliveries();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Actualiser',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        }

        return DeliveryClientsBottomSheet(
          key: const ValueKey('clients'),
          getClientsList: viewModel.getClientsList(),
          onAccept: () {
            // Accepter la première livraison disponible
            if (viewModel.availableDeliveries.isNotEmpty) {
              final firstDelivery = viewModel.availableDeliveries.first;
              if (firstDelivery.hasValidDeliveryId) {
                viewModel.acceptDelivery(firstDelivery.livraisonId!, context);
              }
            }
          },
          onDecline: () {
            // Refuser la première livraison
            if (viewModel.availableDeliveries.isNotEmpty) {
              final firstDelivery = viewModel.availableDeliveries.first;
              if (firstDelivery.hasValidDeliveryId) {
                viewModel.rejectDeliveryById(firstDelivery.livraisonId!);
              }
            }
            // Fermer seulement s'il n'y a plus de livraisons
            if (viewModel.availableDeliveries.length <= 1) {
              viewModel.setBottomSheetType(BottomSheetAppType.none);
            }
          },
        );

      case BottomSheetAppType.pickup:
        if (viewModel.availableDeliveries.isEmpty && viewModel.currentDelivery == null) {
          // UTILISER WidgetsBinding seulement ici car c'est pendant le build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            viewModel.setBottomSheetType(BottomSheetAppType.none);
          });
          return const SizedBox.shrink(key: ValueKey('no-pickup'));
        }

        // Utiliser la livraison actuelle ou la première disponible
        final pickupDelivery = viewModel.currentDelivery ?? 
            (viewModel.availableDeliveries.isNotEmpty ? viewModel.availableDeliveries.first : null);

        if (pickupDelivery == null) {
          return const SizedBox.shrink(key: ValueKey('no-delivery-data'));
        }

        return AcceptedClientBottomSheet(
          key: const ValueKey('pickup'),
          client: pickupDelivery.toDeliveryClientData(),
          onCancelRide: () {
            // Annuler la livraison acceptée
            if (pickupDelivery.hasValidDeliveryId) {
              viewModel.removeDelivery(pickupDelivery.livraisonId!);
              // TODO: Appeler le service pour annuler
              // viewModel.rejectDeliveryService(int.tryParse(pickupDelivery.livraisonId!)!, context);
            }
            viewModel.setBottomSheetType(BottomSheetAppType.none);
          },
          onStartRide: () {
            // Démarrer la livraison
            viewModel.startDelivery();
            if (pickupDelivery.hasValidDeliveryId) {
              viewModel.startDeliveryService(
                  int.tryParse(pickupDelivery.livraisonId!)!, context);
            }
          },
          onCallClients: () {
            // Logique d'appel du client
            print('Appel du client: ${pickupDelivery.fullName}');
          },
        );

      case BottomSheetAppType.inprogress:
        final currentDelivery = viewModel.currentDelivery;
        
        if (currentDelivery == null) {
          // UTILISER WidgetsBinding seulement ici car c'est pendant le build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            viewModel.setBottomSheetType(BottomSheetAppType.none);
          });
          return const SizedBox.shrink(key: ValueKey('no-inprogress'));
        }

        return InProgressRideBottomSheet(
          key: const ValueKey('inprogress'),
          client: currentDelivery.toDeliveryClientData(),
          onCancelRide: () {
            viewModel.setBottomSheetType(BottomSheetAppType.none);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DeliveryRecapitulatifCoursePage(
                  demandType: 'Livraison',
                  pointDepart: currentDelivery.adresseDepart ?? 'Adresse inconnue',
                  destination: 'Destination à définir', // À adapter selon tes besoins
                  nomClient: currentDelivery.fullName,
                  type: 'Livraison',
                  initialeClient: currentDelivery.initials,
                  vetements: const ["Articles à livrer"], // À adapter
                  onSoumettre: () {
                    if (currentDelivery.hasValidDeliveryId) {
                      viewModel.removeDelivery(currentDelivery.livraisonId!);
                    }
                    final navigationService = locator<NavigationService>();
                    navigationService.navigateToDeliveryNavBarView();
                  },
                ),
              ),
            );
          },
          onAddPenalily: () {
            // Logique pour ajouter une pénalité
            print('Ajouter une pénalité pour la livraison');
          },
          onCallClients: () {
            // Logique d'appel du client
            print('Appel du client: ${currentDelivery.fullName}');
          },
          price: 0.0, // À adapter selon tes besoins - prix de livraison
        );

      case BottomSheetAppType.none:
      default:
        return const SizedBox.shrink(key: ValueKey('none'));
    }
  }

  @override
  CoursesDeliveryViewModel viewModelBuilder(BuildContext context) {
    final viewModel = CoursesDeliveryViewModel();
    viewModel.setContext(context);
    // Démarrer l'initialisation après avoir défini le contexte
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.initialize();
    });
    return viewModel;
  }
}