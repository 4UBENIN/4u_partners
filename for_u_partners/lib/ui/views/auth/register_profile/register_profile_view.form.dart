// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedFormGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, constant_identifier_names, non_constant_identifier_names,unnecessary_this

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

const bool _autoTextFieldValidation = true;

const String DriverCarColorInputValueKey = 'driverCarColorInput';
const String DriverCarBrandInputValueKey = 'driverCarBrandInput';
const String DriverCarModelInputValueKey = 'driverCarModelInput';
const String DriverCarYearInputValueKey = 'driverCarYearInput';
const String DriverImmatriculationCarInputValueKey =
    'driverImmatriculationCarInput';
const String DriverCarPlacesInputValueKey = 'driverCarPlacesInput';

final Map<String, TextEditingController>
    _RegisterProfileViewTextEditingControllers = {};

final Map<String, FocusNode> _RegisterProfileViewFocusNodes = {};

final Map<String, String? Function(String?)?>
    _RegisterProfileViewTextValidations = {
  DriverCarColorInputValueKey: null,
  DriverCarBrandInputValueKey: null,
  DriverCarModelInputValueKey: null,
  DriverCarYearInputValueKey: null,
  DriverImmatriculationCarInputValueKey: null,
  DriverCarPlacesInputValueKey: null,
};

mixin $RegisterProfileView {
  TextEditingController get driverCarColorInputController =>
      _getFormTextEditingController(DriverCarColorInputValueKey);
  TextEditingController get driverCarBrandInputController =>
      _getFormTextEditingController(DriverCarBrandInputValueKey);
  TextEditingController get driverCarModelInputController =>
      _getFormTextEditingController(DriverCarModelInputValueKey);
  TextEditingController get driverCarYearInputController =>
      _getFormTextEditingController(DriverCarYearInputValueKey);
  TextEditingController get driverImmatriculationCarInputController =>
      _getFormTextEditingController(DriverImmatriculationCarInputValueKey);
  TextEditingController get driverCarPlacesInputController =>
      _getFormTextEditingController(DriverCarPlacesInputValueKey);

  FocusNode get driverCarColorInputFocusNode =>
      _getFormFocusNode(DriverCarColorInputValueKey);
  FocusNode get driverCarBrandInputFocusNode =>
      _getFormFocusNode(DriverCarBrandInputValueKey);
  FocusNode get driverCarModelInputFocusNode =>
      _getFormFocusNode(DriverCarModelInputValueKey);
  FocusNode get driverCarYearInputFocusNode =>
      _getFormFocusNode(DriverCarYearInputValueKey);
  FocusNode get driverImmatriculationCarInputFocusNode =>
      _getFormFocusNode(DriverImmatriculationCarInputValueKey);
  FocusNode get driverCarPlacesInputFocusNode =>
      _getFormFocusNode(DriverCarPlacesInputValueKey);

  TextEditingController _getFormTextEditingController(
    String key, {
    String? initialValue,
  }) {
    if (_RegisterProfileViewTextEditingControllers.containsKey(key)) {
      return _RegisterProfileViewTextEditingControllers[key]!;
    }

    _RegisterProfileViewTextEditingControllers[key] =
        TextEditingController(text: initialValue);
    return _RegisterProfileViewTextEditingControllers[key]!;
  }

  FocusNode _getFormFocusNode(String key) {
    if (_RegisterProfileViewFocusNodes.containsKey(key)) {
      return _RegisterProfileViewFocusNodes[key]!;
    }
    _RegisterProfileViewFocusNodes[key] = FocusNode();
    return _RegisterProfileViewFocusNodes[key]!;
  }

  /// Registers a listener on every generated controller that calls [model.setData()]
  /// with the latest textController values
  void syncFormWithViewModel(FormStateHelper model) {
    driverCarColorInputController.addListener(() => _updateFormData(model));
    driverCarBrandInputController.addListener(() => _updateFormData(model));
    driverCarModelInputController.addListener(() => _updateFormData(model));
    driverCarYearInputController.addListener(() => _updateFormData(model));
    driverImmatriculationCarInputController
        .addListener(() => _updateFormData(model));
    driverCarPlacesInputController.addListener(() => _updateFormData(model));

    _updateFormData(model, forceValidate: _autoTextFieldValidation);
  }

  /// Registers a listener on every generated controller that calls [model.setData()]
  /// with the latest textController values
  @Deprecated(
    'Use syncFormWithViewModel instead.'
    'This feature was deprecated after 3.1.0.',
  )
  void listenToFormUpdated(FormViewModel model) {
    driverCarColorInputController.addListener(() => _updateFormData(model));
    driverCarBrandInputController.addListener(() => _updateFormData(model));
    driverCarModelInputController.addListener(() => _updateFormData(model));
    driverCarYearInputController.addListener(() => _updateFormData(model));
    driverImmatriculationCarInputController
        .addListener(() => _updateFormData(model));
    driverCarPlacesInputController.addListener(() => _updateFormData(model));

    _updateFormData(model, forceValidate: _autoTextFieldValidation);
  }

  /// Updates the formData on the FormViewModel
  void _updateFormData(FormStateHelper model, {bool forceValidate = false}) {
    model.setData(
      model.formValueMap
        ..addAll({
          DriverCarColorInputValueKey: driverCarColorInputController.text,
          DriverCarBrandInputValueKey: driverCarBrandInputController.text,
          DriverCarModelInputValueKey: driverCarModelInputController.text,
          DriverCarYearInputValueKey: driverCarYearInputController.text,
          DriverImmatriculationCarInputValueKey:
              driverImmatriculationCarInputController.text,
          DriverCarPlacesInputValueKey: driverCarPlacesInputController.text,
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

    for (var controller in _RegisterProfileViewTextEditingControllers.values) {
      controller.dispose();
    }
    for (var focusNode in _RegisterProfileViewFocusNodes.values) {
      focusNode.dispose();
    }

    _RegisterProfileViewTextEditingControllers.clear();
    _RegisterProfileViewFocusNodes.clear();
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

  String? get driverCarColorInputValue =>
      this.formValueMap[DriverCarColorInputValueKey] as String?;
  String? get driverCarBrandInputValue =>
      this.formValueMap[DriverCarBrandInputValueKey] as String?;
  String? get driverCarModelInputValue =>
      this.formValueMap[DriverCarModelInputValueKey] as String?;
  String? get driverCarYearInputValue =>
      this.formValueMap[DriverCarYearInputValueKey] as String?;
  String? get driverImmatriculationCarInputValue =>
      this.formValueMap[DriverImmatriculationCarInputValueKey] as String?;
  String? get driverCarPlacesInputValue =>
      this.formValueMap[DriverCarPlacesInputValueKey] as String?;

  set driverCarColorInputValue(String? value) {
    this.setData(
      this.formValueMap..addAll({DriverCarColorInputValueKey: value}),
    );

    if (_RegisterProfileViewTextEditingControllers.containsKey(
        DriverCarColorInputValueKey)) {
      _RegisterProfileViewTextEditingControllers[DriverCarColorInputValueKey]
          ?.text = value ?? '';
    }
  }

  set driverCarBrandInputValue(String? value) {
    this.setData(
      this.formValueMap..addAll({DriverCarBrandInputValueKey: value}),
    );

    if (_RegisterProfileViewTextEditingControllers.containsKey(
        DriverCarBrandInputValueKey)) {
      _RegisterProfileViewTextEditingControllers[DriverCarBrandInputValueKey]
          ?.text = value ?? '';
    }
  }

  set driverCarModelInputValue(String? value) {
    this.setData(
      this.formValueMap..addAll({DriverCarModelInputValueKey: value}),
    );

    if (_RegisterProfileViewTextEditingControllers.containsKey(
        DriverCarModelInputValueKey)) {
      _RegisterProfileViewTextEditingControllers[DriverCarModelInputValueKey]
          ?.text = value ?? '';
    }
  }

  set driverCarYearInputValue(String? value) {
    this.setData(
      this.formValueMap..addAll({DriverCarYearInputValueKey: value}),
    );

    if (_RegisterProfileViewTextEditingControllers.containsKey(
        DriverCarYearInputValueKey)) {
      _RegisterProfileViewTextEditingControllers[DriverCarYearInputValueKey]
          ?.text = value ?? '';
    }
  }

  set driverImmatriculationCarInputValue(String? value) {
    this.setData(
      this.formValueMap..addAll({DriverImmatriculationCarInputValueKey: value}),
    );

    if (_RegisterProfileViewTextEditingControllers.containsKey(
        DriverImmatriculationCarInputValueKey)) {
      _RegisterProfileViewTextEditingControllers[
              DriverImmatriculationCarInputValueKey]
          ?.text = value ?? '';
    }
  }

  set driverCarPlacesInputValue(String? value) {
    this.setData(
      this.formValueMap..addAll({DriverCarPlacesInputValueKey: value}),
    );

    if (_RegisterProfileViewTextEditingControllers.containsKey(
        DriverCarPlacesInputValueKey)) {
      _RegisterProfileViewTextEditingControllers[DriverCarPlacesInputValueKey]
          ?.text = value ?? '';
    }
  }

  bool get hasDriverCarColorInput =>
      this.formValueMap.containsKey(DriverCarColorInputValueKey) &&
      (driverCarColorInputValue?.isNotEmpty ?? false);
  bool get hasDriverCarBrandInput =>
      this.formValueMap.containsKey(DriverCarBrandInputValueKey) &&
      (driverCarBrandInputValue?.isNotEmpty ?? false);
  bool get hasDriverCarModelInput =>
      this.formValueMap.containsKey(DriverCarModelInputValueKey) &&
      (driverCarModelInputValue?.isNotEmpty ?? false);
  bool get hasDriverCarYearInput =>
      this.formValueMap.containsKey(DriverCarYearInputValueKey) &&
      (driverCarYearInputValue?.isNotEmpty ?? false);
  bool get hasDriverImmatriculationCarInput =>
      this.formValueMap.containsKey(DriverImmatriculationCarInputValueKey) &&
      (driverImmatriculationCarInputValue?.isNotEmpty ?? false);
  bool get hasDriverCarPlacesInput =>
      this.formValueMap.containsKey(DriverCarPlacesInputValueKey) &&
      (driverCarPlacesInputValue?.isNotEmpty ?? false);

  bool get hasDriverCarColorInputValidationMessage =>
      this.fieldsValidationMessages[DriverCarColorInputValueKey]?.isNotEmpty ??
      false;
  bool get hasDriverCarBrandInputValidationMessage =>
      this.fieldsValidationMessages[DriverCarBrandInputValueKey]?.isNotEmpty ??
      false;
  bool get hasDriverCarModelInputValidationMessage =>
      this.fieldsValidationMessages[DriverCarModelInputValueKey]?.isNotEmpty ??
      false;
  bool get hasDriverCarYearInputValidationMessage =>
      this.fieldsValidationMessages[DriverCarYearInputValueKey]?.isNotEmpty ??
      false;
  bool get hasDriverImmatriculationCarInputValidationMessage =>
      this
          .fieldsValidationMessages[DriverImmatriculationCarInputValueKey]
          ?.isNotEmpty ??
      false;
  bool get hasDriverCarPlacesInputValidationMessage =>
      this.fieldsValidationMessages[DriverCarPlacesInputValueKey]?.isNotEmpty ??
      false;

  String? get driverCarColorInputValidationMessage =>
      this.fieldsValidationMessages[DriverCarColorInputValueKey];
  String? get driverCarBrandInputValidationMessage =>
      this.fieldsValidationMessages[DriverCarBrandInputValueKey];
  String? get driverCarModelInputValidationMessage =>
      this.fieldsValidationMessages[DriverCarModelInputValueKey];
  String? get driverCarYearInputValidationMessage =>
      this.fieldsValidationMessages[DriverCarYearInputValueKey];
  String? get driverImmatriculationCarInputValidationMessage =>
      this.fieldsValidationMessages[DriverImmatriculationCarInputValueKey];
  String? get driverCarPlacesInputValidationMessage =>
      this.fieldsValidationMessages[DriverCarPlacesInputValueKey];
}

extension Methods on FormStateHelper {
  setDriverCarColorInputValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[DriverCarColorInputValueKey] =
          validationMessage;
  setDriverCarBrandInputValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[DriverCarBrandInputValueKey] =
          validationMessage;
  setDriverCarModelInputValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[DriverCarModelInputValueKey] =
          validationMessage;
  setDriverCarYearInputValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[DriverCarYearInputValueKey] =
          validationMessage;
  setDriverImmatriculationCarInputValidationMessage(
          String? validationMessage) =>
      this.fieldsValidationMessages[DriverImmatriculationCarInputValueKey] =
          validationMessage;
  setDriverCarPlacesInputValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[DriverCarPlacesInputValueKey] =
          validationMessage;

  /// Clears text input fields on the Form
  void clearForm() {
    driverCarColorInputValue = '';
    driverCarBrandInputValue = '';
    driverCarModelInputValue = '';
    driverCarYearInputValue = '';
    driverImmatriculationCarInputValue = '';
    driverCarPlacesInputValue = '';
  }

  /// Validates text input fields on the Form
  void validateForm() {
    this.setValidationMessages({
      DriverCarColorInputValueKey:
          getValidationMessage(DriverCarColorInputValueKey),
      DriverCarBrandInputValueKey:
          getValidationMessage(DriverCarBrandInputValueKey),
      DriverCarModelInputValueKey:
          getValidationMessage(DriverCarModelInputValueKey),
      DriverCarYearInputValueKey:
          getValidationMessage(DriverCarYearInputValueKey),
      DriverImmatriculationCarInputValueKey:
          getValidationMessage(DriverImmatriculationCarInputValueKey),
      DriverCarPlacesInputValueKey:
          getValidationMessage(DriverCarPlacesInputValueKey),
    });
  }
}

/// Returns the validation message for the given key
String? getValidationMessage(String key) {
  final validatorForKey = _RegisterProfileViewTextValidations[key];
  if (validatorForKey == null) return null;

  String? validationMessageForKey = validatorForKey(
    _RegisterProfileViewTextEditingControllers[key]!.text,
  );

  return validationMessageForKey;
}

/// Updates the fieldsValidationMessages on the FormViewModel
void updateValidationData(FormStateHelper model) =>
    model.setValidationMessages({
      DriverCarColorInputValueKey:
          getValidationMessage(DriverCarColorInputValueKey),
      DriverCarBrandInputValueKey:
          getValidationMessage(DriverCarBrandInputValueKey),
      DriverCarModelInputValueKey:
          getValidationMessage(DriverCarModelInputValueKey),
      DriverCarYearInputValueKey:
          getValidationMessage(DriverCarYearInputValueKey),
      DriverImmatriculationCarInputValueKey:
          getValidationMessage(DriverImmatriculationCarInputValueKey),
      DriverCarPlacesInputValueKey:
          getValidationMessage(DriverCarPlacesInputValueKey),
    });
