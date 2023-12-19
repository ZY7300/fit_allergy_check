import 'package:firebase_core/firebase_core.dart';
import 'package:fit_allergy_check/controller/allergen_controller.dart';
import 'package:fit_allergy_check/controller/auth_controller.dart';
import 'package:fit_allergy_check/firebase_options.dart';
import 'package:fit_allergy_check/home_page.dart';
import 'package:fit_allergy_check/pages/login_page.dart';
import 'package:fit_allergy_check/pages/register_page.dart';
import 'package:fit_allergy_check/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    Get.put(AuthController());
    Get.put(AllergenController());

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      // home: const MyHomePage(),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashPage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
