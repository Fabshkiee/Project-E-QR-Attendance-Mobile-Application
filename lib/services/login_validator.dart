import 'package:powersync/powersync.dart';

class LoginValidatorResult {
  final bool isValid;
  final String message;

  const LoginValidatorResult({required this.isValid, required this.message});
}

class LoginValidator {
  static Future<LoginValidatorResult> validate(
    PowerSyncDatabase db,
    String? username,
    String? password
  ) async {
    print('✅ Processing login credentials: $username, $password');

    if (username == null && password == null) {
      return LoginValidatorResult(isValid: false, message: 'Email and password cannot be null');
    }

    final String usernameToCheck = username ?? '';
    final String passwordToCheck = password ?? '';

    if (usernameToCheck.isEmpty && passwordToCheck.isEmpty) {
      return LoginValidatorResult(isValid: false, message: 'Username and password cannot be empty');
    }
    final matchedUsername = await db.getAll("SELECT * FROM users WHERE nickname = ? AND (role = 'Staff' OR role = 'Admin')", [usernameToCheck]);

    if (matchedUsername.isEmpty) {
      return LoginValidatorResult(isValid: false, message: 'No user found with username $usernameToCheck');
    }

    if (matchedUsername.isNotEmpty && passwordToCheck == 'Admin') {
      return LoginValidatorResult(isValid: true, message: 'Login successful for user $usernameToCheck');
    } else {
      return LoginValidatorResult(isValid: false, message: 'Incorrect password for user $usernameToCheck');
    }


    
  }
}
