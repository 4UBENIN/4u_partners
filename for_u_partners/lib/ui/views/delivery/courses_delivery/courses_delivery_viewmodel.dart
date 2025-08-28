import 'dart:async';
import 'package:flutter/material.dart';
import 'package:for_u_partners/app/models/ramasseur_models/ramasseur_demand_detail.dart';
import 'package:for_u_partners/app/models/ramasseur_models/ramasseur_demand_model.dart';
import 'package:for_u_partners/services/pickers_service.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/ui/common/toast.dart';

// Enum pour les états des bottom sheets du ramassage
enum RamassageBottomSheetType {
  none,
  demandes, // Liste des demandes
  details, // Détails d'une demande acceptée
  inProgress, // Ramassage en cours
}

class CoursesDeliveryViewModel extends BaseViewModel {
  final pickerService = locator<PickersService>();
  final navigationService = locator<NavigationService>();
  final _sharedPreferencesService = locator<SharedpreferencesService>();

  String _userName = '';
  String _userRole = '';

  String get userName => _userName;
  String get userRole => _userRole;

  BuildContext? _context;

  // État du bottom sheet
  RamassageBottomSheetType _currentBottomSheetType =
      RamassageBottomSheetType.none;
  RamassageBottomSheetType get currentBottomSheetType =>
      _currentBottomSheetType;

  // Liste des demandes de ramassage disponibles
  final List<Demandes> _availableDemandes = [];
  List<Demandes> get availableDemandes => _availableDemandes;

  Demandes? _currentDemande;
  Demandes? get currentDemande => _currentDemande;

  // Demande actuellement sélectionnée/acceptée
  RamasseurDemandDetail? _acceptedDemande;
  RamasseurDemandDetail? get acceptedDemande => _acceptedDemande;

  // États de chargement
  bool _isLoadingDemandes = true;
  bool get isLoadingDemandes => _isLoadingDemandes;

  bool _isAcceptingRamassageDemande = false;
  bool get isAcceptingDemande => _isAcceptingRamassageDemande;

  // État du ramassage
  bool _isRamassageInProgress = false;
  bool get isRamassageInProgress => _isRamassageInProgress;

  // Timer pour rafraîchir les demandes
  Timer? _refreshTimer;

  // Définir le contexte
  void setContext(BuildContext context) {
    _context = context;
  }

  // Initialisation du ViewModel
  Future<void> initialize() async {
    setBusy(true);
    try {
      await Future.wait([
        _loadAvailableDemandes(),
        _loadUserData(),
      ]);
      _startAutoRefresh();
    } catch (e) {
      print('Erreur lors de l\'initialisation: $e');
      if (_context != null) {
        CustomToast.showError(_context!,
            message: 'Erreur lors du chargement des données');
      }
    } finally {
      setBusy(false);
    }
  }

  //* Methode pour charger les données utilisateur
  Future<void> _loadUserData() async {
    setBusy(true);
    try {
      _userName =
          await _sharedPreferencesService.getUserName() ?? 'Utilisateur';
      print('Nom de l\'utilisateur: $_userName');
      _userRole = await _sharedPreferencesService.getUserType() ?? 'Partenaire';
      print('Rôle de l\'utilisateur: $_userRole');
      notifyListeners();
    } catch (e) {
      // Gérer l'erreur
      print('Erreur lors du chargement des données utilisateur: $e');
    }
    setBusy(false);
  }

  // Charger les demandes de ramassage disponibles
  Future<void> _loadAvailableDemandes() async {
    try {
      _isLoadingDemandes = true;
      notifyListeners();

      print('📦 Chargement des demandes de ramassage...');

      // Appeler le service pour récupérer les demandes
      final response = await pickerService.getRamassageList();

      if (response != null && response.demandes != null) {
        _availableDemandes.clear();
        _availableDemandes.addAll(response.demandes!);

        print('✅ ${_availableDemandes.length} demandes chargées');

        // Afficher le bottom sheet s'il y a des demandes
        if (_availableDemandes.isNotEmpty) {
          _setBottomSheetType(RamassageBottomSheetType.demandes);
        } else {
          _setBottomSheetType(RamassageBottomSheetType.none);
        }
      }
    } catch (e) {
      print('❌ Erreur chargement demandes: $e');
      if (_context != null) {
        CustomToast.showError(_context!,
            message: 'Erreur lors du chargement des demandes');
      }
    } finally {
      _isLoadingDemandes = false;
      notifyListeners();
    }
  }

  // Rafraîchir manuellement les demandes
  Future<void> refreshDemandes() async {
    await _loadAvailableDemandes();
  }

  // Démarrer le rafraîchissement automatique
  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (!_isAcceptingRamassageDemande && _currentDemande == null) {
        _loadAvailableDemandes();
      }
    });
  }

  //* Accepter une demande de ramassage
  Future<void> acceptDemande(Demandes demande) async {
    if (demande.id == null) {
      print('❌ ID de demande manquant');
      return;
    }

    _isAcceptingRamassageDemande = true;
    notifyListeners();

    print('🔄 Tentative d\'acceptation de la demande ${demande.id}...');

    try {
      // 1. Accepter la demande
      print('1/3 - Envoi de la demande d\'acceptation...');
      await pickerService.acceptRamassage(demande.id!, _context!);
      print('   ✓ Demande acceptée avec succès');

      // 2. Récupérer les détails mis à jour
      print('2/3 - Récupération des détails mis à jour...');
      _acceptedDemande = await pickerService.getCurrentRamassageDetails(
          demande.id!, _context!);
      
      if (_acceptedDemande == null) {
        throw Exception('Impossible de récupérer les détails de la demande');
      }
      
      print('   ✓ Détails récupérés: ${_acceptedDemande!.toJson()}');

      // 3. Mettre à jour l'interface
      print('3/3 - Mise à jour de l\'interface...');
      _availableDemandes.removeWhere((d) => d.id == demande.id);
      _currentDemande = demande; // Conserver la référence à la demande actuelle
      _setBottomSheetType(RamassageBottomSheetType.details);
      
      print('✅ Flux d\'acceptation terminé avec succès');
      print('📊 État final:');
      print('   - Type de bottom sheet: ${_currentBottomSheetType}');
      print('   - Demande acceptée: ${_acceptedDemande != null}');
      print('   - Demande courante: ${_currentDemande != null}');

      // Afficher un message de succès
      if (_context != null) {
        CustomToast.showSuccess(
          _context!,
          message: 'Demande acceptée avec succès',
        );
      }
    } catch (e, stackTrace) {
      print('❌ ERREUR CRITIQUE lors de l\'acceptation de la demande:');
      print('   - Message: $e');
      print('   - Stack trace: $stackTrace');
      
      // Réinitialiser l'état en cas d'erreur
      _currentDemande = null;
      _acceptedDemande = null;
      
      // Afficher un message d'erreur
      if (_context != null) {
        final errorMessage = e is Exception ? e.toString() : 'Une erreur est survenue';
        CustomToast.showError(
          _context!,
          message: errorMessage,
        );
      }
      
      // Rejeter l'erreur pour qu'elle soit gérée par l'appelant si nécessaire
      rethrow;
    } finally {
      _isAcceptingRamassageDemande = false;
      notifyListeners();
    }
  }

  //* Refuser une demande
  // Future<void> rejectDemande(Demandes demande) async {
  //   if (demande.id == null) return;

  //   try {
  //     print('❌ Refus de la demande ${demande.id}');

  //     // Appeler l'API pour refuser
  //     await driverService.rejectRamassageDemande(demande.id!);

  //     // Retirer de la liste
  //     _availableDemandes.removeWhere((d) => d.id == demande.id);

  //     // Masquer le bottom sheet si plus de demandes
  //     if (_availableDemandes.isEmpty) {
  //       _setBottomSheetType(RamassageBottomSheetType.none);
  //     }

  //     notifyListeners();

  //   } catch (e) {
  //     print('❌ Erreur refus demande: $e');
  //     if (_context != null) {
  //       CustomToast.showError(_context!, message: 'Erreur lors du refus');
  //     }
  //   }
  // }

  //* Démarrer le ramassage
  // Future<void> startRamassage() async {
  //   if (_currentDemande?.id == null) return;

  //   try {
  //     setBusy(true);

  //     print('🚛 Démarrage du ramassage pour la demande ${_currentDemande!.id}');

  //     // Appeler l'API pour démarrer le ramassage
  //     await driverService.startRamassage(_currentDemande!.id!);

  //     _isRamassageInProgress = true;
  //     _setBottomSheetType(RamassageBottomSheetType.inProgress);

  //     print('✅ Ramassage démarré');

  //     if (_context != null) {
  //       CustomToast.showSuccess(_context!, message: 'Ramassage démarré');
  //     }

  //   } catch (e) {
  //     print('❌ Erreur démarrage ramassage: $e');
  //     if (_context != null) {
  //       CustomToast.showError(_context!, message: 'Erreur lors du démarrage');
  //     }
  //   } finally {
  //     setBusy(false);
  //     notifyListeners();
  //   }
  // }

  //* Terminer le ramassage
  // Future<void> completeRamassage() async {
  //   if (_currentDemande?.id == null) return;

  //   try {
  //     setBusy(true);

  //     print('✅ Finalisation du ramassage pour la demande ${_currentDemande!.id}');

  //     // Appeler l'API pour terminer le ramassage
  //     await driverService.completeRamassage(_currentDemande!.id!);

  //     print('🎉 Ramassage terminé avec succès');

  //     if (_context != null) {
  //       CustomToast.showSuccess(_context!, message: 'Ramassage terminé avec succès');
  //     }

  //     // Réinitialiser l'état
  //     _resetRamassageState();

  //   } catch (e) {
  //     print('❌ Erreur finalisation ramassage: $e');
  //     if (_context != null) {
  //       CustomToast.showError(_context!, message: 'Erreur lors de la finalisation');
  //     }
  //   } finally {
  //     setBusy(false);
  //     notifyListeners();
  //   }
  // }

  //* Annuler une demande acceptée
  // Future<void> cancelDemande() async {
  //   if (_currentDemande?.id == null) return;

  //   try {
  //     setBusy(true);

  //     print('🔄 Annulation de la demande ${_currentDemande!.id}');

  //     // Appeler l'API pour annuler
  //     await driverService.cancelRamassageDemande(_currentDemande!.id!);

  //     // Remettre dans la liste des demandes disponibles si nécessaire
  //     if (!_availableDemandes.any((d) => d.id == _currentDemande!.id)) {
  //       _availableDemandes.insert(0, _currentDemande!);
  //     }

  //     // Réinitialiser l'état
  //     _resetRamassageState();

  //     if (_context != null) {
  //       CustomToast.showInfo(_context!, message: 'Demande annulée');
  //     }

  //   } catch (e) {
  //     print('❌ Erreur annulation demande: $e');
  //     if (_context != null) {
  //       CustomToast.showError(_context!, message: 'Erreur lors de l\'annulation');
  //     }
  //   } finally {
  //     setBusy(false);
  //     notifyListeners();
  //   }
  // }

  //* Changer le type de bottom sheet
  void _setBottomSheetType(RamassageBottomSheetType type) {
    print('[BottomSheet] Changement: $_currentBottomSheetType -> $type');
    _currentBottomSheetType = type;
    notifyListeners();
  }

  //* Masquer le bottom sheet
  void hideBottomSheet() {
    _setBottomSheetType(RamassageBottomSheetType.none);
  }

  //* Réinitialiser l'état du ramassage
  void _resetRamassageState() {
    _currentDemande = null;
    _isRamassageInProgress = false;

    // Revenir à l'affichage des demandes s'il y en a
    if (_availableDemandes.isNotEmpty) {
      _setBottomSheetType(RamassageBottomSheetType.demandes);
    } else {
      _setBottomSheetType(RamassageBottomSheetType.none);
    }
  }

  //* Obtenir la date formatée
  String formatDateTime(String input) {
    final dateTime = DateTime.parse(input);
    final formatter = DateFormat("dd/MM/yyyy 'à' HH:mm");
    return formatter.format(dateTime.toLocal());
  }

  //* Obtenir le statut formaté d'une demande
  String getDemandeStatusText(String? statut) {
    switch (statut?.toLowerCase()) {
      case 'en_attente':
        return 'En attente';
      case 'acceptee':
        return 'Acceptée';
      case 'en_cours':
        return 'En cours';
      case 'terminee':
        return 'Terminée';
      case 'annulee':
        return 'Annulée';
      default:
        return 'Affectée';
    }
  }

  //* Obtenir la couleur du statut
  Color getDemandeStatusColor(String? statut) {
    switch (statut?.toLowerCase()) {
      case 'en_attente':
        return Colors.orange;
      case 'acceptee':
        return Colors.blue;
      case 'en_cours':
        return Colors.green;
      case 'terminee':
        return Colors.grey;
      case 'annulee':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
