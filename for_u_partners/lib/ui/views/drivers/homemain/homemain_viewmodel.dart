import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:for_u_partners/services/driver_service.dart';
import 'package:for_u_partners/services/profile_photo_service.dart';
import 'package:for_u_partners/models/user_model.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/views/drivers/courses/courses_view.dart';
import 'package:for_u_partners/ui/views/drivers/courses/courses_viewmodel.dart';
import 'package:for_u_partners/ui/views/drivers/activity/activity_view.dart';
import 'package:for_u_partners/ui/views/drivers/notifications/notifications_view.dart';
import 'package:for_u_partners/ui/views/drivers/wallet/wallet_view.dart';
import 'package:for_u_partners/ui/views/drivers/profil/edit_profile_view.dart';
import 'package:for_u_partners/ui/views/drivers/profil/profil_viewmodel.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class HomemainViewModel extends IndexTrackingViewModel {
  final _sharedpreferencesService = locator<SharedpreferencesService>();
  final _navigationService = locator<NavigationService>();
  final _driverService = locator<DriverService>();

  // Lazy getter for ProfilePhotoService to avoid initialization issues
  ProfilePhotoService get _profilePhotoService => locator<ProfilePhotoService>();

  // Référence au CoursesViewModel pour notifier les changements de statut
  CoursesViewModel? _coursesViewModel;

  void setCoursesViewModel(CoursesViewModel viewModel) {
    _coursesViewModel = viewModel;
  }

  // Compteur de courses en attente
  int _pendingCoursesCount = 0;

  int get pendingCoursesCount => _pendingCoursesCount;
  bool _isNavigationOpen = false;

  bool get isNavigationOpen => _isNavigationOpen;

  // User data
  String? _userName;
  bool _isOnline = false;
  UserModel? _user;
  bool _isUploadingPhoto = false;
  String _initials = '';

  String? get userName => _userName;
  bool get isOnline => _isOnline;
  UserModel? get user => _user;
  bool get isUploadingPhoto => _isUploadingPhoto;
  String get initials => _initials;

  HomemainViewModel() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _userName = await _sharedpreferencesService.getUserName();
    _isOnline = await _sharedpreferencesService.getOnlineStatus() ?? false;

    // Load full user profile
    try {
      _user = await _driverService.getUserProfile();
      if (_user != null) {
        _initials = _user!.nom[0].toUpperCase() + _user!.prenom[0].toUpperCase();
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }

    notifyListeners();
  }

  /// Pick and upload profile photo
  Future<void> pickAndUploadPhoto(BuildContext context) async {
    try {
      debugPrint('🖼️ [PHOTO] Starting photo selection process...');

      final picker = ImagePicker();

      // Show dialog to choose source
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Choisir une source'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galerie'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Caméra'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              ],
            ),
          );
        },
      );

      if (source == null) {
        debugPrint('🖼️ [PHOTO] User cancelled source selection');
        return;
      }

      debugPrint('🖼️ [PHOTO] Selected source: $source');

      // Select image with automatic optimization
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        debugPrint('🖼️ [PHOTO] No image selected');
        return;
      }

      final photoFile = File(pickedFile.path);
      final fileSize = await photoFile.length();
      debugPrint('🖼️ [PHOTO] Image selected: ${pickedFile.path}');
      debugPrint('🖼️ [PHOTO] Image size: ${(fileSize / 1024).toStringAsFixed(2)} KB');

      // Upload photo
      _isUploadingPhoto = true;
      notifyListeners();

      await _profilePhotoService.updateProfilePhoto(photoFile, context: context);

      // Refresh user profile
      debugPrint('🖼️ [PHOTO] Refreshing user profile...');
      await _loadUserData();

      _isUploadingPhoto = false;
      notifyListeners();

      // Show success message
      if (context.mounted) {
        _showSuccessSnackBar(context, 'Photo de profil mise à jour avec succès');
      }
    } catch (e) {
      debugPrint('❌ [PHOTO ERROR] Failed to update photo: $e');
      _isUploadingPhoto = false;
      notifyListeners();

      if (context.mounted) {
        _showErrorSnackBar(context, 'Erreur lors de la mise à jour de la photo: $e');
      }
    }
  }

  Future<void> deleteProfilePhoto(BuildContext context) async {
    try {
      final confirmed = await _showDeletePhotoConfirmation(context);
      if (!confirmed) return;

      _isUploadingPhoto = true;
      notifyListeners();

      await _profilePhotoService.deleteProfilePhoto();
      await _loadUserData();

      _isUploadingPhoto = false;
      notifyListeners();

      if (context.mounted) {
        _showSuccessSnackBar(context, 'Photo de profil supprimée');
      }
    } catch (e) {
      _isUploadingPhoto = false;
      notifyListeners();

      if (context.mounted) {
        _showErrorSnackBar(context, 'Erreur lors de la suppression: $e');
      }
    }
  }

  Future<bool> _showDeletePhotoConfirmation(BuildContext context) async {
    if (Platform.isIOS) {
      return await showCupertinoDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Supprimer la photo'),
          content: const Text('Voulez-vous vraiment supprimer votre photo de profil ?'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Supprimer'),
            ),
          ],
        ),
      ) ?? false;
    } else {
      return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Supprimer la photo'),
          content: const Text('Voulez-vous vraiment supprimer votre photo de profil ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        ),
      ) ?? false;
    }
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Mettre à jour le compteur de courses en attente
  void updatePendingCoursesCount(int count) {
    _pendingCoursesCount = count;
    notifyListeners();
  }

  // Notifier le changement de statut en ligne au CoursesViewModel
  Future<void> notifyOnlineStatusChanged(bool isOnline) async {
    _isOnline = isOnline;
    notifyListeners();

    // Notify courses view to start/stop general position tracking
    if (_coursesViewModel != null) {
      await _coursesViewModel!.onDriverOnlineStatusChanged(isOnline);
    }
  }

  getViewFromIndex(int index) {
    switch (index) {
      case 0:
        return const CoursesView();
      case 1:
        return const ActivityView();
      case 2:
        return const WalletView();
      case 3:
        return const NotificationsView();
      default:
        return const CoursesView();
    }
  }

  buildNavItem(String assetName, int index, HomemainViewModel viewModel) {
    return Image.asset(
      assetName,
      height: 22,
      width: 22,
      color: viewModel.currentIndex == index ? kcPrimaryColor : kcLightGrey,
    );
  }

  void toggleNavigation() {
    _isNavigationOpen = !_isNavigationOpen;
    if (_isNavigationOpen) {
      _loadUserData(); // Refresh user data when opening
    }
    notifyListeners();
  }

  void openNavigation() {
    if (_isNavigationOpen) return;
    _isNavigationOpen = true;
    _loadUserData(); // Refresh user data when opening
    notifyListeners();
  }

  void closeNavigation() {
    if (!_isNavigationOpen) return;
    _isNavigationOpen = false;
    notifyListeners();
  }

  void handleNavigationSelection(int index) {
    closeNavigation();

    // Handle special cases (Documents, Assistance, Mon compte, Mes véhicules, Statistiques, and Logout)
    if (index == 5) {
      // Navigate to Documents
      _navigationService.navigateToDocumentsView();
      return;
    }

    if (index == 7) {
      // Navigate to Assistance
      _navigationService.navigateToAssistanceTechniqueView();
      return;
    }

    if (index == 8) {
      // Navigate to Edit Profile (Mon compte)
      navigateToEditProfile();
      return;
    }

    if (index == 9) {
      // Navigate to Mes véhicules
      _navigationService.navigateToMesVehiculesView();
      return;
    }

    if (index == 10) {
      // Navigate to Statistiques
      _navigationService.navigateToStatistiquesView();
      return;
    }

    if (index == 6) {
      // Show logout confirmation dialog
      _showLogoutConfirmationDialog();
      return;
    }

    // Handle normal navigation
    if (currentIndex != index) {
      setIndex(index);
    }
  }

  void navigateToEditProfile() {
    if (_user != null) {
      final context = _navigationService.navigatorKey?.currentContext;
      if (context != null) {
        // Create a ProfilViewModel instance for EditProfileView
        final profilViewModel = ProfilViewModel();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EditProfileView(
              user: _user!,
              viewModel: profilViewModel,
            ),
          ),
        ).then((_) {
          // Reload user data when returning from edit profile
          _loadUserData();
        });
      }
    }
  }

  void _showLogoutConfirmationDialog() {
    if (Platform.isIOS) {
      _showCupertinoLogoutDialog();
    } else {
      _showMaterialLogoutDialog();
    }
  }

  Future<void> logOut() async {
    try {
      print("logout: setting status to false");
      await _driverService.updateStatus(false);
      await _sharedpreferencesService.setOnlineStatus(false);
      print("logout: status updated successfully");
    } catch (e) {
      print("logout: error updating status: $e");
    }
    _sharedpreferencesService.removeToken();
    _navigationService.replaceWithLoginView();
  }

  void _showMaterialLogoutDialog() {
    final context = _navigationService.navigatorKey?.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.logout_rounded, color: Colors.red[600], size: 24),
                const SizedBox(width: 12),
                const Text('Déconnexion', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              ],
            ),
            content: const Text(
              'Êtes-vous sûr de vouloir vous déconnecter de votre compte ?',
              style: TextStyle(fontSize: 16),
            ),
            contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text('Annuler', style: TextStyle(fontWeight: FontWeight.w500)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  logOut();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Se déconnecter', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          );
        },
      );
    }
  }

  void _showCupertinoLogoutDialog() {
    final context = _navigationService.navigatorKey?.currentContext;
    context?.let((ctx) {
      showCupertinoDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Déconnexion', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            content: const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Êtes-vous sûr de vouloir vous déconnecter de votre compte ?',
                style: TextStyle(fontSize: 13),
              ),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler', style: TextStyle(color: CupertinoColors.activeBlue, fontWeight: FontWeight.w400)),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.of(context).pop();
                  logOut();
                },
                child: const Text('Se déconnecter', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          );
        },
      );
    });
  }
}

extension NullableContextExtension on BuildContext? {
  void let(void Function(BuildContext) block) {
    if (this != null) {
      block(this!);
    }
  }
}
