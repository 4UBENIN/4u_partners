import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/services/chat_service.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:for_u_partners/services/driver_service.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/views/drivers/courses/chat_page.dart';
import 'package:for_u_partners/ui/views/drivers/courses/recap_view.dart';
import 'package:for_u_partners/ui/views/drivers/courses/pickup_recap_view.dart';
import 'package:for_u_partners/ui/views/drivers/courses/pick_up_page.dart';
import 'package:for_u_partners/ui/views/drivers/courses/course_denial_view.dart';
import 'package:for_u_partners/ui/views/drivers/homemain/homemain_viewmodel_export.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'courses_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/ui/common/enum/bottom_enum.dart';
import 'package:for_u_partners/ui/views/drivers/courses/widget/customers_sheet_widget.dart';

class CoursesView extends StackedView<CoursesViewModel> {
  const CoursesView({Key? key}) : super(key: key);
  static bool _isChatLoading = false;

  @override
  Widget builder(
    BuildContext context,
    CoursesViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Container(
        color: Colors.white,
        child: Stack(
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
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                  ),

                  // Floating Google Maps button (top right)
                  if (viewModel.currentCourse != null &&
                      (viewModel.currentBottomSheetType == BottomSheetAppType.pickup ||
                       viewModel.currentBottomSheetType == BottomSheetAppType.inprogress))
                    Positioned(
                      top: 60,
                      right: 16,
                      child: SafeArea(
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              try {
                                final currentCourse = viewModel.currentCourse!;
                                String url;

                                // Different URLs based on ride state
                                if (viewModel.currentBottomSheetType == BottomSheetAppType.pickup) {
                                  // Going to pickup: current position -> pickup address
                                  if (viewModel.currentPosiction?.latitude == null ||
                                      viewModel.currentPosiction?.longitude == null) {
                                    throw "Position actuelle non disponible";
                                  }
                                  if (currentCourse.adresseDepart == null ||
                                      currentCourse.adresseDepart!.isEmpty) {
                                    throw "Adresse de départ non disponible";
                                  }

                                  final origin = "${viewModel.currentPosiction!.latitude},${viewModel.currentPosiction!.longitude}";
                                  final destination = Uri.encodeComponent(currentCourse.adresseDepart!);
                                  url = "https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&travelmode=driving";
                                } else {
                                  // In progress: pickup address -> destination
                                  if (currentCourse.adresseDepart == null ||
                                      currentCourse.adresseDepart!.isEmpty) {
                                    throw "Adresse de départ non disponible";
                                  }
                                  if (currentCourse.destination.isEmpty) {
                                    throw "Destination non disponible";
                                  }

                                  final origin = Uri.encodeComponent(currentCourse.adresseDepart!);
                                  final destination = Uri.encodeComponent(currentCourse.destination);
                                  url = "https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&travelmode=driving";
                                }

                                final Uri uri = Uri.parse(url);
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erreur: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.navigation,
                                    size: 24,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Google Maps',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Display client card as fixed positioned element
                  if (viewModel.availableCourses.isNotEmpty &&
                      viewModel.currentBottomSheetType == BottomSheetAppType.clients)
                    Positioned(
                      bottom: 0,
                      left: 16,
                      right: 16,
                      child: _buildClientCard(viewModel, context),
                    ),

                  // Other bottom sheets
                  _buildBottomSheet(viewModel, context),
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

                  _isChatLoading
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
                                      'Ouverture du chat...',
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

                  // Small loading indicator when getting location
                  if (viewModel.isLoadingLocation)
                    Positioned(
                      top: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(kcPrimaryColor),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Localisation...',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Top bar with menu and stats (hide when courses available)
                  if (viewModel.availableCourses.isEmpty &&
                      viewModel.currentBottomSheetType == BottomSheetAppType.none)
                    Positioned(
                      top: 60,
                      left: 16,
                      right: 16,
                      child: SafeArea(
                        top: false,
                        bottom: false,
                        child: _buildTopBar(context, viewModel),
                      ),
                    ),


                  // Status toggle at bottom (hide when courses available)
                  if (viewModel.availableCourses.isEmpty &&
                      viewModel.currentBottomSheetType == BottomSheetAppType.none)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: _buildStatusToggle(viewModel, context),
                    ),
                ],
              ),
      ),
    );
  }

  static Future<void> _openChatWithLoading({
    required BuildContext context,
    required String clientId,
    required String clientName,
    required String? courseId,
    required ChatService chatService,
  }) async {
    // Empêcher les clics multiples
    if (_isChatLoading) return;

    // Activer l'indicateur de chargement
    _isChatLoading = true;
    // Force rebuild pour afficher le loading
    if (context.mounted) {
      (context as Element).markNeedsBuild();
    }

    try {
      // Récupérer les infos de l'utilisateur connecté
      final currentUserInfo = await chatService.getCurrentUserInfo();
      print(" BB CURRENT USER INFO : $currentUserInfo");
      final a = await locator<SharedpreferencesService>().getUserTypeId();
      print(" BB CURRENT USER ID : $a");
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
        clientId: clientId,
        clientName: clientName,
        tripId: courseId,
      );

      print(" BB RecEIVER NAME : $clientName ");
      print(" BB RecEIVER ID : $clientId");
      print(" BB CONVERSATION ID : $conversationId");
      print(" BB CURRENT USER ID : ${currentUserInfo['id']}");

      if (conversationId != null) {
        // Naviguer vers la page de chat
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              receiverUserName: clientName,
              receiverUserId: clientId,
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
    } finally {
      // Désactiver l'indicateur de chargement
      _isChatLoading = false;
      // Force rebuild pour cacher le loading
      if (context.mounted) {
        (context as Element).markNeedsBuild();
      }
    }
  }

  Widget _buildClientCard(CoursesViewModel viewModel, BuildContext context) {
    if (viewModel.availableCourses.isEmpty) {
      return const SizedBox.shrink();
    }

    final client = viewModel.availableCourses.first;

    return ClientCard(
      client: client,
      onAccept: () {
        if (client.hasValidCourseId) {
          viewModel.acceptCourse(client.courseId!, context);
        }
      },
      onDecline: () {
        if (client.hasValidCourseId) {
          viewModel.rejectCourseById(client.courseId!);
        }
        if (viewModel.availableCourses.length <= 1) {
          viewModel.setBottomSheetType(BottomSheetAppType.none);
        }
      },
    );
  }

  Widget _buildBottomSheet(
      CoursesViewModel viewModel, BuildContext context) {
    print('🏗️ [BottomSheet] _buildBottomSheet called');
    print('🏗️ [BottomSheet] currentBottomSheetType: ${viewModel.currentBottomSheetType}');
    print('🏗️ [BottomSheet] currentCourse: ${viewModel.currentCourse?.courseId}');
    print('🏗️ [BottomSheet] isGoingToPickup: ${viewModel.isGoingToPickup}');
    print('🏗️ [BottomSheet] isOnTrip: ${viewModel.isOnTrip}');

    // Ne pas afficher si le type est none
    if (viewModel.currentBottomSheetType == BottomSheetAppType.none) {
      print('🏗️ [BottomSheet] Returning shrink - type is none');
      return const SizedBox.shrink(key: ValueKey('none'));
    }

    // Vérifier si on a une course en cours
    final hasActiveRide = viewModel.currentCourse != null &&
        (viewModel.isGoingToPickup || viewModel.isOnTrip);
    print('🏗️ [BottomSheet] hasActiveRide: $hasActiveRide');

    // Si on a une course en cours mais pas de bottom sheet actif, forcer l'affichage
    if (hasActiveRide &&
        viewModel.currentBottomSheetType == BottomSheetAppType.none) {
      print('🏗️ [BottomSheet] Active ride but no bottom sheet - scheduling type change');
      Future.delayed(Duration.zero, () {
        viewModel.setBottomSheetType(BottomSheetAppType.pickup);
      });
      return const SizedBox.shrink(key: ValueKey('delayed-show'));
    }

    print('🏗️ [BottomSheet] Entering switch with type: ${viewModel.currentBottomSheetType}');
    switch (viewModel.currentBottomSheetType) {
      case BottomSheetAppType.clients:
        // Now handled by _buildClientCard as a fixed positioned card
        return const SizedBox.shrink(key: ValueKey('clients-handled-elsewhere'));

      case BottomSheetAppType.pickup:
        print('🏗️ [BottomSheet] PICKUP case entered');
        print(
            '🔄 BottomSheetAppType.pickup - availableCourses: ${viewModel.availableCourses.length}');
        print(
            '🔄 Contenu de availableCourses: ${viewModel.availableCourses.map((c) => '${c.courseId}: ${c.name}').toList()}');
        print('🔄 Current course: ${viewModel.currentCourse?.courseId}');
        print('🔄 Current course object: ${viewModel.currentCourse}');

        if (viewModel.currentCourse == null) {
          print(
              '❌ [BottomSheet] Aucune course active pour afficher le bottom sheet pickup');
          return const SizedBox.shrink(key: ValueKey('no-pickup'));
        }

        print('✅ [BottomSheet] Current course is NOT null, creating AcceptedClientBottomSheet');
        final pickupCourse = viewModel.currentCourse!;
        print('✅ [BottomSheet] pickupCourse: ${pickupCourse.courseId}');
        print('✅ [BottomSheet] pickupCourse.clientId: ${pickupCourse.clientId}');
        print('✅ [BottomSheet] pickupCourse.hasValidCourseId: ${pickupCourse.hasValidCourseId}');

        final chatService = locator<ChatService>();
        print('✅ [BottomSheet] ChatService obtained, building AcceptedClientBottomSheet...');

        return AcceptedClientBottomSheet(
            key: ValueKey('pickup-${pickupCourse.courseId}'),
            client: pickupCourse,
            clientId: pickupCourse.clientId,
            courseId: int.tryParse(pickupCourse.courseId!)!,
            currentLatitude: viewModel.currentPosiction?.latitude,
            currentLongitude: viewModel.currentPosiction?.longitude,
            onCancelRide: () {
              // Annuler la course acceptée - PAS de WidgetsBinding ici
              if (pickupCourse.hasValidCourseId) {
                viewModel.rejectCourseService(
                    int.tryParse(pickupCourse.courseId!)!, context);
                viewModel.removeCourse(pickupCourse.courseId!);
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

              await _openChatWithLoading(
                context: context,
                clientId: pickupCourse.clientId!,
                clientName: pickupCourse.name,
                courseId: pickupCourse.courseId,
                chatService: chatService,
              );
            },
            onDenyRide: () async {
              // Refuser la course (seulement si statut = chauffeur_en_route)
              try {
                final denialData = await viewModel.denyCourse();
                viewModel.setBottomSheetType(BottomSheetAppType.none);

                if (context.mounted && denialData != null) {
                  // Naviguer vers la page de détails du refus
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CourseDenialView(
                        denialData: denialData,
                        onClose: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            });

      case BottomSheetAppType.inprogress:
        // Vérifier d'abord si on a une course en cours
        if (viewModel.currentCourse == null) {
          // Essayer de restaurer l'état de la course (non-blocking)
          Future.microtask(() => viewModel.checkAndRestoreRideState());

          // Si toujours pas de course, vérifier availableCourses en dernier recours
          if (viewModel.availableCourses.isNotEmpty) {
            viewModel.currentCourse = viewModel.availableCourses.first;
            print(
                'ℹ️ Course récupérée depuis availableCourses: ${viewModel.currentCourse?.courseId}');
          } else {
            print('ℹ️ Aucune course en cours à afficher - tentative de restauration en cours');
            return const SizedBox.shrink(key: ValueKey('no-inprogress'));
          }
        } else {
          print(
              'ℹ️ Course courante déjà définie: ${viewModel.currentCourse?.courseId}');
        }

        return InProgressRideBottomSheet(
          key: const ValueKey('inprogress'),
          client: viewModel.currentCourse!,
          currentLatitude: viewModel.currentPosiction?.latitude,
          currentLongitude: viewModel.currentPosiction?.longitude,
          onCancelRide: () {
            final courseId = int.tryParse(viewModel.currentCourse!.courseId ?? '') ?? 0;
            final isPickup = viewModel.currentCourse!.isPickupCourse;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => isPickup
                    ? PickupRecapView(
                        viewModel: viewModel,
                        courseId: courseId,
                        onSoumettre: () {
                          if (viewModel.currentCourse!.hasValidCourseId) {
                            viewModel.removeCourse(viewModel.currentCourse!.courseId!);
                          }
                          final navigationService = locator<NavigationService>();
                          navigationService.navigateToHomemainView();
                        },
                      )
                    : RecapitulatifCoursePage(
                        viewModel: viewModel,
                        courseId: courseId,
                        onSoumettre: () {
                          if (viewModel.currentCourse!.hasValidCourseId) {
                            viewModel.removeCourse(viewModel.currentCourse!.courseId!);
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

  Widget _buildStartRideButton(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kcPrimaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PickUpPage(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: kcPrimaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_circle_outline_rounded, size: 22),
            SizedBox(width: 10),
            Text(
              'Démarrer une course',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, CoursesViewModel viewModel) {
    final driverService = locator<DriverService>();
    final homeMainViewModel = locator<HomemainViewModel>();

    return FutureBuilder<Map<String, dynamic>>(
      future: Future.wait([
        driverService.fetchDailyStats().then((stats) => {
          'montantGainToday': (stats?.montantGainToday ?? 0).toDouble(),
          'todayCourses': stats?.totalActiviteToday ?? 0,
        }),
      ]).then((results) => results.first),
      builder: (context, snapshot) {
        final montantGainToday = snapshot.data?['montantGainToday'] ?? 0.0;
        final todayCourses = snapshot.data?['todayCourses'] ?? 0;

        return Row(
          children: [
            Material(
              color: Colors.white,
              elevation: 6,
              shape: const CircleBorder(),
              shadowColor: Colors.black.withOpacity(0.15),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  homeMainViewModel.toggleNavigation();
                },
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.12),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.menu_rounded,
                    color: kcPrimaryColor,
                    size: 26,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.payments_outlined,
                          color: kcPrimaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${montantGainToday.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kcPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.directions_car_filled_outlined,
                          color: kcPrimaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$todayCourses',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kcPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusToggle(CoursesViewModel viewModel, BuildContext outerContext) {
    return StreamBuilder<bool?>(
      stream: _getOnlineStatusStream(),
      initialData: true,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;

        return _StatusToggleWidget(
          isOnline: isOnline,
          onToggle: () async {
            final sharedPrefsService = locator<SharedpreferencesService>();
            final driverService = locator<DriverService>();

            final newStatus = !isOnline;
            await driverService.updateStatus(newStatus);
            await sharedPrefsService.setOnlineStatus(newStatus);
          },
          outerContext: outerContext,
        );
      },
    );
  }

  Stream<bool?> _getOnlineStatusStream() async* {
    final sharedPrefsService = locator<SharedpreferencesService>();

    // Emit initial value
    yield await sharedPrefsService.getOnlineStatus();

    // Poll for changes every second
    while (true) {
      await Future.delayed(const Duration(milliseconds: 500));
      yield await sharedPrefsService.getOnlineStatus();
    }
  }

  @override
  CoursesViewModel viewModelBuilder(BuildContext context) {
    // Utiliser locator pour obtenir l'instance de HomemainViewModel
    final homeMainViewModel = locator<HomemainViewModel>();
    final viewModel = CoursesViewModel();
    viewModel.setHomeMainViewModel(homeMainViewModel);
    // Initialiser le ViewModel
    viewModel.initializeViewModel();
    return viewModel;
  }
}

class _StatusToggleWidget extends StatefulWidget {
  final bool isOnline;
  final Future<void> Function() onToggle;
  final BuildContext outerContext;

  const _StatusToggleWidget({
    Key? key,
    required this.isOnline,
    required this.onToggle,
    required this.outerContext,
  }) : super(key: key);

  @override
  State<_StatusToggleWidget> createState() => _StatusToggleWidgetState();
}

class _StatusToggleWidgetState extends State<_StatusToggleWidget> {
  bool _isToggling = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isToggling ? null : () async {
        setState(() {
          _isToggling = true;
        });

        try {
          await widget.onToggle();
        } finally {
          if (mounted) {
            setState(() {
              _isToggling = false;
            });
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                  );
                },
                child: Text(
                  widget.isOnline ? 'EN LIGNE' : 'HORS LIGNE',
                  key: ValueKey(widget.isOnline),
                  style: TextStyle(
                    color: widget.isOnline ? Colors.black : Colors.red.shade600,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (_isToggling)
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(kcPrimaryColor),
                  ),
                )
              else
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: child,
                    );
                  },
                  child: Icon(
                    widget.isOnline ? Icons.toggle_on : Icons.toggle_off,
                    key: ValueKey(widget.isOnline),
                    color: widget.isOnline ? Colors.black : Colors.red.shade600,
                    size: 38,
                  ),
                ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    widget.outerContext,
                    MaterialPageRoute(
                      builder: (context) => const PickUpPage(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.add_circle_outline_rounded,
                    color: Colors.black,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
