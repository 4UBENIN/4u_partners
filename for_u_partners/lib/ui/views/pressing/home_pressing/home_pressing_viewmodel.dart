import 'package:for_u_partners/app/models/depot_models/depot_detail_model.dart';
import 'package:for_u_partners/app/models/depot_models/depot_model.dart';
import 'package:for_u_partners/app/models/ramassage_models/ramassage_detail_model.dart';
import 'package:for_u_partners/app/models/ramassage_models/ramassage_statut_model.dart';
import 'package:for_u_partners/services/wallet_service.dart';
import 'package:for_u_partners/ui/common/api_constant.dart';
import 'package:for_u_partners/ui/common/get_fcm_token.dart';
import 'package:intl/intl.dart';
import 'package:for_u_partners/app/models/pressing_model.dart';
import 'package:for_u_partners/services/pressing_service.dart';
import 'package:stacked/stacked.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/app/models/ramassage_models/ramassage_model.dart';
import 'package:stacked_services/stacked_services.dart';

class HomePressingViewModel extends FormViewModel {
  final navigationService = locator<NavigationService>();
  final _pressingService = locator<PressingService>();
  final _walletService = locator<WalletService>();

  Pressing? _pressingDetails;
  Pressing? get pressingDetails => _pressingDetails;

  // Données des ramassages
  List<Ramassage> _ramassages = [];
  List<Ramassage> get ramassages => _ramassages;

  // Ramassage details
  RamassageDetail? _selectedRamassageDetail;
  RamassageDetail? get selectedRamassageDetail => _selectedRamassageDetail;

  RamassageStatutModel? _validateRamassage;
  RamassageStatutModel? get validateRamassage => _validateRamassage;

  List<Ramassage> validateRamassages = [];

  // Depot
  List<Depot> _depots = [];
  List<Depot> get depot => _depots;

  // Depot details
  Rdv? _selectedDepotDetail;
  Rdv? get selectedDepotDetail => _selectedDepotDetail;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Wallet de l'utilisateur
  String _wallet = "";
  String get wallet => _wallet;

  @override
  HomePressingViewModel() {
    sendPressingFcmToken();
    getWalletSold();
    fetchPressingInfo();
    getRamassagesList();
    getDepotList();
  }

  //! FCM TOKEN

  void sendPressingFcmToken() async {
   await registerPressingToken();
  }

  Future<void> registerPressingToken() async {
    // Enregistrer le token pour le pressing
    bool success = await FirebaseMessagingService().sendCurrentTokenToBackend(
      ApiConstant.saveFcmTokenPressing // URL spécifique pressing
    );
    
    if (success) {
      print('Token pressing enregistré');
    }
  }



  //! WALLET

  //* GET WALLET SOLD
  Future<void> getWalletSold() async {
    setBusy(true);
    _errorMessage = null; // Reset l'erreur
    notifyListeners();

    try {
      final response = await _walletService.getWalletSold();
      // ignore: unnecessary_null_comparison
      if (response != null && response.solde != null) {
        _wallet = response.solde.toString();
        _errorMessage = null;
      } else {
        _errorMessage = "Aucun solde trouvé";
      }
    } catch (e) {
      _errorMessage = e.toString();
      print("Erreur dans ViewModel: $e");
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  //! PRESSING

  //* GET PRESSING INFO
  Future<void> fetchPressingInfo() async {
    setBusy(true);
    _errorMessage = null; // Reset l'erreur
    notifyListeners();

    try {
      final response = await _pressingService.getPressingInfo();
      // ignore: unnecessary_null_comparison
      if (response != null && response.pressing != null) {
        _pressingDetails = response.pressing;
        _errorMessage = null;
      } else {
        _errorMessage = "Aucune information de pressing trouvée";
      }
    } catch (e) {
      _errorMessage = e.toString();
      print("Erreur dans ViewModel: $e");
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  // Méthode pour retry en cas d'erreur
  Future<void> retry() async {
    await fetchPressingInfo();
  }

  //! RAMASSAGE PART

  //* GET RAMASSAGES LIST
  // Charger toute les demandes de ramassages assignées au pressing connecté
  Future<void> getRamassagesList() async {
    setBusy(true);
    _errorMessage = null;

    try {
      _ramassages = await _pressingService.getRamassagesList();
      print("Ramassages chargés: ${_ramassages.length}");
      print(_ramassages);
    } catch (e) {
      _errorMessage = e.toString();
      print("Erreur chargement ramassages: $e");
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  //* GET RAMASSAGE DETAIL COMPLET
  // Charger le détail complet d'un ramassage spécifique
  Future<void> getRamassageDetailComplet(int ramassageId) async {
    setBusy(true);
    _errorMessage = null;

    try {
      _selectedRamassageDetail =
          await _pressingService.getRamassageDetailComplet(ramassageId);
      print(
          "Détail complet ramassage chargé: ${_selectedRamassageDetail?.numero}");
    } catch (e) {
      _errorMessage = e.toString();
      print("Erreur détail ramassage: $e");
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  //* VALIDER RAMASSAGE

  Future<void> validateSelectedRamassage(int ramassageId) async {
    setBusy(true);
    _errorMessage = null;

    try {
      _validateRamassage =
          await _pressingService.updateRamassageStatut(ramassageId);
      print("message de validation ramassage: ${_validateRamassage?.message}");

      // Find the ramassage in _ramassages list
      // final ramassageIndex = _ramassages.indexWhere((r) => r.id == ramassageId);

      // if (ramassageIndex != -1) {
      //   // Get the ramassage to be moved
      //   final ramassage = _ramassages[ramassageIndex];

      //   // Remove from _ramassages
      //   _ramassages.removeAt(ramassageIndex);

      //   // Add to validateRamassages
      //   validateRamassages.add(ramassage);

      //   // Notify listeners to update the UI
      //   notifyListeners();
      // }
    } catch (e) {
      _errorMessage = e.toString();
      print("Erreur détail ramassage: $e");
    } finally {
      setBusy(false);
    }
  }

  //* VIDER RAMASSAGE
  // Vider les détails lors du changement de ramassage
  void clearRamassageDetail() {
    _selectedRamassageDetail = null;
    notifyListeners();
  }

  //! DEPOT PART

  //* GET DEPOT LIST
  // Charger toute les demandes de dépot assignées au pressing connecté
  Future<void> getDepotList() async {
    setBusy(true);
    _errorMessage = null;

    try {
      _depots = await _pressingService.getDepotList();
      print("Dépots chargés: ${_depots.length}");
      print(_depots);
    } catch (e) {
      _errorMessage = e.toString();
      print("Erreur chargement dépots: $e");
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  //* GET DEPOT DETAIL COMPLET
  // Charger le détail complet d'un dépôt spécifique
  Future<void> getDepotDetailComplet(int depotId) async {
    setBusy(true);
    _errorMessage = null;

    try {
      _selectedDepotDetail =
          await _pressingService.getDepotDetailComplet(depotId);
      print("Détail complet dépôt chargé: ${_selectedDepotDetail?.numero}");
    } catch (e) {
      _errorMessage = e.toString();
      print("Erreur détail dépôt: $e");
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  //* VALIDER DEPOT
  Future<void> validateSelectedDepot(int depotId) async {
    setBusy(true);
    _errorMessage = null;

    try {
      // Tu peux créer une méthode similaire dans PressingService pour valider un dépôt
      // await _pressingService.updateDepotStatut(depotId);
      print("Dépôt $depotId validé");

      // Rafraîchir la liste des dépôts après validation
      await getDepotList();
    } catch (e) {
      _errorMessage = e.toString();
      print("Erreur validation dépôt: $e");
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  //* VIDER DEPOT DETAIL
  // Vider les détails lors du changement de dépôt
  void clearDepotDetail() {
    _selectedDepotDetail = null;
    notifyListeners();
  }

  //! OTHERS

  //* HELPER FUNCTIONS

  String changeFormatDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    String formatted = DateFormat("EEEE d MMMM 'à' HH'h'mm", 'fr_FR').format(date);
    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  String changeFormatDateHour(DateTime date) {
    String formatted =
        DateFormat("EEEE d MMMM 'à' HH'h'mm", 'fr_FR').format(date);
    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  //* HELPER METHODS pour les détails

  // Calculer le montant total des vêtements
  double get montantVetements {
    if (_selectedRamassageDetail?.details == null) return 0.0;
    return _selectedRamassageDetail!.details!
        .fold(0.0, (sum, item) => sum + (item.montant ?? 0.0));
  }

  // Calculer le montant total des services complémentaires
  double get montantServices {
    if (_selectedRamassageDetail?.servicesComplementaires == null) return 0.0;
    return _selectedRamassageDetail!.servicesComplementaires!
        .fold(0.0, (sum, service) => sum + (service.montant ?? 0.0));
  }

  // Obtenir la liste formatée des vêtements
  String get vetementsFormates {
    if (_selectedRamassageDetail?.details == null)
      return "Aucun détail disponible";
    return _selectedRamassageDetail!.details!
        .map((item) => "${item.libelle} x${item.quantite}")
        .join(", ");
  }

  // Obtenir la liste formatée des services
  String get servicesFormates {
    if (_selectedRamassageDetail?.servicesComplementaires == null)
      return "Aucun service";
    return _selectedRamassageDetail!.servicesComplementaires!
        .map((service) => service.libelle)
        .join(", ");
  }
}
