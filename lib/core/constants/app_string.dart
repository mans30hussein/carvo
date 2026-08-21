class AppStrings {
  const AppStrings._();

  // Login screen
  static const String loginTitle = 'تسجيل الدخول';
  static const String loginSubtitle = 'مرحباً بك في منصة CarVo لخدمات السيارات';
  static const String loginButton = 'تسجيل الدخول';
  static const String noAccountPrompt = 'معندكش حساب؟ إنشاء حساب جديد';

  // Sign up screen
  static const String signUpTitle = 'إنشاء حساب جديد';
  static const String signUpSubtitle = 'انضم إلى منصة CarVo لخدمات السيارات';
  static const String signUpButton = 'إنشاء الحساب';
  static const String hasAccountPrompt = 'لديك حساب بالفعل؟ تسجيل الدخول';
  static const String signUpSuccessMessage = 'تم إنشاء الحساب بنجاح، سجّل دخولك الآن';

  // Shared fields
  static const String emailLabel = 'البريد الإلكتروني';
  static const String passwordLabel = 'كلمة المرور';
  static const String nameLabel = 'الاسم بالكامل';
  static const String phoneLabel = 'رقم الهاتف';

  // Shared actions / dividers
  static const String orDivider = 'أو';
  static const String googleSignIn = 'تسجيل بحساب Google';

  // Errors
  static const String emptyFieldsError = 'يرجى ملء كافة الحقول';
  static const String invalidLoginError = 'بيانات الدخول غير صحيحة، أو أنشئ حساباً جديداً';
  static const String googleSignInError = 'تعذر تسجيل الدخول عبر Google';
  static const String genericSignUpError = 'حدث خطأ أثناء إنشاء الحساب، حاول مرة أخرى';
  static const String genericSignInError = 'حدث خطأ غير متوقع، حاول مرة أخرى';
  static const String emailAlreadyInUseError = 'البريد الإلكتروني مستخدم بالفعل';
  static const String weakPasswordError = 'كلمة المرور ضعيفة جداً';
  static const String invalidEmailError = 'صيغة البريد الإلكتروني غير صحيحة';
}