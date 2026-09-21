class Validators {
  const Validators._();

  static final RegExp _emailPattern = RegExp(r'^[\w.+\-]+@[\w\-]+\.[\w\-.]+$');

  static String? email(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return 'Enter your email address';
    if (!_emailPattern.hasMatch(v)) return 'That does not look like an email';
    return null;
  }

  static String? password(String? value) {
    final String v = value ?? '';
    if (v.isEmpty) return 'Enter your password';
    if (v.length < 8) return 'Use at least 8 characters';
    return null;
  }

  static String? requiredPassword(String? value) {
    if ((value ?? '').isEmpty) return 'Enter your password';
    return null;
  }

  static String? name(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return 'Enter your name';
    if (v.length < 2) return 'That name looks too short';
    return null;
  }

  static String? age(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return 'Enter your age';
    final int? parsed = int.tryParse(v);
    if (parsed == null) return 'Enter a valid age';
    if (parsed < 13 || parsed > 120) return 'Enter an age between 13 and 120';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if ((value ?? '').isEmpty) return 'Re-enter your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }
}
