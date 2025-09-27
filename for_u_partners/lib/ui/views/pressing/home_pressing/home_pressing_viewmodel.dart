import 'package:for_u_partners/app/models/pressing_depot_models/depot_detail_model.dart';
import 'package:for_u_partners/app/models/pressing_depot_models/depot_model.dart';
import 'package:for_u_partners/app/models/pressing_depot_models/planned_depot_model.dart';
import 'package:for_u_partners/app/models/pressing_ramassage_models/ramassage_detail_model.dart';
import 'package:for_u_partners/app/models/pressing_ramassage_models/ramassage_statut_model.dart';
import 'package:for_u_partners/services/wallet_service.dart';
import 'package:for_u_partners/ui/common/api_constant.dart';
import 'package:for_u_partners/ui/common/get_fcm_token.dart';
import 'package:intl/intl.dart';
import 'package:for_u_partners/app/models/pressing_model.dart';
import 'package:for_u_partners/services/pressing_service.dart';
import 'package:stacked/stacked.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/app/models/pressing_ramassage_models/ramassage_model.dart';
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

  PlannedDepotModel plannedDepot = PlannedDepotModel();

  // Filtres pour les dépôts
  bool _demands = true; // Par défaut sur "Demandes"
  bool get demands => _demands;

  bool _planified = false;
  bool get planified => _planified;

  // Liste des dépôts planifiés
  List<Depot> _planifiedDepots = [];
  List<Depot> get planifiedDepots => _planifiedDepots;

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

  // Variable pour gérer les états de loading séparément
  bool _isLoadingDepots = false;
  bool get isLoadingDepots => _isLoadingDepots;

  @override
  HomePressingViewModel() {
    sendPressingFcmToken();
    getWalletSold();
    fetchPressingInfo();
    getRamassagesList();
    getDepotList();
    // Ne pas charger les dépôts planifiés au démarrage
  }

  // Méthodes pour gérer les filtres
  void toggleDemandsFilter() {
    if (!_demands) {
      _demands = true;
      _planified = false;
      notifyListeners();
      // Recharger les demandes si la liste est vide
      if (_depots.isEmpty) {
        getDepotList();
      }
    }
  }

  void togglePlanifiedFilter() {
    if (!_planified) {
      _demands = false;
      _planified = true;
      notifyListeners();
      // Charger les dépôts planifiés si ce n'est pas déjà fait
      getPlanifiedDepotList();
    }
  }

  // Getter pour obtenir la liste appropriée selon le filtre sélectionné
  List<Depot> get currentDepotList {
    if (_demands) {
      return _depots; // Liste des demandes
    } else {
      return _planifiedDepots; // Liste des dépôts planifiés
    }
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
    await getRamassagesList();
    if (_demands) {
      await getDepotList();
    } else if (_planified) {
      await getPlanifiedDepotList();
    }
  }

  //! RAMASSAGE PART
  //* GET RAMASSAGES LIST
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
    } catch (e) {
      _errorMessage = e.toString();
      print("Erreur détail ramassage: $e");
    } finally {
      setBusy(false);
    }
  }

  //* VIDER RAMASSAGE
  void clearRamassageDetail() {
    _selectedRamassageDetail = null;
    notifyListeners();
  }

  //! DEPOT PART

  //* GET DEPOT LIST
  Future<void> getDepotList() async {
    _isLoadingDepots = true;
    if (_demands) setBusy(true);
    _errorMessage = null;
    notifyListeners();

    try {
      _depots = await _pressingService.getDepotList();
      print("Dépots chargés: ${_depots.length}");
    } catch (e) {
      _errorMessage = e.toString();
      print("Erreur chargement dépots: $e");
    } finally {
      _isLoadingDepots = false;
      if (_demands) setBusy(false);
      notifyListeners();
    }
  }

  //* GET DEPOT PLANIFIED LIST
  Future<void> getPlanifiedDepotList() async {
    _isLoadingDepots = true;
    if (_planified) setBusy(true);
    _errorMessage = null;
    notifyListeners();

    try {
      _planifiedDepots = await _pressingService.getPlanifiedDepotList();
      print("Dépôts planifiés chargés: ${_planifiedDepots.length}");
    } catch (e) {
      _errorMessage = e.toString();
      print("Erreur chargement dépôts planifiés: $e");
    } finally {
      _isLoadingDepots = false;
      if (_planified) setBusy(false);
      notifyListeners();
    }
  }

  //* GET DEPOT DETAIL COMPLET
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

  //* PLANIFIER DEPOT
  Future<PlannedDepotModel?> planifierDepot(int depotId) async {
    setBusy(true);
    _errorMessage = null;

    try {
      // Appeler le service pour planifier le dépôt
      plannedDepot = await _pressingService.planifierDepot(depotId);

      // Trouver et supprimer le dépôt de la liste des demandes
      _depots.removeWhere((depot) => depot.id == depotId);

      // Rafraîchir la liste des dépôts planifiés
      await getPlanifiedDepotList();

      // Rafraîchir aussi la liste des demandes pour être sûr
      await getDepotList();

      return plannedDepot;
    } catch (e) {
      _errorMessage =
          'Erreur lors de la planification du dépôt: ${e.toString()}';
      print("Erreur planification dépôt: $e");
      return null;
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  //* VIDER DEPOT DETAIL
  void clearDepotDetail() {
    _selectedDepotDetail = null;
    notifyListeners();
  }

  //! OTHERS
  //* HELPER FUNCTIONS
  String changeFormatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      String formatted =
          DateFormat("EEEE d MMMM 'à' HH'h'mm", 'fr_FR').format(date);
      return formatted[0].toUpperCase() + formatted.substring(1);
    } catch (e) {
      print("Erreur format date: $e");
      return dateString;
    }
  }

  String changeFormatDateHour(DateTime date) {
    try {
      String formatted =
          DateFormat("EEEE d MMMM 'à' HH'h'mm", 'fr_FR').format(date);
      return formatted[0].toUpperCase() + formatted.substring(1);
    } catch (e) {
      print("Erreur format date heure: $e");
      return date.toString();
    }
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
    if (_selectedRamassageDetail?.details == null) {
      return "Aucun détail disponible";
    }
    return _selectedRamassageDetail!.details!
        .map((item) => "${item.libelle} x${item.quantite}")
        .join(", ");
  }

  // Obtenir la liste formatée des services
  String get servicesFormates {
    if (_selectedRamassageDetail?.servicesComplementaires == null) {
      return "Aucun service";
    }
    return _selectedRamassageDetail!.servicesComplementaires!
        .map((service) => service.libelle)
        .join(", ");
  }
}
