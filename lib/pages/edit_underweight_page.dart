import 'package:fit_allergy_check/controller/auth_controller.dart';
import 'package:fit_allergy_check/controller/underweight_controller.dart';
import 'package:fit_allergy_check/model/underweight.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditUnderweightPage extends StatefulWidget {
  final Underweight underweight;

  const EditUnderweightPage({Key? key, required this.underweight})
      : super(key: key);

  @override
  State<EditUnderweightPage> createState() => _EditUnderweightPageState();
}

class _EditUnderweightPageState extends State<EditUnderweightPage> {
  String uid = "";

  TextEditingController _underwNameController = TextEditingController();
  TextEditingController _descController = TextEditingController();

  final authController = Get.find<AuthController>();
  final underwController = Get.find<UnderweightController>();

  @override
  void initState() {
    super.initState();

    _underwNameController.text = widget.underweight.underwName;
    _descController.text = widget.underweight.desc;

    uid = authController.uid.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Ingredient'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Center(child: Text(widget.underweight.underwID.toString())),
          ),
          Padding(
            padding: EdgeInsets.all(15.0),
            child: TextField(
              controller: _underwNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Ingredient Name",
                hintText: "Ingredient Name",
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
                  await underwController.editUnderweight(
                      uid,
                      widget.underweight.underwID,
                      _underwNameController.text,
                      _descController.text);
                  Get.back(result: true);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(100, 40),
                ),
                child: const Text("Update Ingredient"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
