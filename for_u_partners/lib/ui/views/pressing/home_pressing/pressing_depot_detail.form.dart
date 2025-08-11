// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedFormGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, constant_identifier_names, non_constant_identifier_names,unnecessary_this

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

const bool _autoTextFieldValidation = true;

const String PoidsInputValueKey = 'poidsInput';

final Map<String, TextEditingController>
    _DepotDetailViewTextEditingControllers = {};

final Map<String, FocusNode> _DepotDetailViewFocusNodes = {};

final Map<String, String? Function(String?)?> _DepotDetailViewTextValidations =
    {
  PoidsInputValueKey: null,
};

mixin $DepotDetailView {
  TextEditingController get poidsInputController =>
      _getFormTextEditingController(PoidsInputValueKey);

  FocusNode get poidsInputFocusNode => _getFormFocusNode(PoidsInputValueKey);

  TextEditingController _getFormTextEditingController(
    String key, {
    String? initialValue,
  }) {
    if (_DepotDetailViewTextEditingControllers.containsKey(key)) {
      return _DepotDetailViewTextEditingControllers[key]!;
    }

    _DepotDetailViewTextEditingControllers[key] =
        TextEditingController(text: initialValue);
    return _DepotDetailViewTextEditingControllers[key]!;
  }

  FocusNode _getFormFocusNode(String key) {
    if (_DepotDetailViewFocusNodes.containsKey(key)) {
      return _DepotDetailViewFocusNodes[key]!;
    }
    _DepotDetailViewFocusNodes[key] = FocusNode();
    return _DepotDetailViewFocusNodes[key]!;
  }

  /// Registers a listener on every generated controller that calls [model.setData()]
  /// with the latest textController values
  void syncFormWithViewModel(FormStateHelper model) {
    poidsInputController.addListener(() => _updateFormData(model));

    _updateFormData(model, forceValidate: _autoTextFieldValidation);
  }

  /// Registers a listener on every generated controller that calls [model.setData()]
  /// with the latest textController values
  @Deprecated(
    'Use syncFormWithViewModel instead.'
    'This feature was deprecated after 3.1.0.',
  )
  void listenToFormUpdated(FormViewModel model) {
    poidsInputController.addListener(() => _updateFormData(model));

    _updateFormData(model, forceValidate: _autoTextFieldValidation);
  }

  /// Updates the formData on the FormViewModel
  void _updateFormData(FormStateHelper model, {bool forceValidate = false}) {
    model.setData(
      model.formValueMap
        ..addAll({
          PoidsInputValueKey: poidsInputController.text,
        }),
    );

    if (_autoTextFieldValidation || forceValidate) {
      updateValidationData(model);
    }
  }

  bool validateFormFields(FormViewModel model) {
    _updateFormData(model, forceValidate: true);
    return model.isFormValid;
  }

  /// Calls dispose on all the generated controllers and focus nodes
  void disposeForm() {
    // The dispose function for a TextEditingController sets all listeners to null

    for (var controller in _DepotDetailViewTextEditingControllers.values) {
      controller.dispose();
    }
    for (var focusNode in _DepotDetailViewFocusNodes.values) {
      focusNode.dispose();
    }

    _DepotDetailViewTextEditingControllers.clear();
    _DepotDetailViewFocusNodes.clear();
  }
}

extension ValueProperties on FormStateHelper {
  bool get hasAnyValidationMessage => this
      .fieldsValidationMessages
      .values
      .any((validation) => validation != null);

  bool get isFormValid {
    if (!_autoTextFieldValidation) this.validateForm();

    return !hasAnyValidationMessage;
  }

  String? get poidsInputValue =>
      this.formValueMap[PoidsInputValueKey] as String?;

  set poidsInputValue(String? value) {
    this.setData(
      this.formValueMap..addAll({PoidsInputValueKey: value}),
    );

    if (_DepotDetailViewTextEditingControllers.containsKey(
        PoidsInputValueKey)) {
      _DepotDetailViewTextEditingControllers[PoidsInputValueKey]?.text =
          value ?? '';
    }
  }

  bool get hasPoidsInput =>
      this.formValueMap.containsKey(PoidsInputValueKey) &&
      (poidsInputValue?.isNotEmpty ?? false);

  bool get hasPoidsInputValidationMessage =>
      this.fieldsValidationMessages[PoidsInputValueKey]?.isNotEmpty ?? false;

  String? get poidsInputValidationMessage =>
      this.fieldsValidationMessages[PoidsInputValueKey];
}

extension Methods on FormStateHelper {
  setPoidsInputValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[PoidsInputValueKey] = validationMessage;

  /// Clears text input fields on the Form
  void clearForm() {
    poidsInputValue = '';
  }

  /// Validates text input fields on the Form
  void validateForm() {
    this.setValidationMessages({
      PoidsInputValueKey: getValidationMessage(PoidsInputValueKey),
    });
  }
}

/// Returns the validation message for the given key
String? getValidationMessage(String key) {
  final validatorForKey = _DepotDetailViewTextValidations[key];
  if (validatorForKey == null) return null;

  String? validationMessageForKey = validatorForKey(
    _DepotDetailViewTextEditingControllers[key]!.text,
  );

  return validationMessageForKey;
}

/// Updates the fieldsValidationMessages on the FormViewModel
void updateValidationData(FormStateHelper model) =>
    model.setValidationMessages({
      PoidsInputValueKey: getValidationMessage(PoidsInputValueKey),
    });
