import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'pages/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      'pk_test_51RFh8rRRNxfyNkWbyBYdJmGEZ9VfdHo2FZuUxBitPW8d7fT7WVa3sNEZN45yZ0FHDrUp8y35QoH6Iz8BUNFt85SN00BwBxPS11';
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance
      .activate(androidProvider: AndroidProvider.playIntegrity);
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('zh'), Locale('th')],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        ...context.localizationDelegates,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: LoginScreen(),
    );
  }
}
