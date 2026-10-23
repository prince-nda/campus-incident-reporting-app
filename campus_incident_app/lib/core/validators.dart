import 'app_config.dart';

class Validators {
  static String? required(String? v, [String field = 'This field']) =>
      (v == null || v.trim().isEmpty) ? '$field is required' : null;

  static String? minLength(String? v, int min, String field) {
    final r = required(v, field);
    if (r != null) return r;
    return v!.trim().length < min ? '$field must be at least $min characters' : null;
  }

  static bool isAluEmail(String email) {
    final e = email.trim().toLowerCase();
    final at = e.lastIndexOf('@');
    if (at < 1) return false;
    return AppConfig.allowedEmailDomains.contains(e.substring(at + 1));
  }

  static String? aluEmail(String? v) {
    final r = required(v, 'Email');
    if (r != null) return r;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v!.trim())) {
      return 'Enter a valid email address';
    }
    if (!isAluEmail(v)) {
      return 'Use your ALU email (@${AppConfig.allowedEmailDomains.join(' or @')})';
    }
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Use at least 8 characters';
    return null;
  }
}