import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:stacked/stacked.dart';

import 'homemain_viewmodel.dart';

const double _kSidebarWidth = 240;

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
        label: 'Courses',
        builder: (context) => _buildCoursesIcon(viewModel),
      ),
      _NavItemData(
        index: 3,
        label: 'Portefeuille',
        builder: (context) => Icon(
          Icons.account_balance_wallet_outlined,
          color: viewModel.currentIndex == 3 ? kcPrimaryColor : kcLightGrey,
          size: 24,
        ),
      ),
      _NavItemData(
        index: 4,
        label: 'Notifications',
        builder: (context) =>
            viewModel.buildNavItem("assets/Bell.png", 4, viewModel),
      ),
      _NavItemData(
        index: 5,
        label: 'Compte',
        builder: (context) =>
            viewModel.buildNavItem("assets/user.png", 5, viewModel),
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
                  color: Colors.black.withOpacity(0.35),
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
              child: SafeArea(
                right: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: _DriverSideNavigation(
                    items: navItems,
                    currentIndex: viewModel.currentIndex,
                    onItemSelected: viewModel.handleNavigationSelection,
                    onClose: viewModel.closeNavigation,
                    userName: viewModel.userName,
                    isOnline: viewModel.isOnline,
                  ),
                ),
              ),
            ),
          ),
          if (!viewModel.isNavigationOpen)
            Positioned(
              top: 100,
              left: 16,
              child: SafeArea(
                top: false,
                child: _SidebarToggleButton(
                  onTap: viewModel.toggleNavigation,
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

class _DriverSideNavigation extends StatelessWidget {
  const _DriverSideNavigation({
    required this.items,
    required this.currentIndex,
    required this.onItemSelected,
    required this.onClose,
    this.userName,
    required this.isOnline,
  });

  final List<_NavItemData> items;
  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onClose;
  final String? userName;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kcWhiteColors,
      elevation: 16,
      shadowColor: Colors.black.withOpacity(0.2),
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
            decoration: BoxDecoration(
              color: kcPrimaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kcPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.dashboard_rounded,
                    color: kcPrimaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Menu',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: kcPrimaryColor,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                IconButton(
                  splashRadius: 20,
                  onPressed: onClose,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: kcMediumGrey,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          _buildDriverProfile(),
          Divider(height: 1, color: Colors.grey.withOpacity(0.15)),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = currentIndex == item.index;
                return _SideNavItem(
                  label: item.label,
                  isSelected: isSelected,
                  onTap: () => onItemSelected(item.index),
                  icon: item.builder(context),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemCount: items.length,
            ),
          ),
          Divider(height: 1, color: Colors.grey.withOpacity(0.15)),
          const SizedBox(height: 8),
          _BottomMenuItem(
            icon: Icons.help_outline_rounded,
            label: 'Aide & Support',
            onTap: onClose,
          ),
          _BottomMenuItem(
            icon: Icons.person_outline_rounded,
            label: 'Compte',
            onTap: onClose,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDriverProfile() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: kcPrimaryColor,
            child: Text(
              userName?.isNotEmpty == true
                  ? userName![0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              userName?.isNotEmpty == true ? userName! : 'Conducteur',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: kcPrimaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SideNavItem extends StatelessWidget {
  const _SideNavItem({
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
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      kcPrimaryColor.withOpacity(0.15),
                      kcPrimaryColor.withOpacity(0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(14),
            border: isSelected
                ? Border.all(
                    color: kcPrimaryColor.withOpacity(0.2),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              SizedBox(
                height: 26,
                width: 26,
                child: Center(child: icon),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? kcPrimaryColor : kcMediumGrey,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: kcPrimaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomMenuItem extends StatelessWidget {
  const _BottomMenuItem({
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                color: kcPrimaryColor.withOpacity(0.7),
                size: 22,
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: kcMediumGrey,
                  letterSpacing: 0.2,
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
      borderRadius: BorderRadius.circular(12),
      shadowColor: Colors.black.withOpacity(0.15),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.12),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.menu_rounded,
            color: kcPrimaryColor,
            size: 24,
          ),
        ),
      ),
    );
  }
}
