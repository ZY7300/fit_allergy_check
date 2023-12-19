import 'package:fit_allergy_check/model/allergen.dart';
import 'package:fit_allergy_check/model/overweight.dart';
import 'package:fit_allergy_check/model/underweight.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResultPage extends StatefulWidget {
  final String result;
  final List<Allergen>? allergenLists;
  final List<Underweight>? underwLists;
  final List<Overweight>? overwLists;

  const ResultPage(
      {Key? key,
      required this.result,
      this.allergenLists,
      this.underwLists,
      this.overwLists})
      : super(key: key);

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool match = false;
  List<String> matchList = [];

  @override
  void initState() {
    super.initState();

    print(widget.result);

    if (widget.allergenLists != null) {
      for (var allergen in widget.allergenLists!) {
        if (allergen.isSelected == true) {
          if (widget.result
              .toUpperCase()
              .contains(allergen.allerName.toUpperCase())) {
            match = true;
            matchList.add(allergen.allerName);
          }
        }
      }
    }

    if (widget.underwLists != null) {
      for (var underweight in widget.underwLists!) {
        if (underweight.isSelected == true) {
          if (widget.result
              .toUpperCase()
              .contains(underweight.underwName.toUpperCase())) {
            match = true;
            matchList.add(underweight.underwName);
          }
        }
      }
    }

    if (widget.overwLists != null) {
      for (var overweight in widget.overwLists!) {
        if (overweight.isSelected == true) {
          if (widget.result
              .toUpperCase()
              .contains(overweight.overwName.toUpperCase())) {
            match = true;
            matchList.add(overweight.overwName);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        leading: Container(),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            !match
                ? const Text(
                  'CAN CONSUME',
                  style: TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                )
                : const Text(
                    'CAN NOT COMSUME',
                    style: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
            const SizedBox(
              height: 15.0,
            ),
            widget.allergenLists != null ? Text(!match
                ? 'This food does not contains any allergen ingredient'
                : 'This food contains ${matchList.toString()}') : Container(),
            const SizedBox(
              height: 15.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Get.offAllNamed('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 40),
                  ),
                  child: const Text('Home'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 40),
                  ),
                  child: const Text('TEST AGAIN'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
