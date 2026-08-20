
 /// The data collected on the sign-up screen before an account exists.
///
/// This is a domain entity (not a Firestore model) because it represents
/// input the user is providing, not a persisted user record. Once sign-up
/// succeeds, the persisted user is represented by UserModel — this class's
/// job ends at "here's what the form collected".
class SignUpCredentials {
  final String name;
  final String email;
  final String phone;
  final String password;
 
  const SignUpCredentials({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });
 
  /// Basic presence validation. Format validation (email shape, phone
  /// digits) belongs in the UI layer's TextFormField validators, not here —
  /// this only checks "did the user leave something blank".
  bool get hasAllFields =>
      name.trim().isNotEmpty &&
      email.trim().isNotEmpty &&
      phone.trim().isNotEmpty &&
      password.trim().isNotEmpty;
}
 
