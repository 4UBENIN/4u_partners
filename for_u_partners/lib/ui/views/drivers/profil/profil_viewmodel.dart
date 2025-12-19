import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:for_u_partners/models/global_stats_model.dart';
import 'package:for_u_partners/models/user_model.dart';
import 'package:for_u_partners/services/driver_service.dart';
import 'package:for_u_partners/services/profile_photo_service.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:for_u_partners/ui/views/drivers/profil/edit_profile_view.dart';
import 'package:stacked/stacked.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:image_picker/image_picker.dart';

class ProfilViewModel extends BaseViewModel {
  final navigationService = locator<NavigationService>();
  final _sharedPreferencesServices = locator<SharedpreferencesService>();
  final _driverService = locator<DriverService>();
  final _profilePhotoService = locator<ProfilePhotoService>();
  final _snackbarService = locator<SnackbarService>(); 

  GlobalStats? _globalStats;
  UserModel? _user;
  bool _isLoading = false;
  bool _isEditing = false;
  bool _isUploadingPhoto = false;
  String? _errorMessage;
  String _initials = '';

  // Getters
  GlobalStats? get globalStats => _globalStats;
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isEditing => _isEditing;
  bool get isUploadingPhoto => _isUploadingPhoto;
  String? get errorMessage => _errorMessage;
  String get initials => _initials;

  ProfilViewModel() {
    init();
  }

  Future<void> init() async {
    await Future.wait([
      loadGlobalStats(),
      loadUserProfile(),
    ]);
  }

  /// Sélectionne et upload une photo de profil
  ///
  /// Affiche un dialogue pour choisir entre la caméra ou la galerie,
  /// puis optimise et upload l'image sélectionnée
  Future<void> pickAndUploadPhoto(BuildContext context) async {
    try {
      debugPrint('🖼️ [PHOTO] Starting photo selection process...');

      final picker = ImagePicker();

      // 1. Afficher un dialogue pour choisir la source
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

      // 2. Sélectionner l'image avec optimisation automatique
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024, // Limite la largeur à 1024px
        maxHeight: 1024, // Limite la hauteur à 1024px
        imageQuality: 85, // Qualité de compression (0-100)
      );

      if (pickedFile == null) {
        debugPrint('🖼️ [PHOTO] No image selected');
        return;
      }

      final photoFile = File(pickedFile.path);
      final fileSize = await photoFile.length();
      debugPrint('🖼️ [PHOTO] Image selected: ${pickedFile.path}');
      debugPrint('🖼️ [PHOTO] Image size: ${(fileSize / 1024).toStringAsFixed(2)} KB');

      // 3. Upload de la photo
      _isUploadingPhoto = true;
      notifyListeners();

      await _profilePhotoService.updateProfilePhoto(photoFile, context: context);

      // 4. Mettre à jour l'utilisateur avec la nouvelle URL
      debugPrint('🖼️ [PHOTO] Refreshing user profile...');
      await loadUserProfile();

      _isUploadingPhoto = false;
      notifyListeners();

      // 5. Afficher le SnackBar de succès APRÈS avoir mis à jour l'état
      if (context.mounted) {
        _showSuccessSnackBar(context, 'Photo de profil mise à jour avec succès');
      }
    } catch (e) {
      debugPrint('❌ [PHOTO ERROR] Failed to update photo: $e');
      _isUploadingPhoto = false;
      notifyListeners();

      // Vérifier que le context est toujours monté
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
      await loadUserProfile();

      _isUploadingPhoto = false;
      notifyListeners();

      // Vérifier que le context est toujours monté
      if (context.mounted) {
        _showSuccessSnackBar(context, 'Photo de profil supprimée');
      }
    } catch (e) {
      _isUploadingPhoto = false;
      notifyListeners();
      
      // Vérifier que le context est toujours monté
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
    // Double vérification avant d'afficher
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
    // Double vérification avant d'afficher
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

  void showLogoutConfirmationDialog(BuildContext context) {
    if (Platform.isIOS) {
      _showCupertinoLogoutDialog(context);
    } else {
      _showMaterialLogoutDialog(context);
    }
  }

  Future<void> logOut() async {
    try {
      print("logout: setting status to false");
      await _driverService.updateStatus(false);
      await _sharedPreferencesServices.setOnlineStatus(false);
      print("logout: status updated successfully");
    } catch (e) {
      print("logout: error updating status: $e");
    }
    _sharedPreferencesServices.removeToken();
    navigationService.replaceWithLoginView();
  }

  void _showMaterialLogoutDialog(BuildContext context) {
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

  void _showCupertinoLogoutDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
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
  }

  Future<void> loadUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _driverService.getUserProfile();
      _initials = _user!.nom[0].toUpperCase() + _user!.prenom[0].toUpperCase();
    } catch (e) {
      _errorMessage = 'Impossible de charger le profil: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserProfile({
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
    String? adresse,
    String? dateNaissance,
    String? genre,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _driverService.updateUserProfile(
        nom: nom,
        prenom: prenom,
        email: email,
        telephone: telephone,
        adresse: adresse,
        dateNaissance: dateNaissance,
        genre: genre,
      );
      _isEditing = false;
    } catch (e) {
      _errorMessage = 'Échec de la mise à jour: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleEditMode() {
    _isEditing = !_isEditing;
    notifyListeners();
  }

  Future<void> loadGlobalStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _globalStats = await _driverService.fetchGlobalStats();
    } catch (e) {
      _errorMessage = 'Impossible de charger les statistiques: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void navigateToEditProfile(BuildContext context) {
    if (user != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EditProfileView(user: user!, viewModel: this),
        ),
      );
    }
  }
}