import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fit_allergy_check/component/auth.dart';
import 'package:fit_allergy_check/component/input_style.dart';
import 'package:fit_allergy_check/component/loading_dialog.dart';
import 'package:fit_allergy_check/component/my_dialog.dart';
import 'package:fit_allergy_check/controller/auth_controller.dart';
import 'package:fit_allergy_check/pages/reset_password_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();

  AuthStatus _status = AuthStatus.unknown;
  String username = "";
  String uid = "";

  final authController = Get.find<AuthController>();
  final _auth = FirebaseAuth.instance;

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
              child: Image.asset('assets/images/logo.png'),
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
            inputField("Enter your email", Icons.person_outline, false,
                _emailTextController),
            SizedBox(
              height: 20,
            ),
            inputField("Enter your password", Icons.lock_outline, true,
                _passwordTextController),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 25),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Get.to(ResetPasswordPage());
                  },
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 50,
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

                  if (_emailTextController.text.isNotEmpty &&
                      _passwordTextController.text.isNotEmpty) {
                    login(
                            email: _emailTextController.text,
                            password: _passwordTextController.text)
                        .then((status) {
                      if (status == AuthStatus.successful) {
                        Get.toNamed('/home');
                      } else {
                        AuthExceptionHandler.generateErrorMessage(status);
                      }
                    });
                  } else {
                    Get.dialog(
                      MyDialog(
                        title: "Error",
                        message: "Please fill in all detail",
                        dialogType: DialogType.error,
                        withBtn: false,
                      ),
                    );
                  }
                },
                child: Text(
                  "LOGIN",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(fontSize: 15, color: Colors.grey[850]),
                  ),
                  TextSpan(
                      text: "Register",
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Get.toNamed('/register');
                        }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<AuthStatus> login({
    required String email,
    required String password,
  }) async {
    try {
      LoadingDialog.show();
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User user = userCredential.user!;
      username = user.displayName ?? "No username set";
      uid = user.uid;
      _status = AuthStatus.successful;

      authController.saveUserLocal(username, email, uid);

      LoadingDialog.dismiss();

      print(
          "Signed in as ${user.email} with username: $username and uid: $uid");
    } on FirebaseAuthException catch (e) {
      LoadingDialog.dismiss();
      _status = AuthExceptionHandler.handleAuthException(e);
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        Get.dialog(MyDialog(title: "Error", message: "No user found for that email", dialogType: DialogType.error, withBtn: false,));
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        Get.dialog(MyDialog(title: "Error", message: "Wrong password provided for that user", dialogType: DialogType.error, withBtn: false));
      }
    }
    return _status;
  }
}
