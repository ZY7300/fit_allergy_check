import 'package:fit_allergy_check/controller/allergen_controller.dart';
import 'package:fit_allergy_check/controller/auth_controller.dart';
import 'package:fit_allergy_check/model/allergen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditAllergenPage extends StatefulWidget {
  final Allergen allergen;

  const EditAllergenPage({Key? key, required this.allergen}) : super(key: key);

  @override
  State<EditAllergenPage> createState() => _EditAllergenPageState();
}

class _EditAllergenPageState extends State<EditAllergenPage> {
  String uid = "";

  TextEditingController _allerNameController = TextEditingController();
  TextEditingController _descController = TextEditingController();

  final authController = Get.find<AuthController>();
  final allerController = Get.find<AllergenController>();

  @override
  void initState() {
    super.initState();

    _allerNameController.text = widget.allergen.allerName;
    _descController.text = widget.allergen.desc;

    uid = authController.uid.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Allergen'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Center(child: Text(widget.allergen.allerID.toString())),
          ),
          Padding(
            padding: EdgeInsets.all(15.0),
            child: TextField(
              controller: _allerNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Allergen Name",
                hintText: "Allergen Name",
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(15.0),
            child: TextField(
              controller: _descController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Description",
                hintText: "Description",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () async {
                  await allerController.editAllergen(
                      uid,
                      widget.allergen.allerID,
                      _allerNameController.text,
                      _descController.text);
                  Get.back(result: true);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(100, 40),
                ),
                child: const Text("Update Allergen"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
