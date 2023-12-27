import 'package:fit_allergy_check/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BMIResultPage extends StatefulWidget {
  final String bmiValue;
  final String bmiCategory;
  final String words;

  const BMIResultPage(
      {Key? key,
      required this.bmiValue,
      required this.bmiCategory,
      required this.words})
      : super(key: key);

  @override
  State<BMIResultPage> createState() => _BMIResultPageState();
}

class _BMIResultPageState extends State<BMIResultPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('BMI Result'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DataTable(
                dataRowHeight: 37.0,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                columnSpacing: 16.0,
                columns: [
                  DataColumn(
                      label: Text(
                    'BMI',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                  DataColumn(
                      label: Text(
                    'Weight Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                ],
                rows: [
                  DataRow(
                    cells: [
                      DataCell(Text("Below 18.5")),
                      DataCell(Text("Underweight")),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text("18.5 - 24.9")),
                      DataCell(Text("Normal Weight")),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text("25.0 - 29.9")),
                      DataCell(Text("Overweight")),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text("30.0 - 34.9")),
                      DataCell(Text("Obesity Class I")),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text("35.0 - 39.9")),
                      DataCell(Text("Obesity Class II")),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text("Above 40.0")),
                      DataCell(Text("Obesity Class II")),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 70),
              child: Column(
                children: [
                  SizedBox(height: 30.0,),
                  Text(widget.bmiCategory, style: TextStyle(fontSize: 20),),
                  SizedBox(height: 20,),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: Colors.black,
                        width: 2.0,
                      ),
                    ),
                    child: Text(
                      widget.bmiValue,
                      style: kNumberStyle,
                    ),
                  ),
                  SizedBox(height: 20,),
                  Text(widget.words, style: TextStyle(fontSize: 16),),
                ],
              ),
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
                  child: const Text('CALCULATE AGAIN'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
