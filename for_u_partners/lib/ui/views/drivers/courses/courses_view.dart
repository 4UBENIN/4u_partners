import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:for_u_partners/services/driver_service.dart';
import 'package:for_u_partners/services/course_restoration_service.dart';
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
                                  // Going to pickup: current position -> pickup coordinates
                                  if (viewModel.currentPosiction?.latitude == null ||
                                      viewModel.currentPosiction?.longitude == null) {
                                    throw "Position actuelle non disponible";
                                  }

                                  final origin = "${viewModel.currentPosiction!.latitude},${viewModel.currentPosiction!.longitude}";

                                  // Prefer coordinates over address for accuracy
                                  String destination;
                                  if (currentCourse.depLat != null && currentCourse.depLong != null) {
                                    destination = "${currentCourse.depLat},${currentCourse.depLong}";
                                  } else if (currentCourse.adresseDepart != null && currentCourse.adresseDepart!.isNotEmpty) {
                                    destination = Uri.encodeComponent(currentCourse.adresseDepart!);
                                  } else {
                                    throw "Adresse de départ non disponible";
                                  }

                                  url = "https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&travelmode=driving";
                                } else {
                                  // In progress: pickup coordinates -> destination coordinates
                                  String origin;
                                  if (currentCourse.depLat != null && currentCourse.depLong != null) {
                                    origin = "${currentCourse.depLat},${currentCourse.depLong}";
                                  } else if (currentCourse.adresseDepart != null && currentCourse.adresseDepart!.isNotEmpty) {
                                    origin = Uri.encodeComponent(currentCourse.adresseDepart!);
                                  } else {
                                    throw "Adresse de départ non disponible";
                                  }

                                  String destination;
                                  if (currentCourse.destLat != null && currentCourse.destLong != null) {
                                    destination = "${currentCourse.destLat},${currentCourse.destLong}";
                                  } else if (currentCourse.destination.isNotEmpty) {
                                    destination = Uri.encodeComponent(currentCourse.destination);
                                  } else {
                                    throw "Destination non disponible";
                                  }

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
    String? clientPhone,
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
      // Parse courseId with fallback - no restrictions
      final courseIdInt = int.tryParse(courseId ?? '0') ?? 0;

      print("📱 [CHAT] Opening chat for course: $courseIdInt");
      print("📱 [CHAT] Client name: $clientName");
      print("📱 [CHAT] Client phone: ${clientPhone ?? 'N/A'}");

      // Naviguer vers la page de chat avec la nouvelle API - always allow
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            receiverUserName: clientName,
            courseId: courseIdInt,
            driverPhone: clientPhone ?? '',
          ),
        ),
      );
    } catch (e) {
      print('❌ [CHAT] Erreur ouverture chat: $e');
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
    print('🎴 [ClientCard] _buildClientCard called');
    print('🎴 [ClientCard] availableCourses.length: ${viewModel.availableCourses.length}');
    print('🎴 [ClientCard] currentBottomSheetType: ${viewModel.currentBottomSheetType}');

    if (viewModel.availableCourses.isEmpty) {
      print('❌ [ClientCard] availableCourses is EMPTY, returning SizedBox.shrink()');
      return const SizedBox.shrink();
    }

    final client = viewModel.availableCourses.first;
    print('✅ [ClientCard] Rendering card for client: ${client.name} (courseId: ${client.courseId})');

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

        // Parse courseId once and reuse
        final parsedCourseId = int.tryParse(pickupCourse.courseId ?? '0') ?? 0;

        return AcceptedClientBottomSheet(
            key: ValueKey('pickup-${pickupCourse.courseId}'),
            client: pickupCourse,
            clientId: pickupCourse.clientId,
            courseId: parsedCourseId,
            vehicleType: pickupCourse.vehicleType,
            currentLatitude: viewModel.currentPosiction?.latitude,
            currentLongitude: viewModel.currentPosiction?.longitude,
            onCancelRide: () {
              // Annuler la course acceptée - PAS de WidgetsBinding ici
              if (pickupCourse.hasValidCourseId) {
                viewModel.rejectCourseService(parsedCourseId, context);
                viewModel.removeCourse(pickupCourse.courseId!);
              }
              viewModel.setBottomSheetType(BottomSheetAppType.none);
            },
            onStartRide: () {
              // PAS de WidgetsBinding ici
              viewModel.startTrip();
              viewModel.startCourseService(parsedCourseId, context);
            },
            onCallClients: () {
              // Logique d'appel du client
            },
            onChatClients: () async {
              // No restrictions - chat can always be opened with the course ID
              print("📱 [CHAT] Opening chat with courseId: $parsedCourseId");
              await _openChatWithLoading(
                context: context,
                clientId: pickupCourse.clientId ?? '',
                clientName: pickupCourse.name,
                courseId: parsedCourseId.toString(),
                clientPhone: null, // Phone not available in pickup course model
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
            final courseIdString = viewModel.currentCourse!.courseId ?? '';
            final isPickup = viewModel.currentCourse!.isPickupCourse;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => isPickup
                    ? PickupRecapView(
                        viewModel: viewModel,
                        courseId: courseId,
                        onSoumettre: () {
                          // Use the captured courseIdString instead of accessing viewModel.currentCourse
                          if (courseIdString.isNotEmpty) {
                            viewModel.removeCourse(courseIdString);
                          }

                          // Clear any pending restoration data to prevent re-restoration
                          final restorationService = locator<CourseRestorationService>();
                          restorationService.clearPendingRestoration();

                          // Navigate back to home, clearing the navigation stack
                          final navigationService = locator<NavigationService>();
                          // First pop the recap view to return to courses view briefly
                          Navigator.of(context).pop();
                          // Then navigate to home
                          navigationService.navigateToHomemainView();
                        },
                      )
                    : RecapitulatifCoursePage(
                        viewModel: viewModel,
                        courseId: courseId,
                        onSoumettre: () {
                          // Use the captured courseIdString instead of accessing viewModel.currentCourse
                          if (courseIdString.isNotEmpty) {
                            viewModel.removeCourse(courseIdString);
                          }

                          // Clear any pending restoration data to prevent re-restoration
                          final restorationService = locator<CourseRestorationService>();
                          restorationService.clearPendingRestoration();

                          // Navigate back to home, clearing the navigation stack
                          final navigationService = locator<NavigationService>();
                          // First pop the recap view to return to courses view briefly
                          Navigator.of(context).pop();
                          // Then navigate to home
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
    // Use locator to get the singleton instance instead of creating a new one
    final viewModel = locator<CoursesViewModel>();

    // Set up HomemainViewModel reference
    final homeMainViewModel = locator<HomemainViewModel>();
    viewModel.setHomeMainViewModel(homeMainViewModel);

    // Initialize the ViewModel (has guard to prevent double initialization)
    viewModel.initializeViewModel();
    return viewModel;
  }

  @override
  bool get disposeViewModel => false; // CRITICAL: Don't dispose Singleton ViewModel

  @override
  void onViewModelReady(CoursesViewModel viewModel) {
    super.onViewModelReady(viewModel);

    // ⚡ CRITICAL: Check for pending restoration every time the view is shown
    // This ensures pickup courses started from PickUpPage are properly restored
    // Also refresh stored notifications to handle notification taps
    // Schedule for next frame to avoid build conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await viewModel.checkPendingRestoration();

      // Refresh notifications and show bottom sheet if courses are available
      // This handles notification tap scenarios where the view is shown from a notification
      await viewModel.refreshNotificationsAndShowBottomSheet();
    });
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_location_alt,
                        color: Colors.black,
                        size: 26,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'PICKUP',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
