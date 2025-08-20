import 'package:for_u_partners/services/chat_service.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/views/drivers/courses/chat_page.dart';

import 'courses_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/ui/common/enum/bottom_enum.dart';
import 'package:for_u_partners/ui/views/drivers/courses/recap_view.dart';
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

  Widget _buildBottomSheet(CoursesViewModel viewModel, BuildContext context) {
    switch (viewModel.currentBottomSheetType) {
      case BottomSheetAppType.clients:
        // Afficher uniquement s'il y a des courses disponibles
        if (viewModel.availableCourses.isEmpty) {
          // UTILISER WidgetsBinding seulement ici car c'est pendant le build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            viewModel.setBottomSheetType(BottomSheetAppType.none);
          });
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
        if (viewModel.availableCourses.isEmpty) {
          // UTILISER WidgetsBinding seulement ici car c'est pendant le build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            viewModel.setBottomSheetType(BottomSheetAppType.none);
          });
          return const SizedBox.shrink(key: ValueKey('no-pickup'));
        }

        final pickupCourse = viewModel.availableCourses.first;
        final chatService = locator<ChatService>();

        return AcceptedClientBottomSheet(
          key: const ValueKey('pickup'),
          client: pickupCourse,
          clientId: pickupCourse.clientId,
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
          onChatClients: () async {
            try {
              // Vérifier que nous avons l'ID du client
              if (pickupCourse.clientId == null ||
                  pickupCourse.clientId!.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Impossible d\'ouvrir le chat pour le moment'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Récupérer les infos de l'utilisateur connecté
              final currentUserInfo = await chatService.getCurrentUserInfo();
              if (currentUserInfo == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erreur: Utilisateur non connecté'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Créer ou récupérer la conversation
              final conversationId = await chatService.createOrGetConversation(
                currentUserId: currentUserInfo['id'],
                clientId: pickupCourse.clientId!,
                clientName: pickupCourse.name,
                tripId: pickupCourse.courseId,
              );

              print(" BB RecEIVER NAME : ${pickupCourse.name} ");
              print(" BB RecEIVER ID : ${pickupCourse.clientId}");
              print(" BB CONVERSATION ID : $conversationId");
              print(" BB CURRENT USER ID : ${currentUserInfo['id']}");

              if (conversationId != null) {
                // Naviguer vers la page de chat
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      receiverUserName: pickupCourse.name,
                      receiverUserId: pickupCourse.clientId!,
                      conversationId: conversationId,
                      currentUserId: currentUserInfo['id'],
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erreur lors de l\'ouverture du chat'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } catch (e) {
              print('Erreur ouverture chat: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Une erreur est survenue'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        );

      case BottomSheetAppType.inprogress:
        if (viewModel.availableCourses.isEmpty) {
          // UTILISER WidgetsBinding seulement ici car c'est pendant le build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            viewModel.setBottomSheetType(BottomSheetAppType.none);
          });
          return const SizedBox.shrink(key: ValueKey('no-inprogress'));
        }

        final currentCourse = viewModel.availableCourses.first;

        return InProgressRideBottomSheet(
          key: const ValueKey('inprogress'),
          client: currentCourse,
          onCancelRide: () {
            viewModel.setBottomSheetType(BottomSheetAppType.none);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecapitulatifCoursePage(
                  viewModel: viewModel,
                  courseId: int.tryParse(currentCourse.courseId ?? '') ?? 0,
                  onSoumettre: () {
                    if (currentCourse.hasValidCourseId) {
                      viewModel.removeCourse(currentCourse.courseId!);
                    }
                    final navigationService = locator<NavigationService>();
                    navigationService.navigateToHomemainView();
                  },
                ),
              ),
            );
          },
          onAddPenalty: () {
            // Logique pour ajouter une pénalité
            print('Ajouter une pénalité');
          },
          onCallClients: () {
            // final phoneNumber = currentCourse.pho ;
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
          price: currentCourse.prix ??
              0.0, // Assurez-vous que le prix est correctement défini
        );

      case BottomSheetAppType.none:
      default:
        return const SizedBox.shrink(key: ValueKey('none'));
    }
  }

  @override
  CoursesViewModel viewModelBuilder(BuildContext context) => CoursesViewModel();
}
