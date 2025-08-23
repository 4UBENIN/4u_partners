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

  //* AUTH METHODS
  void logOut() {
    _sharedPreferencesServices.removeToken();
    navigationService.replaceWithLoginView();
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
