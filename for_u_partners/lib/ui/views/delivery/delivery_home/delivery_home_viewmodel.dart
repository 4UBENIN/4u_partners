import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:for_u_partners/services/wallet_service.dart';
import 'package:stacked/stacked.dart';

class DeliveryHomeViewModel extends BaseViewModel {
  final _sharedPreferencesServices = locator<SharedpreferencesService>();
  final _walletService = locator<WalletService>();

  String _userName = '';
  String _userRole = '';

  String get userName => _userName;
  String get userRole => _userRole;

  // Wallet de l'utilisateur
  String _wallet = "";
  String get wallet => _wallet;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  DeliveryHomeViewModel() {
    _loadUserData();
    getWalletSold();
  }

  //* Methode pour charger les données utilisateur
  Future<void> _loadUserData() async {
    setBusy(true);
    try {
      _userName =
          await _sharedPreferencesServices.getUserName() ?? 'Utilisateur';
      print('Nom de l\'utilisateur: $_userName');
      _userRole =
          await _sharedPreferencesServices.getUserType() ?? 'Partenaire';
      print('Rôle de l\'utilisateur: $_userRole');
      notifyListeners();
    } catch (e) {
      // Gérer l'erreur
      print('Erreur lors du chargement des données utilisateur: $e');
    }
    setBusy(false);
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

  //* Méthode pour obtenir les initiales du nom
  String getUserInitials() {
    if (_userName.isEmpty) return '?';
    List<String> nameParts = _userName.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return _userName[0].toUpperCase();
  }
}
