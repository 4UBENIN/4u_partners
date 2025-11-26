import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'otp_viewmodel.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/common/text_component.dart';
import 'package:for_u_partners/ui/common/app_button_component.dart';
import 'package:for_u_partners/app/app.router.dart';

class OtpView extends StackedView<OtpViewModel> {
  final String phoneNumber;
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;
  final String? address;

  const OtpView({
    Key? key,
    required this.phoneNumber,
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
    this.address,
  }) : super(key: key);

  @override
  void onViewModelReady(OtpViewModel viewModel) {
    super.onViewModelReady(viewModel);
    viewModel.initialize(phoneNumber);
  }

  @override
  OtpViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      OtpViewModel();

  @override
  Widget builder(
    BuildContext context,
    OtpViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => viewModel.goBackToProfileSelection(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.message_rounded,
                          size: 40,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 30),

                      const TextComponent(
                        "Vérification",
                        fontsize: 28,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      Text(
                        "Entrez le code à 4 chiffres envoyé au",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            viewModel.maskedPhoneNumber,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                      const SizedBox(height: 40),

                      _buildOtpFields(context, viewModel),
                      const SizedBox(height: 12),

                      if (viewModel.otpError != null)
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          margin: const EdgeInsets.only(top: 12.0),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.red.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  viewModel.otpError!,
                                  style: TextStyle(
                                    color: Colors.red.shade900,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 30),

                      PrimaryButton(
                        text: viewModel.isBusy
                            ? "Vérification..."
                            : "Vérifier",
                        isActive: viewModel.isOtpComplete && !viewModel.isBusy,
                        onPressed: viewModel.isOtpComplete && !viewModel.isBusy
                            ? () {
                                viewModel.verifyOtp().then((isValid) {
                                  if (isValid) {
                                    print("🔑 [OtpView] Navigation avec code OTP: ${viewModel.otpCode}");
                                    viewModel.navigationService
                                        .navigateToRegisterProfileView(
                                      selectedProfile: "conducteur",
                                      phoneNumber: phoneNumber,
                                      mail: email,
                                      password: password,
                                      firstName: firstName ?? '',
                                      lastName: lastName ?? '',
                                      address: address ?? '',
                                      otpCode: viewModel.otpCode,
                                    );
                                  }
                                });
                              }
                            : () {},
                      ),
                      const SizedBox(height: 20),

                      _buildResendSection(viewModel),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOtpFields(BuildContext context, OtpViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        viewModel.otpLength,
        (index) => Container(
          width: 50,
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          child: TextFormField(
            autofocus: index == 0,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterText: '',
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: viewModel.otpDigits[index].isEmpty
                      ? Colors.grey.shade300
                      : primaryColor,
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: primaryColor,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.red.shade400,
                  width: 2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.red.shade400,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: viewModel.otpDigits[index].isEmpty
                  ? Colors.grey.shade50
                  : primaryColor.withOpacity(0.05),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (value) {
              if (value.isNotEmpty) {
                viewModel.setOtpDigit(index, value);
                if (index < viewModel.otpLength - 1) {
                  FocusScope.of(context).nextFocus();
                } else {
                  FocusScope.of(context).unfocus();
                }
              } else {
                viewModel.setOtpDigit(index, '');
                if (index > 0) {
                  FocusScope.of(context).previousFocus();
                }
              }
            },
            onTap: () {
              if (viewModel.otpDigits[index].isNotEmpty) {
                viewModel.setOtpDigit(index, '');
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildResendSection(OtpViewModel viewModel) {
    return Column(
      children: [
        if (!viewModel.canResend)
          Text(
            "Renvoyer le code dans ${viewModel.resendTimer}s",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Vous n'avez pas reçu le code ?",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              TextButton(
                onPressed: viewModel.isBusy
                    ? null
                    : () async {
                        await viewModel.resendOtp();
                      },
                child: const Text(
                  "Renvoyer",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

}