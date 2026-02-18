/// Represents a single password requirement with its label and whether it's met.
class PasswordRequirement {
  final String label;
  final bool isMet;

  const PasswordRequirement({required this.label, required this.isMet});
}

/// Standardized password validation used across the app.
class PasswordValidator {
  static const int minLength = 8;

  /// Validates the password and returns a list of requirements with their status.
  static List<PasswordRequirement> validate(String password) {
    return [
      PasswordRequirement(
        label: 'Minimal $minLength karakter',
        isMet: password.length >= minLength,
      ),
      PasswordRequirement(
        label: 'Mengandung huruf besar (A-Z)',
        isMet: password.contains(RegExp(r'[A-Z]')),
      ),
      PasswordRequirement(
        label: 'Mengandung huruf kecil (a-z)',
        isMet: password.contains(RegExp(r'[a-z]')),
      ),
      PasswordRequirement(
        label: 'Mengandung angka (0-9)',
        isMet: password.contains(RegExp(r'[0-9]')),
      ),
    ];
  }

  /// Returns true if all password requirements are met.
  static bool isValid(String password) {
    return validate(password).every((req) => req.isMet);
  }

  /// Returns a human-readable error message if the password is invalid, or null if valid.
  static String? getErrorMessage(String password) {
    if (password.isEmpty) return 'Password tidak boleh kosong.';
    if (!isValid(password)) {
      final unmet =
          validate(password).where((r) => !r.isMet).map((r) => r.label);
      return 'Password harus: ${unmet.join(', ')}.';
    }
    return null;
  }

  /// Returns password strength as a value from 0.0 to 1.0.
  static double getStrength(String password) {
    if (password.isEmpty) return 0.0;
    final requirements = validate(password);
    final met = requirements.where((r) => r.isMet).length;
    return met / requirements.length;
  }

  /// Returns a label for the password strength level.
  static String getStrengthLabel(String password) {
    final strength = getStrength(password);
    if (strength <= 0.0) return '';
    if (strength <= 0.25) return 'Sangat Lemah';
    if (strength <= 0.5) return 'Lemah';
    if (strength <= 0.75) return 'Sedang';
    return 'Kuat';
  }
}
