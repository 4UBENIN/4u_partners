import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'create_payout_viewmodel.dart';

class CreatePayoutView extends StackedView<CreatePayoutViewModel> {
  const CreatePayoutView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    CreatePayoutViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F7),
        elevation: 0,
        title: const Text(
          'Retrait d\'argent',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: viewModel.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 24),
              _buildAmountField(viewModel),
              const SizedBox(height: 20),
              _buildProviderSelection(viewModel),
              const SizedBox(height: 20),
              _buildPasswordField(viewModel),
              const SizedBox(height: 32),
              _buildSubmitButton(context, viewModel),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF007AFF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF007AFF).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Le retrait sera traité par FedaPay. Montant minimum: 500 FCFA',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF1C1C1E),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField(CreatePayoutViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Montant',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1C1E),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: viewModel.amountController,
          keyboardType: TextInputType.number,
          validator: viewModel.validateAmount,
          decoration: InputDecoration(
            hintText: 'Entrez le montant',
            suffixText: 'FCFA',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF007AFF),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFF3B30),
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFF3B30),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProviderSelection(CreatePayoutViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Moyen de paiement',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1C1E),
          ),
        ),
        const SizedBox(height: 12),
        ...viewModel.providers.map((provider) {
          final isSelected = viewModel.selectedProvider == provider['value'];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => viewModel.selectProvider(provider['value']),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF007AFF)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (provider['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        provider['icon'],
                        color: provider['color'],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        provider['label'],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF007AFF),
                        size: 24,
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPasswordField(CreatePayoutViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mot de passe',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1C1E),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: viewModel.passwordController,
          obscureText: true,
          validator: viewModel.validatePassword,
          decoration: InputDecoration(
            hintText: 'Entrez votre mot de passe',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF007AFF),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFF3B30),
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFF3B30),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, CreatePayoutViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: viewModel.isBusy
            ? null
            : () => viewModel.createPayout(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007AFF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: viewModel.isBusy
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Demander le retrait',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  @override
  CreatePayoutViewModel viewModelBuilder(BuildContext context) =>
      CreatePayoutViewModel();
}
