import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fit_allergy_check/component/loading_dialog.dart';
import 'package:fit_allergy_check/controller/allergen_controller.dart';
import 'package:fit_allergy_check/controller/auth_controller.dart';
import 'package:fit_allergy_check/controller/overweight_controller.dart';
import 'package:fit_allergy_check/controller/underweight_controller.dart';
import 'package:fit_allergy_check/pages/check_bmi_page.dart';
import 'package:fit_allergy_check/pages/check_calo_phos_sod_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = "";
  String uid = "";

  final _auth = FirebaseAuth.instance;
  final authController = Get.put(AuthController());
  final allergenController = Get.put(AllergenController());
  final underwController = Get.put(UnderweightController());
  final overwController = Get.put(OverweightController());

  File? _image;
  List? _output;
  final picker = ImagePicker();

  classifyImage(File image) async {
    LoadingDialog.show();
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _output = output!;
    });
    LoadingDialog.dismiss();
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fit Allergy Check'),
        leading: Container(),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut().then((value) {
                logout();
                Get.offAllNamed('/login');
              });
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(flex: 1, child: Container()),
          Expanded(
            flex: 1,
            child: FutureBuilder<void>(
              future: authController.fetchUserLocal(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else {
                  // final username = snapshot.data;
                  uid = authController.uid.value;
                  username = authController.username.value;
                  return RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Hello ",
                          style:
                              TextStyle(fontSize: 15, color: Colors.grey[850]),
                        ),
                        TextSpan(
                          text: username.toUpperCase(),
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black.withOpacity(0.7),
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
          Expanded(flex: 1, child: Container()),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () {
                Get.to(CheckCaloPhosSodPage(date: DateTime.now(),));
              },
              child: SizedBox.expand(
                child: Card(
                  color: Colors.grey[350],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "CHECK CALORIES +",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "PHOSPHATE + SODIUM",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(flex: 1, child: Container()),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () {
                allergenController.fetchAllergens(uid);
              },
              child: SizedBox.expand(
                child: Card(
                  color: Colors.grey[350],
                  child: Center(
                    child: Text(
                      "ALLERGEN",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(flex: 1, child: Container()),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () {
                underwController.fetchUnderweights(uid);
              },
              child: SizedBox.expand(
                child: Card(
                  color: Colors.grey[350],
                  child: Center(
                    child: Text(
                      "UNDERWEIGHT",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(flex: 1, child: Container()),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () {
                overwController.fetchOverweights(uid);
              },
              child: SizedBox.expand(
                child: Card(
                  color: Colors.grey[350],
                  child: Center(
                    child: Text(
                      "OVERWEIGHT",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(flex: 1, child: Container()),
          Expanded(
            flex: 1,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Check BMI? ",
                    style: TextStyle(fontSize: 15, color: Colors.grey[850]),
                  ),
                  TextSpan(
                      text: "Click here",
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Get.to(CheckBmiPage());
                        }),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
