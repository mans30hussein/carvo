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

  // Role selection screen
  static const String roleSelectionTitle = 'استكمال الحساب';
  static const String chooseAccountType = 'اختر نوع حسابك:';
  static const String requiredData = 'البيانات المطلوبة:';
  static const String saveAndContinue = 'حفظ واستمرار';
  static const String completeRequiredFields = 'يرجى استكمال جميع الحقول المطلوبة';
  static const String genericSaveProfileError =
      'حدث خطأ أثناء حفظ البيانات، حاول مرة أخرى';

  // Roles
  static const String roleCustomerTitle = '🚗 عميل';
  static const String roleCustomerSubtitle = 'طلب قطع وغيار وإنقاذ';
  static const String roleVendorTitle = '🏪 تاجر / محل';
  static const String roleVendorSubtitle = 'بيع وإدارة قطع الغيار';
  static const String roleMechanicTitle = '🔧 ميكانيكي / ورشة';
  static const String roleMechanicSubtitle = 'استقبال أعطال وصيانة';
  static const String roleWinchTitle = '🛻 ونش إنقاذ';
  static const String roleWinchSubtitle = 'سحب وطوارئ الطرق';

  // Dynamic field labels by role
  static const String nameHintCustomer = 'الاسم بالكامل';
  static const String nameHintVendor = 'اسم المحل أو الشركة';
  static const String nameHintMechanic = 'اسم الورشة / الفني';
  static const String nameHintWinch = 'اسم السائق / الونش';

  static const String addressHintCustomer =
      'العنوان بالتفصيل (المحافظة، المدينة، الشارع)';
  static const String addressHintVendor = 'عنوان المحل / الشركة بالتفصيل';
  static const String addressHintMechanic = 'عنوان الورشة بالتفصيل';
  static const String addressHintWinch = 'نطاق التغطية والعنوان بالتفصيل';

  static const String phoneContactLabel = 'رقم الهاتف للتواصل';
  static const String specializationLabel =
      'التخصص (مثال: ميكانيكا عامة، كهرباء، عفشة...)';
}