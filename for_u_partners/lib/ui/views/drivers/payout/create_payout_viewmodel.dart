import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/payout_service.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:for_u_partners/ui/common/toast.dart';

class CreatePayoutViewModel extends BaseViewModel {
  final _payoutService = locator<PayoutService>();
  final _sharedPreferencesService = locator<SharedpreferencesService>();
  final _navigationService = locator<NavigationService>();

  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final passwordController = TextEditingController();

  String _selectedProvider = 'mtn';
  String get selectedProvider => _selectedProvider;

  final List<Map<String, dynamic>> providers = [
    {
      'value': 'mtn',
      'label': 'MTN Mobile Money',
      'icon': Icons.phone_android,
      'color': Color(0xFFFFCC00),
    },
    {
      'value': 'moov',
      'label': 'Moov Money',
      'icon': Icons.phone_android,
      'color': Color(0xFF0066CC),
    },
    {
      'value': 'wave',
      'label': 'Wave',
      'icon': Icons.phone_android,
      'color': Color(0xFF00D9FF),
    },
  ];

  void selectProvider(String provider) {
    _selectedProvider = provider;
    notifyListeners();
  }

  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un montant';
    }
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Montant invalide';
    }
    if (amount <= 0) {
      return 'Le montant doit être supérieur à 0';
    }
    if (amount < 500) {
      return 'Le montant minimum est de 500 FCFA';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre mot de passe';
    }
    return null;
  }

  Future<void> createPayout(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final userIdStr = await _sharedPreferencesService.getUserTypeId();
    if (userIdStr == null) {
      if (context.mounted) {
        CustomToast.showError(context, message: 'Utilisateur non connecté');
      }
      return;
    }

    final userId = int.tryParse(userIdStr);
    if (userId == null) {
      if (context.mounted) {
        CustomToast.showError(context, message: 'ID utilisateur invalide');
      }
      return;
    }

    setBusy(true);
    try {
      final amount = double.parse(amountController.text);
      final password = passwordController.text;

      final response = await _payoutService.createPayout(
        utilisateurId: userId,
        password: password,
        amount: amount,
        provider: _selectedProvider,
        recipientType: 'mobile_money',
      );

      if (context.mounted) {
        CustomToast.showSuccess(context, message: response.message);
      }

      // Clear form
      amountController.clear();
      passwordController.clear();

      // Navigate back to wallet or payout history
      _navigationService.back();

    } catch (e) {
      debugPrint('❌ Error creating payout: $e');
      if (context.mounted) {
        CustomToast.showError(context, message: e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      setBusy(false);
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
