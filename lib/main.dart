import 'package:carvo/core/constants/app_theme.dart';
import 'package:carvo/core/depandency_injection/depandency_injection.dart';
import 'package:carvo/core/maping/gelocator.dart';
import 'package:carvo/core/routing/app_routes.dart';
 import 'package:carvo/firebase_options.dart';
 
import 'package:carvo/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AuthService.initGoogleSignIn();
  setupAuthDependencies();
  setupRoleSelectionDependencies();

  try {
    await Firebase.initializeApp();
  } catch (e) {
   // print("Firebase Init: $e");
  }
  runApp(const CarVoApp());
}

class CarVoApp extends StatelessWidget {
  const CarVoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CarVo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      locale: const Locale('ar', 'EG'),
      supportedLocales: const [Locale('ar', 'EG'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const LocationWidget(),
      //       initialRoute: AppRoutes.login,   // شاشة البداية
      // onGenerateRoute: generateAppRoute,
    );
  }
}
