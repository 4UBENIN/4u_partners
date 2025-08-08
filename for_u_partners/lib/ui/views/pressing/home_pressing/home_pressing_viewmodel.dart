import 'package:for_u_partners/app/models/ramassage_detail_model.dart';
import 'package:intl/intl.dart';
import 'package:for_u_partners/app/models/pressing_model.dart';
import 'package:for_u_partners/services/pressing_service.dart';
import 'package:stacked/stacked.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/app/models/ramassage_model.dart';
import 'package:stacked_services/stacked_services.dart';

class HomePressingViewModel extends BaseViewModel {
  final navigationService = locator<NavigationService>();
  final _pressingService = locator<PressingService>();

  Pressing? _pressingDetails;
  Pressing? get pressingDetails => _pressingDetails;

  // Données des ramassages
  List<Ramassage> _ramassages = [];
  List<Ramassage> get ramassages => _ramassages;

  // Ramassage details
  RamassageDetail? _selectedRamassageDetail;
  RamassageDetail? get selectedRamassageDetail => _selectedRamassageDetail;

  //statut de la 

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // État du dépôt (garde ta logique existante)
  String _depotStatus = "En attente de validation";
  String get depotStatus => _depotStatus;

  @override
  HomePressingViewModel() {
    fetchPressingInfo();
    getRamassagesList();
  }

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

//* UPDATE RAMASSAGE STATUT

  // Garde tes méthodes existantes pour le dépôt
  void setDepotStatus(String status) {
    _depotStatus = status;
    notifyListeners();
  }

  //* HELPER FUNCTIONS

  String changeFormatDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    String formatted = DateFormat('EEEE d MMMM', 'fr_FR').format(date);
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

  // Vider les détails lors du changement de ramassage
  // void clearRamassageDetail() {
  //   _selectedRamassageDetail = null;
  //   _selectedRamassage = null;
  //   notifyListeners();
  // }
}
