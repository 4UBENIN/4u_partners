import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/views/drivers/courses/pick_up_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:stacked/stacked.dart';

import 'home_viewmodel.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    HomeViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: kcWhiteColors,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildMap(viewModel),
          ),
          Positioned(
            bottom: 170,
            right: 16,
            child: SafeArea(
              bottom: false,
              child: _MapControlButton(
                onTap:
                    viewModel.hasLocation ? viewModel.recenterOnDriver : null,
                icon: Icons.my_location_rounded,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomPanel(context, viewModel),
          ),
          if (viewModel.errorMessage != null && !viewModel.isBusy)
            Positioned(
              top: 130,
              left: 16,
              right: 16,
              child: _ErrorBanner(message: viewModel.errorMessage!),
            ),
          if (viewModel.isBusy)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.2),
                child: Center(
                  child: LoadingAnimationWidget.fourRotatingDots(
                    color: kcPrimaryColor,
                    size: 50,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();
}

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({
    required this.onTap,
    required this.icon,
  });

  final VoidCallback? onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 6,
      borderRadius: BorderRadius.circular(12),
      shadowColor: Colors.black.withOpacity(0.15),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: onTap != null ? kcPrimaryColor : kcLightGrey,
            size: 26,
          ),
        ),
      ),
    );
  }
}

// Removed _buildDriverStatusBar - driver info now in sidebar

Widget _buildMap(HomeViewModel viewModel) {
  if (!viewModel.hasLocation && !viewModel.isBusy) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  if (viewModel.currentPosition == null) {
    return Container(
      color: Colors.white,
    );
  }

  final driverMarker = Marker(
    markerId: const MarkerId('driver-position'),
    position: viewModel.currentPosition!,
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
  );

  return GoogleMap(
    onMapCreated: viewModel.onMapCreated,
    initialCameraPosition: CameraPosition(
      target: viewModel.currentPosition!,
      zoom: 15.5,
    ),
    myLocationEnabled: true,
    myLocationButtonEnabled: false,
    zoomControlsEnabled: false,
    trafficEnabled: true,
    compassEnabled: false,
    markers: {driverMarker},
  );
}

Widget _buildBottomPanel(BuildContext context, HomeViewModel model) {
  return SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 24,
                  offset: const Offset(0, -2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                _StatTile(
                  title: 'Gains du jour',
                  value: '${model.montantGainToday.toStringAsFixed(0)} FCFA',
                  icon: Icons.payments_outlined,
                ),
                Container(
                  height: 46,
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 18),
                  color: kcLightGrey.withOpacity(0.2),
                ),
                _StatTile(
                  title: 'Courses',
                  value: '${model.todayCourses}',
                  icon: Icons.directions_car_filled_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSimpleStartRideButton(context),
          const SizedBox(height: 16),
          _buildStatusToggle(model),
        ],
      ),
    ),
  );
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  kcPrimaryColor.withOpacity(0.15),
                  kcPrimaryColor.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: kcPrimaryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: kcLightGrey.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: kcPrimaryColor,
                    letterSpacing: -0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      color: Colors.red.withOpacity(0.92),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildSimpleStartRideButton(BuildContext context) {
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

Widget _buildStatusToggle(HomeViewModel model) {
  return GestureDetector(
    onTap: model.isBusy ? null : model.toggleOnlineStatus,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: model.isOnline
              ? [
                  const Color(0xFF10B981),
                  const Color(0xFF059669),
                ]
              : [
                  const Color(0xFF9CA3AF),
                  const Color(0xFF6B7280),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (model.isOnline
                    ? const Color(0xFF10B981)
                    : const Color(0xFF9CA3AF))
                .withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            model.isOnline ? 'EN LIGNE' : 'HORS LIGNE',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            model.isOnline ? Icons.toggle_on : Icons.toggle_off,
            color: Colors.white,
            size: 32,
          ),
        ],
      ),
    ),
  );
}
