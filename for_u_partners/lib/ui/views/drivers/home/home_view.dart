import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/views/drivers/courses/pick_up_page.dart';
import 'package:stacked/stacked.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'home_viewmodel.dart';
import 'widgets/wallet_widget.dart';
import 'widgets/summary_widget.dart';
import 'widgets/activity_widget.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    HomeViewModel viewModel,
    Widget? child,
  ) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: kcWhiteColors,
          appBar: _buildCustomAppBar(viewModel),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WalletWidget(balance: viewModel.solde.toDouble()),
                  const SizedBox(height: 24),
                  SummaryWidget(
                    todayCourses: viewModel.todayCourses,
                    todayEarnings: viewModel.montantGainToday.toString(),
                  ),
                  const SizedBox(height: 24),
                  _buildSimpleStartRideButton(context),
                  const Text(
                    'Activité récente',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 15),
                  ActivityWidget(
                    recentActivities:
                        viewModel.dailyStats?.activiteRecenteTerminee != null
                            ? [viewModel.dailyStats!.activiteRecenteTerminee!]
                            : null,
                    evaluations: viewModel.dailyStats?.dernieresEvaluations,
                    onActivityTap: () {
                      // Navigation vers le détail de l'activité
                    },
                    onRatingTap: () {
                      // Navigation vers les évaluations
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        if (viewModel.isBusy)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: Center(
              child: LoadingAnimationWidget.fourRotatingDots(
                color: kcPrimaryColor,
                size: 50,
              ),
            ),
          ),
      ],
    );
  }

  PreferredSizeWidget _buildCustomAppBar(HomeViewModel model) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
              bottom: BorderSide(
            color: Color(0xFFe5e7eb),
          )),
          color: Colors.white,
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFF184E9C),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: model.isBusy
                            ? const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(primaryColor),
                              )
                            : Text(
                                model.name!.isNotEmpty == true
                                    ? model.name![0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    model.isBusy
                        ? LoadingAnimationWidget.threeArchedCircle(
                            color: primaryColor,
                            size: 24,
                          )
                        : Text(
                            model.name!.isNotEmpty == true ? model.name! : '?',
                            style: const TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                  ],
                ),
                GestureDetector(
                  onTap: model.isBusy ? null : () => model.toggleOnlineStatus(),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: model.isOnline
                          ? const Color(0xFF10B981)
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          model.isOnline ? 'EN LIGNE' : 'HORS LIGNE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
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
        ),
      ),
    );
  }

  // Bouton pour démarrer une nouvelle course
  Widget _buildSimpleStartRideButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: () {
          // Navigation vers le nouvel écran de réservation
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
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Démarrer une course',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();
}
