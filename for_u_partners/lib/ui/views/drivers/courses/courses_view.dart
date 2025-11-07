import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/services/chat_service.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:for_u_partners/services/driver_service.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/views/drivers/courses/chat_page.dart';
import 'package:for_u_partners/ui/views/drivers/courses/recap_view.dart';
import 'package:for_u_partners/ui/views/drivers/courses/pick_up_page.dart';
import 'package:for_u_partners/ui/views/drivers/homemain/homemain_viewmodel_export.dart';
import 'package:stacked_services/stacked_services.dart';
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
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                  ),
                  // Bouton pour recentrer sur la position utilisateur

                  // Display client card as fixed positioned element
                  if (viewModel.availableCourses.isNotEmpty &&
                      viewModel.currentBottomSheetType == BottomSheetAppType.clients)
                    Positioned(
                      bottom: 100,
                      left: 16,
                      right: 16,
                      child: _buildClientCard(viewModel, context),
                    ),

                  // Other bottom sheets
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

  Future<Widget> _buildBottomSheet(
      CoursesViewModel viewModel, BuildContext context) async {
    // Ne pas afficher si le type est none
    if (viewModel.currentBottomSheetType == BottomSheetAppType.none) {
      return const SizedBox.shrink(key: ValueKey('none'));
    }

    // Vérifier si on a une course en cours
    final hasActiveRide = viewModel.currentCourse != null &&
        (viewModel.isGoingToPickup || viewModel.isOnTrip);

    // Si on a une course en cours mais pas de bottom sheet actif, forcer l'affichage
    if (hasActiveRide &&
        viewModel.currentBottomSheetType == BottomSheetAppType.none) {
      Future.delayed(Duration.zero, () {
        viewModel.setBottomSheetType(BottomSheetAppType.pickup);
      });
      return const SizedBox.shrink(key: ValueKey('delayed-show'));
    }

    switch (viewModel.currentBottomSheetType) {
      case BottomSheetAppType.clients:
        // Now handled by _buildClientCard as a fixed positioned card
        return const SizedBox.shrink(key: ValueKey('clients-handled-elsewhere'));

      case BottomSheetAppType.pickup:
        print(
            '🔄 BottomSheetAppType.pickup - availableCourses: ${viewModel.availableCourses.length}');
        print(
            '🔄 Contenu de availableCourses: ${viewModel.availableCourses.map((c) => '${c.courseId}: ${c.name}').toList()}');
        print('🔄 Current course: ${viewModel.currentCourse?.courseId}');
        if (viewModel.currentCourse == null) {
          print(
              '❌ Aucune course active pour afficher le bottom sheet pickup');
          return const SizedBox.shrink(key: ValueKey('no-pickup'));
        }

        final pickupCourse = viewModel.currentCourse!;
        final chatService = locator<ChatService>();

        return AcceptedClientBottomSheet(
            key: ValueKey('pickup-${pickupCourse.courseId}'),
            client: pickupCourse,
            clientId: pickupCourse.clientId,
            courseId: int.tryParse(pickupCourse.courseId!)!,
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
            });

      case BottomSheetAppType.inprogress:
        // Vérifier d'abord si on a une course en cours
        if (viewModel.currentCourse == null) {
          // Essayer de restaurer l'état de la course
          await viewModel.checkAndRestoreRideState();

          // Si toujours pas de course, vérifier availableCourses en dernier recours
          if (viewModel.currentCourse == null &&
              viewModel.availableCourses.isNotEmpty) {
            viewModel.currentCourse = viewModel.availableCourses.first;
            print(
                'ℹ️ Course récupérée depuis availableCourses: ${viewModel.currentCourse?.courseId}');
          } else if (viewModel.currentCourse == null) {
            print('ℹ️ Aucune course en cours à afficher');
            return const SizedBox.shrink(key: ValueKey('no-inprogress'));
          }
        } else {
          print(
              'ℹ️ Course courante déjà définie: ${viewModel.currentCourse?.courseId}');
        }

        return InProgressRideBottomSheet(
          key: const ValueKey('inprogress'),
          client: viewModel.currentCourse!,
          onCancelRide: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecapitulatifCoursePage(
                  viewModel: viewModel,
                  courseId:
                      int.tryParse(viewModel.currentCourse!.courseId ?? '') ??
                          0,
                  onSoumettre: () {
                    if (viewModel.currentCourse!.hasValidCourseId) {
                      viewModel
                          .removeCourse(viewModel.currentCourse!.courseId!);
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

        return GestureDetector(
          onTap: () async {
            final sharedPrefsService = locator<SharedpreferencesService>();
            final driverService = locator<DriverService>();

            final newStatus = !isOnline;
            await driverService.updateStatus(newStatus);
            await sharedPrefsService.setOnlineStatus(newStatus);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isOnline ? 'EN LIGNE' : 'HORS LIGNE',
                    style: TextStyle(
                      color: isOnline ? Colors.black : Colors.red.shade600,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    isOnline ? Icons.toggle_on : Icons.toggle_off,
                    color: isOnline ? Colors.black : Colors.red.shade600,
                    size: 32,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        outerContext,
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
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
