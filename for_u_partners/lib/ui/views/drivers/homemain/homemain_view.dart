import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:stacked/stacked.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'homemain_viewmodel.dart';

const double _kSidebarWidth = 280;

class HomemainView extends StackedView<HomemainViewModel> {
  const HomemainView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    HomemainViewModel viewModel,
    Widget? child,
  ) {
    final navItems = [
      _NavItemData(
        index: 0,
        label: 'Accueil',
        builder: (context) =>
            viewModel.buildNavItem("assets/Home.png", 0, viewModel),
      ),
      _NavItemData(
        index: 1,
        label: 'Activités',
        builder: (context) =>
            viewModel.buildNavItem("assets/refresh.png", 1, viewModel),
      ),
      _NavItemData(
        index: 2,
        label: 'Portefeuille',
        builder: (context) => Icon(
          Icons.account_balance_wallet_outlined,
          color: viewModel.currentIndex == 2 ? kcPrimaryColor : kcLightGrey,
          size: 24,
        ),
      ),
      _NavItemData(
        index: 3,
        label: 'Notifications',
        builder: (context) =>
            viewModel.buildNavItem("assets/Bell.png", 3, viewModel),
      ),
    ];

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
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: KeyedSubtree(
                key: ValueKey<int>(viewModel.currentIndex),
                child: viewModel.getViewFromIndex(viewModel.currentIndex),
              ),
            ),
          ),
          if (viewModel.isNavigationOpen)
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: viewModel.closeNavigation,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.35),
                ),
              ),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOut,
            top: 0,
            bottom: 0,
            left: viewModel.isNavigationOpen ? 0 : -_kSidebarWidth,
            child: SizedBox(
              width: _kSidebarWidth,
              child: _AppleStyleSideNavigation(
                items: navItems,
                currentIndex: viewModel.currentIndex,
                onItemSelected: viewModel.handleNavigationSelection,
                onClose: viewModel.closeNavigation,
                viewModel: viewModel,
              ),
            ),
          ),
          if (!viewModel.isNavigationOpen)
            Positioned(
              top: 60,
              left: 16,
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    _SidebarToggleButton(
                      onTap: viewModel.toggleNavigation,
                    ),
                    const SizedBox(width: 12),
                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.grey.withValues(alpha: 0.12),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              'v${snapshot.data!.version}+${snapshot.data!.buildNumber}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: kcPrimaryColor,
                                letterSpacing: -0.2,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  HomemainViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      HomemainViewModel();
}

Widget _buildCoursesIcon(HomemainViewModel viewModel) {
  final hasPendingCourses = viewModel.pendingCoursesCount > 0;
  final isSelected = viewModel.currentIndex == 2;
  final icon = Icon(
    Icons.map_outlined,
    color: isSelected ? kcPrimaryColor : kcLightGrey,
    size: 24,
  );

  if (!hasPendingCourses) {
    return icon;
  }

  return badges.Badge(
    position: badges.BadgePosition.topEnd(top: -10, end: -10),
    badgeContent: Text(
      '${viewModel.pendingCoursesCount}',
      style: const TextStyle(color: Colors.white, fontSize: 10),
    ),
    child: icon,
  );
}

class _NavItemData {
  const _NavItemData({
    required this.index,
    required this.label,
    required this.builder,
  });

  final int index;
  final String label;
  final WidgetBuilder builder;
}

class _AppleStyleSideNavigation extends StatelessWidget {
  const _AppleStyleSideNavigation({
    required this.items,
    required this.currentIndex,
    required this.onItemSelected,
    required this.onClose,
    required this.viewModel,
  });

  final List<_NavItemData> items;
  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onClose;
  final HomemainViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFAFAFA),
      elevation: 24,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: SafeArea(
        right: false,
        child: Column(
          children: [
            // Profile Header Section
            _buildProfileHeader(context),

            const SizedBox(height: 8),

            // Main Navigation
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Navigation Items
                  ...items.map((item) {
                    final isSelected = currentIndex == item.index;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: _AppleNavItem(
                        label: item.label,
                        isSelected: isSelected,
                        onTap: () => onItemSelected(item.index),
                        icon: item.builder(context),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // Section Divider
                  const Divider(height: 1, thickness: 0.5),

                  const SizedBox(height: 16),

                  // Secondary Menu Items
                  _AppleMenuItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Mon compte',
                    onTap: () => onItemSelected(8),
                  ),
                  _AppleMenuItem(
                    icon: Icons.directions_car_outlined,
                    label: 'Mes véhicules',
                    onTap: () => onItemSelected(9),
                  ),
                  _AppleMenuItem(
                    icon: Icons.description_outlined,
                    label: 'Documents',
                    onTap: () => onItemSelected(5),
                  ),
                  _AppleMenuItem(
                    icon: Icons.bar_chart_rounded,
                    label: 'Statistiques',
                    onTap: () => onItemSelected(10),
                  ),
                  _AppleMenuItem(
                    icon: Icons.headset_mic_rounded,
                    label: 'Assistance',
                    onTap: () => onItemSelected(7),
                  ),
                ],
              ),
            ),

            // Logout Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: _AppleLogoutButton(
                onTap: () => onItemSelected(6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Profile Photo
          GestureDetector(
            onTap: () => _showPhotoOptions(context),
            child: Stack(
              children: [
                _buildProfileAvatar(),
                // Edit Badge
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: kcPrimaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: viewModel.isUploadingPhoto
                        ? const Padding(
                            padding: EdgeInsets.all(6),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt,
                            size: 14,
                            color: Colors.white,
                          ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viewModel.userName ?? 'Conducteur',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: viewModel.isOnline
                            ? const Color(0xFF34C759)
                            : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      viewModel.isOnline ? 'En ligne' : 'Hors ligne',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: viewModel.user?.photoUrl == null
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF184E9C), Color(0xFF2A5BB8)],
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: viewModel.user?.photoUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(32),
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
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                cacheKey: '${viewModel.user!.photoUrl}_${DateTime.now().millisecondsSinceEpoch}',
              ),
            )
          : Center(
              child: Text(
                viewModel.initials,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                if (viewModel.user?.photoUrl == null)
                  _PhotoOption(
                    icon: Icons.add_a_photo_rounded,
                    label: 'Ajouter une photo',
                    onTap: () {
                      Navigator.pop(context);
                      viewModel.pickAndUploadPhoto(context);
                    },
                  )
                else ...[
                  _PhotoOption(
                    icon: Icons.edit_rounded,
                    label: 'Modifier la photo',
                    onTap: () {
                      Navigator.pop(context);
                      viewModel.pickAndUploadPhoto(context);
                    },
                  ),
                  _PhotoOption(
                    icon: Icons.delete_outline_rounded,
                    label: 'Supprimer la photo',
                    isDestructive: true,
                    onTap: () {
                      Navigator.pop(context);
                      viewModel.deleteProfilePhoto(context);
                    },
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Apple-style navigation item
class _AppleNavItem extends StatelessWidget {
  const _AppleNavItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? kcPrimaryColor.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Center(child: icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? kcPrimaryColor
                        : const Color(0xFF3A3A3C),
                    letterSpacing: -0.2,
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

// Apple-style menu item (for secondary actions)
class _AppleMenuItem extends StatelessWidget {
  const _AppleMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF3A3A3C),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF3A3A3C),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Apple-style logout button
class _AppleLogoutButton extends StatelessWidget {
  const _AppleLogoutButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.red.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.logout_rounded,
                color: Color(0xFFFF3B30),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Déconnexion',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF3B30),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Photo option item for bottom sheet
class _PhotoOption extends StatelessWidget {
  const _PhotoOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive ? const Color(0xFFFF3B30) : kcPrimaryColor,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? const Color(0xFFFF3B30) : const Color(0xFF1A1A1A),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarToggleButton extends StatelessWidget {
  const _SidebarToggleButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 6,
      shape: const CircleBorder(),
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.12),
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
    );
  }
}
