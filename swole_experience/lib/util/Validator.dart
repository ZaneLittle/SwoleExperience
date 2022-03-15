class Validator {

  static String? doubleValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please a value';
    } else if (double.tryParse(value) == null) {
      return 'Please enter a numeric value';
    } else {
      return null;
    }
  }

  static String? doubleValidatorNullAllowed(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    } else if (double.tryParse(value) == null) {
      return 'Please enter a numeric value';
    } else {
      return null;
    }
  }
}