import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'profil_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilView extends StackedView<ProfilViewModel> {
  const ProfilView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ProfilViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: viewModel.isLoading
          ? Center(
              child: LoadingAnimationWidget.fourRotatingDots(
                color: kcPrimaryColor,
                size: 50,
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    // Avatar avec photo de profil
                    Container(
                      margin: const EdgeInsets.only(bottom: 40),
                      child: Stack(
                        children: [
                          // Avatar principal
                          GestureDetector(
                            onTap: () => _showPhotoOptions(context, viewModel),
                            child: _buildProfileAvatar(viewModel),
                          ),
                          // Bouton d'édition
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: () => _showPhotoOptions(context, viewModel),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: kcPrimaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: viewModel.isUploadingPhoto
                                    ? const Padding(
                                        padding: EdgeInsets.all(8),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.camera_alt,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Stats Section
                    Container(
                      padding: const EdgeInsets.fromLTRB(25, 0, 25, 30),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              viewModel.globalStats?.totalActivities.toString() ?? '0',
                              'Courses',
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildStatCard(
                              viewModel.globalStats?.totalNotes.toString() ?? '0',
                              'Note',
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildStatCard(
                              _formatAmount(viewModel.globalStats?.totalEarnings.toDouble() ?? 0),
                              'Revenus',
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Menu Section
                    Container(
                      padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: _buildUserIcon(),
                            text: 'Mon compte',
                            onTap: () => viewModel.navigateToEditProfile(context),
                          ),
                          _buildMenuItem(
                            icon: _buildCarIcon(),
                            text: 'Mes véhicules',
                            onTap: () => viewModel.navigationService.navigateToMesVehiculesView(),
                          ),
                          _buildMenuItem(
                            icon: _buildDocumentsIcon(),
                            text: 'Documents',
                            onTap: () => viewModel.navigationService.navigateToDocumentsView(),
                          ),
                          _buildMenuItem(
                            icon: _buildHistoryIcon(),
                            text: 'Historique',
                            onTap: () => viewModel.navigationService.navigateToActivityView(),
                          ),
                          _buildMenuItem(
                            icon: _buildLogoutIcon(),
                            text: 'Déconnexion',
                            isLogout: true,
                            onTap: () => viewModel.showLogoutConfirmationDialog(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // 🎯 Nouvelle méthode pour gérer l'affichage de l'avatar
  Widget _buildProfileAvatar(ProfilViewModel viewModel) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(60),
        gradient: viewModel.user?.photoUrl == null
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF184E9C), Color(0xFF2A5BB8)],
              )
            : null,
      ),
      child: viewModel.user?.photoUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: CachedNetworkImage(
                imageUrl: viewModel.user!.photoUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF184E9C), Color(0xFF2A5BB8)],
                    ),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF184E9C), Color(0xFF2A5BB8)],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      viewModel.initials,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // 🔑 IMPORTANT: Force le rechargement de l'image
                cacheKey: '${viewModel.user!.photoUrl}_${DateTime.now().millisecondsSinceEpoch}',
              ),
            )
          : Center(
              child: Text(
                viewModel.initials,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }

  void _showPhotoOptions(BuildContext context, ProfilViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (viewModel.user?.photoUrl == null)
                  ListTile(
                    leading: const Icon(Icons.add_a_photo, color: kcPrimaryColor),
                    title: const Text('Ajouter une photo'),
                    onTap: () {
                      Navigator.pop(context);
                      viewModel.pickAndUploadPhoto(context);
                    },
                  )
                else ...[
                  ListTile(
                    leading: const Icon(Icons.edit, color: kcPrimaryColor),
                    title: const Text('Modifier la photo'),
                    onTap: () {
                      Navigator.pop(context);
                      viewModel.pickAndUploadPhoto(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Supprimer la photo'),
                    onTap: () {
                      Navigator.pop(context);
                      viewModel.deleteProfilePhoto(context);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M F';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1).replaceAll('.0', '')}K F';
    } else {
      return '${amount.toStringAsFixed(0)} F';
    }
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF184E9C),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required Widget icon,
    required String text,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SizedBox(width: 20, height: 20, child: icon),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 15,
                    color: isLogout ? const Color(0xFFDC3545) : const Color(0xFF333333),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '›',
                style: TextStyle(
                  fontSize: 18,
                  color: isLogout ? const Color(0xFFDC3545) : const Color(0xFF999999),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserIcon() => const Icon(Icons.person_outline, size: 24);
  Widget _buildCarIcon() => const Icon(Icons.directions_car_outlined, size: 24);
  Widget _buildDocumentsIcon() => const Icon(Icons.description_outlined, size: 24);
  Widget _buildHistoryIcon() => const Icon(Icons.history_outlined, size: 24);
  Widget _buildLogoutIcon() => const Icon(Icons.logout_outlined, size: 24);

  @override
  ProfilViewModel viewModelBuilder(BuildContext context) => ProfilViewModel();
}