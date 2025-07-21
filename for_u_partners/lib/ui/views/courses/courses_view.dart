import 'courses_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/ui/common/api_constant.dart';
import 'package:for_u_partners/ui/common/enum/bottom_enum.dart';
import 'package:for_u_partners/ui/views/courses/recap_view.dart';
import 'package:for_u_partners/ui/views/courses/widget/dialog_widget.dart';
import 'package:for_u_partners/ui/views/courses/widget/customers_sheet_widget.dart';

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
        //padding: const EdgeInsets.only(left: 25.0, right: 25.0),
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
                  // Bouton pour recentrer sur la position utilisateur
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: FloatingActionButton(
                      onPressed: viewModel.recenterOnUserLocation,
                      backgroundColor: Colors.blue,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.white,
                      ),
                    ),
                  ),
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
                ],
              ),
      ),
    );
  }

  Widget _buildBottomSheet(CoursesViewModel viewModel, BuildContext context) {
    switch (viewModel.currentBottomSheetType) {
      case BottomSheetAppType.clients:
        return ClientsBottomSheet(
          key: const ValueKey('clients'),
          getClientsList: viewModel.getClientsList(),
          onAccept: () {
            viewModel.setBottomSheetType(BottomSheetAppType.pickup);
          },
          onDecline: () {
            viewModel.setBottomSheetType(BottomSheetAppType.none);
          },
        );

      case BottomSheetAppType.pickup:
        return AcceptedClientBottomSheet(
          key: const ValueKey('pickup'),
          client: viewModel.getClientsList()[0],
          onCancelRide: () {
            print("Pickup confirmé");
            viewModel.setBottomSheetType(BottomSheetAppType.none);
          },
          onStartRide: () {
            viewModel.setBottomSheetType(BottomSheetAppType.inprogress);
          },
          onCallClients: () {},
        );

      case BottomSheetAppType.inprogress:
        return InProgressRideBottomSheet(
          key: const ValueKey('inprogress'),
          client: viewModel.getClientsList()[0],
          onCancelRide: () {
            print("Pickup confirmé");
            viewModel.setBottomSheetType(BottomSheetAppType.none);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecapitulatifCoursePage(
                  pointDepart: 'Seme City, Cadjehoun',
                  destination: 'EREVAN, Cadjehoun Aeroport',
                  nomClient: 'Teddy TOSSOU',
                  initialeClient: 'T',
                  distance: 21.0,
                  prix: 250,
                  moyenPaiement: 'Espèces',
                  coutParMinute: 1.0,
                  coutDistance: 220.0,
                  onSoumettre: () {
                    final navigationService = locator<NavigationService>();
                    navigationService.navigateToHomemainView();
                  },
                ),
              ),
            );
          },
          onAddPenalily: () {},
          onCallClients: () {},
          price: 2,
        );

      case BottomSheetAppType.none:
      default:
        return const SizedBox.shrink(
          key: ValueKey('none'),
        );
    }
  }

  @override
  CoursesViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      CoursesViewModel();
}
