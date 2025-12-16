import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/services/wallet_service.dart';
import 'package:for_u_partners/services/auth_service.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/views/drivers/wallet/payment_webview.dart';
import 'package:for_u_partners/app/api_constant.dart';
import 'package:for_u_partners/app/models/parrainage_model.dart';

class WalletViewModel extends BaseViewModel {
  final _walletService = locator<WalletService>();
  final _authService = locator<AuthService>();
  final _navigationService = locator<NavigationService>();

  double _balance = 0.0;
  List<Map<String, dynamic>> _transactions = [];
  List<ParrainageModel> _uncollectedBonuses = [];
  bool _isCollecting = false;

  double get balance => _balance;
  List<Map<String, dynamic>> get transactions => _transactions;
  List<ParrainageModel> get uncollectedBonuses => _uncollectedBonuses;
  bool get isCollecting => _isCollecting;

  double get totalUncollectedAmount {
    return _uncollectedBonuses.fold(0.0, (sum, bonus) => sum + (bonus.montant ?? 0));
  }

  bool get hasUncollectedBonuses => _uncollectedBonuses.isNotEmpty;

  WalletViewModel() {
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    setBusy(true);
    try {
      // Load balance from wallet service
      final walletData = await _walletService.getWalletSold();
      _balance = (walletData.balance ?? 0).toDouble();

      // Load uncollected bonuses
      _uncollectedBonuses = await _walletService.getUncollectedBonuses();

      // TODO: Implement transaction history when API is ready
      _transactions = [];

      notifyListeners();
    } catch (e) {
      print('Error loading wallet data: $e');
      _balance = 0.0;
      _transactions = [];
      _uncollectedBonuses = [];
    } finally {
      setBusy(false);
    }
  }

  void rechargeWallet(BuildContext context) {
    _showRechargeBottomSheet(context);
  }

  void _showRechargeBottomSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recharger le portefeuille',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kcPrimaryColor),
                    ),
                    labelText: 'Montant (FCFA)',
                    labelStyle: TextStyle(color: kcPrimaryColor),
                    border: OutlineInputBorder(),
                    prefixText: 'FCFA ',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un montant';
                    }
                    final amount = int.tryParse(value);
                    if (amount == null) {
                      return 'Montant invalide';
                    }
                    if (amount < 500) {
                      return 'Le montant minimum est de 500 FCFA';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (formKey.currentState?.validate() ?? false) {
                              setState(() => isLoading = true);
                              try {
                                final amount =
                                    int.parse(amountController.text.trim());

                                // Get payment URL from API
                                final paymentUrl = await _getPaymentUrl(amount);

                                if (context.mounted) {
                                  Navigator.pop(context); // Close bottom sheet

                                  // Open WebView for payment
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PaymentWebView(
                                        paymentUrl: paymentUrl,
                                      ),
                                    ),
                                  );

                                  // Refresh balance after payment
                                  await _loadWalletData();

                                  if (context.mounted) {
                                    if (result == true) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Paiement effectué avec succès!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } else if (result == false) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Paiement annulé ou échoué'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    }
                                  }
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  Navigator.pop(context); // Close bottom sheet
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Erreur: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } finally {
                                if (context.mounted) {
                                  setState(() => isLoading = false);
                                }
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kcPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Valider',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> _getPaymentUrl(int amount) async {
    try {
      final headers = await _authService.getAuthenticatedHeaders();

      final response = await http
          .post(
            Uri.parse("$baseUrl/wallet_recharge"),
            headers: headers,
            body: jsonEncode({
              'montant': amount,
            }),
          )
          .timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String paymentUrl = data['payment_url'];
        print('Lien de paiement : $paymentUrl');
        return paymentUrl;
      } else {
        final error = jsonDecode(response.body);
        final errorMessage = error['message'] ?? 'Échec de la mise à jour';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Erreur réseau : $e');
      throw Exception('Erreur lors de la création du lien de paiement: $e');
    }
  }

  Future<void> refresh() async {
    await _loadWalletData();
  }

  Future<void> collectBonus(BuildContext context, ParrainageModel bonus) async {
    if (_isCollecting) return;

    _isCollecting = true;
    notifyListeners();

    try {
      final result = await _walletService.collectBonus(bonus.id!);

      // Reload wallet data to get updated balance and bonuses
      await _loadWalletData();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Bonus collecté avec succès!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      _isCollecting = false;
      notifyListeners();
    }
  }

  Future<void> collectAllBonuses(BuildContext context) async {
    if (_isCollecting || _uncollectedBonuses.isEmpty) return;

    _isCollecting = true;
    notifyListeners();

    int successCount = 0;
    int totalAmount = 0;
    List<String> errors = [];

    for (var bonus in List.from(_uncollectedBonuses)) {
      try {
        final result = await _walletService.collectBonus(bonus.id!);
        successCount++;
        totalAmount += (result['montant'] as int? ?? 0);
      } catch (e) {
        errors.add(e.toString().replaceAll('Exception: ', ''));
      }
    }

    // Reload wallet data
    await _loadWalletData();

    if (context.mounted) {
      if (successCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$successCount bonus collecté${successCount > 1 ? 's' : ''} • $totalAmount FCFA ajouté${successCount > 1 ? 's' : ''}',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }

      if (errors.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreurs: ${errors.join(', ')}'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }

    _isCollecting = false;
    notifyListeners();
  }

  void navigateToPayoutHistory() {
    _navigationService.navigateTo(Routes.payoutHistoryView);
  }
}
