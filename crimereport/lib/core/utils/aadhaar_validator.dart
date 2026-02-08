/// Validation utility for Aadhaar numbers.
class AadhaarValidator {
  /// Validates an Aadhaar number string.
  ///
  /// Returns null if valid, or an error message string if invalid.
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Aadhaar number is required';
    }

    // Remove any whitespace or special characters just in case
    final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanValue.length != 12) {
      return 'Aadhaar number must be exactly 12 digits';
    }

    // Check for non-numeric characters (redundant with cleanValue logic but good for specific error)
    if (RegExp(r'[^0-9]').hasMatch(value)) {
      return 'Aadhaar number must contain only digits';
    }

    // Check for repetitive patterns (e.g. 000000000000, 111111111111)
    if (_hasRepetitivePattern(cleanValue)) {
      return 'Invalid Aadhaar number format (repetitive digits)';
    }

    // The first digit of Aadhaar should not be 0 or 1
    if (cleanValue.startsWith('0') || cleanValue.startsWith('1')) {
      return 'Aadhaar number cannot start with 0 or 1';
    }

    // Verhoeff algorithm check could be added here for real validation
    // For simulation, we assume basic checks pass.

    return null;
  }

  /// Checks if the string consists of the same digit repeated 12 times.
  static bool _hasRepetitivePattern(String value) {
    // If all characters are the same as the first character
    return value.split('').every((char) => char == value[0]);
  }
}
