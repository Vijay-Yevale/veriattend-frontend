// lib/core/validators/app_validators.dart

class AppValidators {
  AppValidators._();

  // ─── Email ────────────────────────────────────────────
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  // ─── Password ─────────────────────────────────────────
  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.trim().length < 6) {
      return 'Minimum 6 characters required';
    }
    return null;
  }

  // ─── Username ─────────────────────────────────────────
  static String? userName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    if (value.trim().length < 3) {
      return 'Minimum 3 characters required';
    }
    return null;
  }

  // ─── PRN ──────────────────────────────────────────────
  // format: RBT23CS130
  static String? prn(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'PRN is required';
    }

    final prnRegex = RegExp(r'^RBT\d{2}[A-Z]+\d+$');

    if (!prnRegex.hasMatch(value.trim().toUpperCase())) {
      return 'Invalid PRN format (e.g. RBT23CS130)';
    }

    return null;
  }

  // ─── Required field (generic) ─────────────────────────
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // ─── Marks validator ──────────────────────────────────
  static String? marks(String? value, {required double max}) {
    if (value == null || value.trim().isEmpty) {
      return 'Marks are required';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) {
      return 'Enter a valid number';
    }
    if (parsed < 0) {
      return 'Marks cannot be negative';
    }
    if (parsed > max) {
      return 'Marks cannot exceed $max';
    }
    return null;
  }

  static String? academicYear(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Academic Year is required';
    }

    final regex = RegExp(r'^\d{4}-\d{2}$');

    if (!regex.hasMatch(value.trim())) {
      return 'Format should be YYYY-YY (e.g. 2026-27)';
    }

    return null;
  }

  // ─── ObjectId (MongoDB) ───────────────────────────────
  static String? objectId(String? value, {String fieldName = 'ID'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final objectIdRegex = RegExp(r'^[a-fA-F0-9]{24}$');
    if (!objectIdRegex.hasMatch(value.trim())) {
      return 'Invalid $fieldName';
    }
    return null;
  }

  static String? semester(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Semester is required';
    }

    final semester = int.tryParse(value);

    if (semester == null || semester < 1 || semester > 8) {
      return 'Semester must be between 1 and 8';
    }

    return null;
  }
}
