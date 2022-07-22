class Validator {

  static String? doubleValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    } else if (double.tryParse(value) == null) {
      return 'Invalid value';
    } else {
      return null;
    }
  }

  static String? doubleValidatorNullAllowed(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    } else if (double.tryParse(value) == null) {
      return 'Invalid value';
    } else {
      return null;
    }
  }

  static String? stringValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Invalid value';
    } else {
      return null;
    }
  }

  static String? intValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    } else if (int.tryParse(value) == null) {
      return 'Invalid value';
    } else {
      return null;
    }
  }

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