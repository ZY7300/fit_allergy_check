import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fit_allergy_check/component/auth.dart';
import 'package:fit_allergy_check/component/input_style.dart';
import 'package:fit_allergy_check/component/loading_dialog.dart';
import 'package:fit_allergy_check/component/my_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  TextEditingController _emailTextController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  AuthStatus _status = AuthStatus.unknown;

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
            inputField("Enter your email", Icons.person_outline, false,
                _emailTextController),
            SizedBox(
              height: 20,
            ),
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

                  if (_emailTextController.text.isNotEmpty) {
                    resetPassword(email: _emailTextController.text)
                        .then((status) async {
                      if (status == AuthStatus.successful) {
                        await Get.dialog(MyDialog(
                          title: "Sent!",
                          message: "Please check your email to reset password",
                          dialogType: DialogType.success,
                          withBtn: true,
                          okPressed: () {
                            Get.back();
                          },
                        ));
                        Get.back();
                      } else {
                        AuthExceptionHandler.generateErrorMessage(status);
                      }
                    });
                  } else {
                    Get.dialog(MyDialog(
                        title: "Error",
                        message: "Please fill in email",
                        dialogType: DialogType.error,
                        withBtn: false));
                  }
                },
                child: Text(
                  "RESET PASSWORD",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<AuthStatus> resetPassword({required String email}) async {
    try {
      LoadingDialog.show();
      await _auth.sendPasswordResetEmail(email: email);
      _status = AuthStatus.successful;
      LoadingDialog.dismiss();
    } on FirebaseAuthException catch (e) {
      LoadingDialog.dismiss();
      _status = AuthExceptionHandler.handleAuthException(e);
    }
    return _status;
  }
}
