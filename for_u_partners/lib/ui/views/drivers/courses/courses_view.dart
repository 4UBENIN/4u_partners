import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/views/drivers/homemain/homemain_viewmodel_export.dart';
import 'courses_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/ui/common/enum/bottom_enum.dart';
import 'package:for_u_partners/ui/views/drivers/courses/widget/customers_sheet_widget.dart';

class CoursesView extends StackedView<CoursesViewModel> {
  const CoursesView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    CoursesViewModel viewModel,
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
                  GoogleMap(
                    onMapCreated: viewModel.onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: viewModel.mapCenter,
                      zoom: viewModel.mapZoom,
                    ),
                    onTap: viewModel.onMapTapped,
                    markers: viewModel.markers,
                    polylines: viewModel.polylines,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                  ),
                  // Bouton pour recentrer sur la position utilisateur

                  // Afficher le bottom sheet avec gestion asynchrone
                  FutureBuilder<Widget>(
                    future: _buildBottomSheet(viewModel, context),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox.shrink();
                      }
                      return snapshot.data ?? const SizedBox.shrink();
                    },
                  ),
                  viewModel.isBusy
                      ? Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(
                                0.3), // Arrière-plan semi-transparent
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
                                      'Acceptation en cours...',
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

                  Positioned(
                    top: 52,
                    left: 20,
                    child: IgnorePointer(
                      // Désactiver le bouton pendant la restauration de l'état
                      ignoring: viewModel.isRestoringState,
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
                  ),

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
                      ],
                    ),
                  ),

                  // Bouton flottant pour démarrer la course (visible uniquement lors du ramassage)
                ],
              ),
      ),
    );
  }

  Future<Widget> _buildBottomSheet(CoursesViewModel viewModel, BuildContext context) async {
    // Ne pas afficher si le type est none
    if (viewModel.currentBottomSheetType == BottomSheetAppType.none) {
      return const SizedBox.shrink(key: ValueKey('none'));
    }
    
    // Vérifier si on a une course en cours
    final hasActiveRide = viewModel.currentCourse != null && 
                         (viewModel.isGoingToPickup || viewModel.isOnTrip);
    
    // Si on a une course en cours mais pas de bottom sheet actif, forcer l'affichage
    if (hasActiveRide && viewModel.currentBottomSheetType == BottomSheetAppType.none) {
      Future.delayed(Duration.zero, () {
        viewModel.setBottomSheetType(BottomSheetAppType.pickup);
      });
      return const SizedBox.shrink(key: ValueKey('delayed-show'));
    }
    
    switch (viewModel.currentBottomSheetType) {
      case BottomSheetAppType.clients:
        // Afficher uniquement s'il y a des courses disponibles
        if (viewModel.availableCourses.isEmpty) {
          return const SizedBox.shrink(key: ValueKey('empty'));
        }

        return ClientsBottomSheet(
          key: const ValueKey('clients'),
          getClientsList: viewModel.availableCourses,
          onAccept: () {
            // Accepter la première course disponible
            if (viewModel.availableCourses.isNotEmpty) {
              final firstCourse = viewModel.availableCourses.first;
              if (firstCourse.hasValidCourseId) {
                viewModel.acceptCourse(firstCourse.courseId!, context);
              }
            }
          },
          onDecline: () {
            // Refuser la première course
            if (viewModel.availableCourses.isNotEmpty) {
              final firstCourse = viewModel.availableCourses.first;
              if (firstCourse.hasValidCourseId) {
                viewModel.rejectCourseById(firstCourse.courseId!);
              }
            }
            // Fermer seulement s'il n'y a plus de courses - PAS de WidgetsBinding ici
            if (viewModel.availableCourses.length <= 1) {
              viewModel.setBottomSheetType(BottomSheetAppType.none);
            }
          },
        );

      case BottomSheetAppType.pickup:
        print('🔄 BottomSheetAppType.pickup - availableCourses: ${viewModel.availableCourses.length}');
        print('🔄 Contenu de availableCourses: ${viewModel.availableCourses.map((c) => '${c.courseId}: ${c.name}').toList()}');
        print('🔄 Current course: ${viewModel.currentCourse?.courseId}');
        if (viewModel.availableCourses.isEmpty) {
          print('❌ Aucune course disponible pour afficher le bottom sheet pickup');
          return const SizedBox.shrink(key: ValueKey('no-pickup'));
        }

        final pickupCourse = viewModel.availableCourses.first;

        return AcceptedClientBottomSheet(
          key: const ValueKey('pickup'),
          client: pickupCourse,
          onCancelRide: () {
            // Annuler la course acceptée - PAS de WidgetsBinding ici
            if (pickupCourse.hasValidCourseId) {
              viewModel.removeCourse(pickupCourse.courseId!);
              viewModel.rejectCourseService(
                  int.tryParse(pickupCourse.courseId!)!, context);
            }
            viewModel.setBottomSheetType(BottomSheetAppType.none);
          },
          onStartRide: () {
            // PAS de WidgetsBinding ici
            viewModel.startTrip();
            viewModel.startCourseService(
                int.tryParse(pickupCourse.courseId!)!, context);
          },
          onCallClients: () {
            // Logique d'appel du client
          },
        );

      case BottomSheetAppType.inprogress:
        // Vérifier d'abord si on a une course en cours
        if (viewModel.currentCourse == null) {
          // Essayer de restaurer l'état de la course
          await viewModel.checkAndRestoreRideState();
          
          // Si toujours pas de course, vérifier availableCourses en dernier recours
          if (viewModel.currentCourse == null && viewModel.availableCourses.isNotEmpty) {
            viewModel.currentCourse = viewModel.availableCourses.first;
            print('ℹ️ Course récupérée depuis availableCourses: ${viewModel.currentCourse?.courseId}');
          } else if (viewModel.currentCourse == null) {
            print('ℹ️ Aucune course en cours à afficher');
            return const SizedBox.shrink(key: ValueKey('no-inprogress'));
          }
        } else {
          print('ℹ️ Course courante déjà définie: ${viewModel.currentCourse?.courseId}');
        }

        return InProgressRideBottomSheet(
          key: const ValueKey('inprogress'),
          client: viewModel.currentCourse!,
          onCancelRide: () {
            viewModel.currentCourse = null;
            viewModel.setBottomSheetType(BottomSheetAppType.none);
          },
          onAddPenalty: () {
            // Logique pour ajouter une pénalité
            print('Ajouter une pénalité');
          },
          onCallClients: () {
            // final phoneNumber = viewModel.currentCourse?.phoneNumber;
            // if (phoneNumber != null && phoneNumber.isNotEmpty) {
            //   final url = 'tel:$phoneNumber';
            //   // launchUrl(Uri.parse(url));
            //   print('Appel du client: $phoneNumber');
            // } else {
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     const SnackBar(content: Text('Numéro de téléphone non disponible')),
            //   );
            // }
          },
          price: viewModel.currentCourse?.prix ?? 0.0,
        );

      case BottomSheetAppType.none:
        return const SizedBox.shrink(key: ValueKey('none'));
    }
  }

  @override
  CoursesViewModel viewModelBuilder(BuildContext context) {
    // Utiliser locator pour obtenir l'instance de HomemainViewModel
    final homeMainViewModel = locator<HomemainViewModel>();
    final viewModel = CoursesViewModel();
    viewModel.setHomeMainViewModel(homeMainViewModel);
    // Appeler onModelReady pour restaurer l'état de la course
    viewModel.onModelReady();
    return viewModel;
  }
}
