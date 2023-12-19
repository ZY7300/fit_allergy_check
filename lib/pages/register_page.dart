import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fit_allergy_check/component/auth.dart';
import 'package:fit_allergy_check/component/input_style.dart';
import 'package:fit_allergy_check/component/loading_dialog.dart';
import 'package:fit_allergy_check/component/my_dialog.dart';
import 'package:fit_allergy_check/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _usernameTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();

  AuthStatus _status = AuthStatus.unknown;
  String uid = "";

  final authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.elliptical(50, 50),
                    bottomLeft: Radius.elliptical(50, 50)),
              ),
              child: Image.asset('assets/images/logo.png',
                  width: 100, height: 100),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              "- Fit Allergy Check -",
              style: TextStyle(
                  fontSize: 20, color: Colors.black87.withOpacity(0.7)),
            ),
            SizedBox(
              height: 30,
            ),
            inputField("Enter your username", Icons.person_outline, false,
                _usernameTextController),
            SizedBox(
              height: 20,
            ),
            inputField("Enter your email", Icons.person_outline, false,
                _emailTextController),
            SizedBox(
              height: 20,
            ),
            inputField("Enter your password", Icons.lock_outline, true,
                _passwordTextController),
            SizedBox(
              height: 60,
            ),
            Container(
              height: 60,
              width: 300,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();

                  if (_usernameTextController.text.isNotEmpty &&
                      _emailTextController.text.isNotEmpty &&
                      _passwordTextController.text.isNotEmpty) {
                    createAccount(
                            username: _usernameTextController.text,
                            email: _emailTextController.text,
                            password: _passwordTextController.text)
                        .then((status) {
                      if (status == AuthStatus.successful) {
                        Navigator.of(context).pushReplacementNamed('/home');
                      } else {
                        AuthExceptionHandler.generateErrorMessage(status);
                      }
                    });
                  } else {
                    Get.dialog(MyDialog(title: "Error", message: "Please fill in all details", dialogType: DialogType.error, withBtn: false));
                  }
                },
                child: Text(
                  "REGISTER",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<AuthStatus> createAccount({
    required username,
    required String email,
    required String password,
  }) async {
    try {
      LoadingDialog.show();
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User user = userCredential.user!;
      uid = user.uid;
      await user.updateDisplayName(username);
      _status = AuthStatus.successful;

      authController.saveUserLocal(username, email, uid);

      LoadingDialog.dismiss();

      print("User created with UID: $uid");
    } on FirebaseAuthException catch (e) {
      LoadingDialog.dismiss();
      _status = AuthExceptionHandler.handleAuthException(e);
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        Get.dialog(MyDialog(title: "Error", message: "The password provided is too weak", dialogType: DialogType.error, withBtn: false));
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        Get.dialog(MyDialog(title: "Error", message: "The account already exists for that email", dialogType: DialogType.error, withBtn: false));
      }
    }
    return _status;
  }
}
