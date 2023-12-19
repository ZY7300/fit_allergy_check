import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:fit_allergy_check/component/my_dialog.dart';
import 'package:fit_allergy_check/controller/allergen_controller.dart';
import 'package:fit_allergy_check/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddAllergenPage extends StatefulWidget {
  final int index;

  const AddAllergenPage({Key? key, required this.index}) : super(key: key);

  @override
  State<AddAllergenPage> createState() => _AddAllergenPageState();
}

class _AddAllergenPageState extends State<AddAllergenPage> {
  int indexx = 0;
  String uid = "";

  TextEditingController _allerNameController = TextEditingController();
  TextEditingController _descController = TextEditingController();

  final authController = Get.find<AuthController>();
  final allerController = Get.find<AllergenController>();

  @override
  void initState() {
    super.initState();

    indexx = widget.index + 1;
    print("widget.index: ${widget.index} indexx: $indexx");

    uid = authController.uid.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Allergen'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Center(child: Text(indexx.toString())),
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
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  showAddConfirmationDialog();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(100, 40),
                ),
                child: const Text("Add Allergen"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  showAddConfirmationDialog() async {
    await Get.dialog(
      MyDialog(
        title: "Confirmation",
        message: "Are you sure you want to add new allergen?",
        dialogType: DialogType.info,
        withBtn: true,
        okPressed: () {
          Get.back(result: true);
        },
        cancelPressed: () {
          Get.back();
        },
        okText: "Add",
        cancelText: "Cancel",
      ),
    ).then((result) async {
      if (result != null) {
        if (result) {
          await allerController.addAllergen(
              uid, indexx, _allerNameController.text, _descController.text);
          Get.back(result: true);
        }
      }
    });
  }
}
