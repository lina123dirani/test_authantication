class AppRegex {
  static bool isEmailValid(String email) {
    return RegExp(
      r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$',
    ).hasMatch(email);
  }

  static bool isPasswordValid(String password) {
    // Enforce the requested password rules:
    // 1. at least one special character
    // 2. at least one number
    // 3. at least one lowercase letter
    // 4. at least one uppercase letter
    return hasSpecialCharacter(password) &&
        hasNumber(password) &&
        hasLowerCase(password) &&
        hasUpperCase(password);
  }

  static bool isPhoneNumberValid(String phoneNumber) {
    return RegExp(r'^\+?[0-9]{6,15}$').hasMatch(phoneNumber);
    // Global format for international phone numbers.
    // return RegExp(r'^(010|011|012|015)[0-9]{8}$').hasMatch(phoneNumber);
  }

  static bool hasLowerCase(String password) {
    return RegExp(r'(?=.*[a-z])').hasMatch(password);
  }
  
   static  String flagEmoji(String countryCode) {
    return countryCode.toUpperCase().replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397),
    );
  }

  static bool hasUpperCase(String password) {
    return RegExp(r'(?=.*[A-Z])').hasMatch(password);
  }

  static bool hasNumber(String password) {
    return RegExp(r'(?=.*[0-9])').hasMatch(password);
  }

  static bool hasSpecialCharacter(String password) {
    // Use a raw triple-quoted string so we can include both single and double
    // quotes in the character class without terminating the Dart string.
    return RegExp(
      r'''(?=.*[!@#\$%\^&\*()_\-+=\[\]{};:'",<>./?\|`~])''',
    ).hasMatch(password);
  }

  static bool hasMinLength(String password) {
    return RegExp(r'(?=.{8,})').hasMatch(password);
  }

  static String maskPhoneNumber(String phoneNumber) {
    if (phoneNumber.length <= 7) return phoneNumber;

    // Extract prefix and last two digits
    String prefix = phoneNumber.substring(0, 4); // +963
    String suffix = phoneNumber.substring(
      phoneNumber.length - 2,
    ); // last 2 digits

    // Calculate number of stars
    int starsCount = phoneNumber.length - (prefix.length + suffix.length);
    String stars = '*' * starsCount;

    return '$prefix$stars$suffix';
  }

  static String extractNumberOnly(String input) {
    // Extract numeric prefix from mixed text.
    RegExp regex = RegExp(r'^\s*([\d.]+)');
    Match? match = regex.firstMatch(input);

    if (match != null) {
      return match.group(1)!; // Number found before any trailing text.
    }

    return '';
  }
}
