class ValidationMessages {
  ValidationMessages._();

  static String translate(String? key) {
    switch (key) {
      case 'validation.field_cannot_be_empty':
        return 'الحقل مطلوب';
      case 'validation.enter_valid_email':
        return 'أدخل بريداً إلكترونياً صحيحاً';
      case 'validation.password_not_match':
        return 'كلمتا المرور غير متطابقتين';
      default:
        return key ?? 'خطأ في التحقق';
    }
  }
}
