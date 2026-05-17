import 'package:authantication/core/utils/app_regex.dart';

class Validator {
  static String? validatorPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "validation.field_cannot_be_empty";
    } 
    // else if (!AppRegex.hasMinLength(value)) {
    //   return 'كلمة المرور يجب ان تحتوي 8 أحرف على الأقل';
    // }
    // if (!AppRegex.hasUpperCase(value)) {
    //   return 'يجب إدخال حرف واحد كبير على الأقل';
    // }
    // if (!AppRegex.hasLowerCase(value)) {
    //   return 'يجب إدخال حرف صغير واحد على الأقل';
    // }
    // if (!AppRegex.hasNumber(value)) {
    //   return 'كلمة السر يجب أن تحتوي رقم واحد على الأقل';
    // }
    // if (!AppRegex.hasSpecialCharacter(value)) {
    //   return 'يجب إدخال رمز واحد على الأقل';
    // }
    return null;
  }

  static String? validatorConfirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return "validation.field_cannot_be_empty";
    }
    if (originalPassword == null || originalPassword.isEmpty) {
      return "validation.field_cannot_be_empty";
    }
    if (value != originalPassword) {
      return "validation.password_not_match";
    }
    return null;
  }

  static dynamic validatorEmail(value) {
    if (value == null || value.isEmpty) {
      return "validation.field_cannot_be_empty";
    } else if (!AppRegex.isEmailValid(value) && value.isNotEmpty) {
      return "validation.enter_valid_email";
    } else {
      return null;
    }
  }

  static dynamic validatorNotEmpty(value) {
    if (value == null || value.isEmpty) {
      return "validation.field_cannot_be_empty";
    } else {
      return null;
    }
  }

  static String? validatorPhoneNumber(String? value) {
    final v = (value ?? '').trim();

    if (v.isEmpty) return "validation.field_cannot_be_empty";

    if (!AppRegex.isPhoneNumberValid(v)) {
      return "validation.enter_valid_phone";
    }
    return null;
  }
}
