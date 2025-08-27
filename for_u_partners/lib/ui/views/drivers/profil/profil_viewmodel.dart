import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:for_u_partners/models/global_stats_model.dart';
import 'package:for_u_partners/models/user_model.dart';
import 'package:for_u_partners/services/driver_service.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:for_u_partners/ui/views/drivers/profil/edit_profile_view.dart';
import 'package:stacked/stacked.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';

class ProfilViewModel extends BaseViewModel {
  final navigationService = locator<NavigationService>();
  final _sharedPreferencesServices = locator<SharedpreferencesService>();
  final _driverService = locator<DriverService>();

  GlobalStats? _globalStats;
  UserModel? _user;
  bool _isLoading = false;
  bool _isEditing = false;
  String? _errorMessage;
  String _initials = '';
  // Getters
  GlobalStats? get globalStats => _globalStats;
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isEditing => _isEditing;
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

  void showLogoutConfirmationDialog(BuildContext context) {
  if (Platform.isIOS) {
    _showCupertinoLogoutDialog(context);
  } else {
    _showMaterialLogoutDialog(context);
  }
}


  //* AUTH METHODS
  void logOut() {
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
            Icon(
              Icons.logout_rounded,
              color: Colors.red[600],
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              'Déconnexion',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
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
            child: const Text(
              'Annuler',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Se déconnecter',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      );
    },
  );
}

// Style Cupertino (iOS)
void _showCupertinoLogoutDialog(BuildContext context) {
  showCupertinoDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: const Text(
          'Déconnexion',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
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
            child: const Text(
              'Annuler',
              style: TextStyle(
                color: CupertinoColors.activeBlue,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(context).pop();
              logOut();
            },
            child: const Text(
              'Se déconnecter',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    },
  );
}



  //* PROFILE METHODS
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

  //* STATS METHODS
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
