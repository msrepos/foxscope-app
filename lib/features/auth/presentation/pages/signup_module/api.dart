// lib/features/auth/data/models/signup_draft.dart
import 'dart:io';

class SignUpDraft {
  String? email;
  String? password;
  String? firstName;
  String? lastName;
  String? username;
  String? gender;        // Add
  DateTime? birthDate;   // Add
  File? profileImage;  // Add profile image

  SignUpDraft();

  /// ✅ API PAYLOAD
  Map<String, String> toFormData() {
    final fullName =
    "${firstName?.trim() ?? ''} ${lastName?.trim() ?? ''}".trim();

    return {
      'name': fullName,
      'email': email ?? '',
      'password': password ?? '',
    };
  }
}

class SignupSession {
  static final SignupSession _instance = SignupSession._internal();
  factory SignupSession() => _instance;

  SignupSession._internal();

  final SignUpDraft draft = SignUpDraft();

  void clear() {
    draft.email = null;
    draft.password = null;
    draft.firstName = null;
    draft.lastName = null;
    draft.username = null;
    draft.profileImage = null;
  }
}
