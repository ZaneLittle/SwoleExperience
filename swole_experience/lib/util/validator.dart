class Validator {
  static bool _requiredCheck(String? value, Object? defaultValue) {
    return ((value == null || value.isEmpty) &&
        (defaultValue == null || defaultValue.toString().isEmpty));
  }

  /// Validate that @param{value} is present and non-empty (or has a @param{defaultValue})
  /// Validate that @param{value} is a valid double
  static String? doubleValidator(String? value, {double? defaultValue}) {
    if (_requiredCheck(value, defaultValue)) {
      return 'Required';
    } else if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
      return 'Invalid value';
    } else {
      return null;
    }
  }

  /// Validate that @param{value} is a valid double
  static String? doubleValidatorNullAllowed(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    } else if (double.tryParse(value) == null) {
      return 'Invalid value';
    } else {
      return null;
    }
  }

  /// Validate that @param{value} is present and non-empty (or has a @param{defaultValue})
  static String? stringValidator(String? value, {String? defaultValue}) {
    if (_requiredCheck(value, defaultValue)) {
      return 'Required';
    } else {
      return null;
    }
  }

  /// Validate that @param{value} is present and non-empty (or has a @param{defaultValue})
  /// Validate that @param{value} is a valid int
  static String? intValidator(String? value, {int? defaultValue}) {
    if (_requiredCheck(value, defaultValue)) {
      return 'Required';
    } else if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
      return 'Invalid value';
    } else {
      return null;
    }
  }

  /// Validate that @param{value} is a valid int
  static String? intValidatorNullAllowed(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    } else if (int.tryParse(value) == null) {
      return 'Invalid value';
    } else {
      return null;
    }
  }
}
