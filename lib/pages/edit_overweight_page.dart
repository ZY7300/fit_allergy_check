import 'package:fit_allergy_check/controller/auth_controller.dart';
import 'package:fit_allergy_check/controller/overweight_controller.dart';
import 'package:fit_allergy_check/model/overweight.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditOverweightPage extends StatefulWidget {
  final Overweight overweight;

  const EditOverweightPage({Key? key, required this.overweight})
      : super(key: key);

  @override
  State<EditOverweightPage> createState() => _EditOverweightPageState();
}

class _EditOverweightPageState extends State<EditOverweightPage> {
  String uid = "";

  TextEditingController _overwNameController = TextEditingController();
  TextEditingController _descController = TextEditingController();

  final authController = Get.find<AuthController>();
  final overwController = Get.find<OverweightController>();

  @override
  void initState() {
    super.initState();

    _overwNameController.text = widget.overweight.overwName;
    _descController.text = widget.overweight.desc;

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
            child: Center(child: Text(widget.overweight.overwID.toString())),
          ),
          Padding(
            padding: EdgeInsets.all(15.0),
            child: TextField(
              controller: _overwNameController,
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
                  await overwController.editOverweight(
                      uid,
                      widget.overweight.overwID,
                      _overwNameController.text,
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
