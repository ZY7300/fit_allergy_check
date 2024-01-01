import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:fit_allergy_check/component/loading_dialog.dart';
import 'package:fit_allergy_check/component/my_dialog.dart';
import 'package:fit_allergy_check/controller/auth_controller.dart';
import 'package:fit_allergy_check/controller/calo_phos_sod_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:tflite/tflite.dart';

class CheckCaloPhosSodPage extends StatefulWidget {
  final DateTime date;

  const CheckCaloPhosSodPage({Key? key, required this.date}) : super(key: key);

  @override
  State<CheckCaloPhosSodPage> createState() => _CheckCaloPhosSodPageState();
}

class _CheckCaloPhosSodPageState extends State<CheckCaloPhosSodPage> {
  final authController = Get.put(AuthController());
  final caloPhosSodController = Get.put(CaloPhosSodController());

  String uid = "";

  int tempCalo = 0;
  int tempPhos = 0;
  int tempSod = 0;

  int caloLimit = 2200;
  int phosLimit = 4000;
  int sodLimit = 2300;

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
      tempCalo = caloPhosSodController.totalCalories.value +
          foodMap[_output![0]['label'].split(' ').sublist(1).join(' ')]![
              'calorie']!;
      tempPhos = caloPhosSodController.totalPhospahte.value +
          foodMap[_output![0]['label'].split(' ').sublist(1).join(' ')]![
              'phosphate']!;
      tempSod = caloPhosSodController.totalSodium.value +
          foodMap[_output![0]['label'].split(' ').sublist(1).join(' ')]![
              'sodium']!;
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
    uid = authController.uid.value;
    loadModel().then((value) {
      caloPhosSodController.fetchCalories(uid).then((_) {
        setState(() {});
      });
      caloPhosSodController.fetchPhosphate(uid).then((_) {
        setState(() {});
      });
      caloPhosSodController.fetchSodium(uid).then((_) {
        setState(() {});
      });
    });
  }

  Map<String, Map<String, int>> foodMap = {
    'Satay': {'calorie': 36, 'phosphate': 161, 'sodium': 110},
    'Roti Canai': {'calorie': 209, 'phosphate': 123, 'sodium': 366},
    'Nasi Lemak': {'calorie': 398, 'phosphate': 154, 'sodium': 2300},
    'Laksa': {'calorie': 432, 'phosphate': 216, 'sodium': 712},
    'Fried Rice': {'calorie': 163, 'phosphate': 181, 'sodium': 396},
    'Fried Noodle': {'calorie': 460, 'phosphate': 199, 'sodium': 500},
    'Waffle': {'calorie': 291, 'phosphate': 200, 'sodium': 511},
    // 'Apple Pie': 237,
    // 'Bibimbap': 634,
    // 'Biscuit': 353,
    // 'Bread': 365,
    // 'Burger': 295,
    // 'Carrot Cake': 415,
    // 'Cheese Cake': 321,
    // 'Chicken Curry': 110,
    // 'Chicken Wing': 203,
    // 'Chocolate': 546,
    // 'Chocolate Cake': 371,
    // 'Churros': 946,
    // 'Coffee': 5,
    // 'Cup Cake': 305,
    // 'Donut': 230,
    // 'Dumpling': 205,
    // 'Fish and Chip': 861,
    // 'French Fries': 312,
    // 'French Toast': 229,
    // 'Fried Calamari': 175,
    // 'Fried Chicken': 246,
    // 'Fried Noodle': 460,
    // 'Fried Rice': 163,
    // 'Frozen Yogurt': 159,
    // 'Garlic Bread': 350,
    // 'Grilled Cheese Sandwich': 366,
    // 'Grilled Salmon': 175,
    // 'Gyoza': 57,
    // 'Hotdog': 290,
    // 'Ice Cream': 207,
    // 'Kaya Toast': 163,
    // 'Laksa': 432,
    // 'Lasagna': 135,
    // 'Macaron': 404,
    // 'Macaroni': 371,
    // 'Miso Soup': 40,
    // 'Mixed Rice': 150,
    // 'Mussel': 172,
    // 'Nasi Lemak': 398,
    // 'Omelette': 154,
    // 'Onion Ring': 411,
    // 'Oyster': 199,
    // 'Pancake': 227,
    // 'Peking Duck': 400,
    // 'Pizza': 266,
    // 'Popiah': 190,
    // 'Pork Chop': 231,
    // 'Ramen': 436,
    // 'Red Velvet Cake': 293,
    // 'Roti Canai': 301,
    // 'Salad': 333,
    // 'Sashimi': 110,
    // 'Satay': 36,
    // 'Scallop': 137,
    // 'Seaweed Salad': 70,
    // 'Spaghetti Bolognese': 297,
    // 'Spaghetti Carbonara': 307,
    // 'Spring Roll': 154,
    // 'Steak': 271,
    // 'Strawberry Cake': 190,
    // 'Sushi': 306,
    // 'Takoyaki': 70,
    // 'Tiramisu': 492,
    // 'Waffle': 291,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calories + Phosphate + Sodium',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: _output != null && _output!.isNotEmpty
          ? SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${widget.date.day}-${widget.date.month}-${widget.date.year}",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.menu_book),
                        onPressed: () async {
                          await generatePDF();
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Text("TOTAL"),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Center(child: Text("CURRENT")),
                      ),
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: Text(
                            "BALANCE",
                            style: TextStyle(color: Colors.blue.shade900),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: Text(
                            "LIMIT",
                            style: TextStyle(color: Colors.red.shade900),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Text("Calories: "),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Obx(() {
                          Color textColor =
                              caloPhosSodController.totalCalories > caloLimit
                                  ? Colors.red
                                  : Colors.black.withOpacity(0.7);
                          return Center(
                            child: Text(
                              tempCalo >
                                      caloPhosSodController.totalCalories.value
                                  ? "$tempCalo"
                                  : "${caloPhosSodController.totalCalories}",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: textColor),
                            ),
                          );
                        }),
                      ),
                      Expanded(
                        flex: 3,
                        child: Obx(() {
                          int bal;
                          tempCalo > caloPhosSodController.totalCalories.value
                              ? bal = caloLimit - tempCalo
                              : bal = caloLimit -
                                  caloPhosSodController.totalCalories.value;
                          Color textColor = bal.isNegative
                              ? Colors.red
                              : Colors.blue.shade900;
                          return Center(
                            child: Text(
                              bal.toString(),
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: textColor),
                            ),
                          );
                        }),
                      ),
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: Text(
                            caloLimit.toString(),
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.red.shade900),
                          ),
                        ),
                      ),
                      // Text(" calories"),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Text("Phosphate: "),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Obx(() {
                          Color textColor =
                              caloPhosSodController.totalPhospahte > phosLimit
                                  ? Colors.red
                                  : Colors.black.withOpacity(0.7);
                          return Center(
                            child: Text(
                              tempPhos >
                                      caloPhosSodController.totalPhospahte.value
                                  ? "$tempPhos"
                                  : "${caloPhosSodController.totalPhospahte}",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: textColor),
                            ),
                          );
                        }),
                      ),
                      Expanded(
                        flex: 3,
                        child: Obx(() {
                          int bal;
                          tempPhos > caloPhosSodController.totalPhospahte.value
                              ? bal = phosLimit - tempPhos
                              : bal = phosLimit -
                              caloPhosSodController.totalPhospahte.value;
                          Color textColor = bal.isNegative
                              ? Colors.red
                              : Colors.blue.shade900;
                          return Center(
                            child: Text(
                              bal.toString(),
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: textColor),
                            ),
                          );
                        }),
                      ),
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: Text(
                            phosLimit.toString(),
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.red.shade900),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Text("Sodium: "),
                          )),
                      Expanded(
                        flex: 3,
                        child: Obx(() {
                          Color textColor =
                              caloPhosSodController.totalSodium > sodLimit
                                  ? Colors.red
                                  : Colors.black.withOpacity(0.7);
                          return Center(
                            child: Text(
                              tempSod > caloPhosSodController.totalSodium.value
                                  ? "$tempSod"
                                  : "${caloPhosSodController.totalSodium}",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: textColor),
                            ),
                          );
                        }),
                      ),
                      Expanded(
                        flex: 3,
                        child: Obx(() {
                          int bal;
                          tempSod > caloPhosSodController.totalSodium.value
                              ? bal = sodLimit - tempSod
                              : bal = sodLimit -
                              caloPhosSodController.totalSodium.value;
                          Color textColor = bal.isNegative
                              ? Colors.red
                              : Colors.blue.shade900;
                          return Center(
                            child: Text(
                              bal.toString(),
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: textColor),
                            ),
                          );
                        }),
                      ),
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: Text(
                            sodLimit.toString(),
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.red.shade900),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Container(
                      height: 300,
                      width: MediaQuery.of(context).size.width,
                      child: Image.file(_image!),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Center(
                      child: Column(
                        children: [
                          if (foodMap.containsKey(_output![0]['label']
                              .split(' ')
                              .sublist(1)
                              .join(' ')))
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(dataRowHeight: 37.0, columns: [
                                DataColumn(
                                    label: Text(
                                        _output![0]['label']
                                            .split(' ')
                                            .sublist(1)
                                            .join(' '),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20))),
                                DataColumn(label: Text("")),
                              ], rows: [
                                DataRow(
                                  cells: [
                                    DataCell(Text("Calories")),
                                    DataCell(Text(
                                        "${foodMap[_output![0]['label'].split(' ').sublist(1).join(' ')]!['calorie']}")),
                                  ],
                                ),
                                DataRow(
                                  cells: [
                                    DataCell(Text("Phosphate")),
                                    DataCell(Text(
                                        "${foodMap[_output![0]['label'].split(' ').sublist(1).join(' ')]!['phosphate']}")),
                                  ],
                                ),
                                DataRow(
                                  cells: [
                                    DataCell(Text("Sodium")),
                                    DataCell(Text(
                                        "${foodMap[_output![0]['label'].split(' ').sublist(1).join(' ')]!['sodium']}")),
                                  ],
                                ),
                              ]),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _output = null;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(100, 40),
                        ),
                        child: const Text('SCAN AGAIN'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            LoadingDialog.show();
                            await caloPhosSodController.addCalories(
                              uid,
                              _output![0]['label']
                                  .split(' ')
                                  .sublist(1)
                                  .join(' '),
                              foodMap[_output![0]['label']
                                  .split(' ')
                                  .sublist(1)
                                  .join(' ')]!['calorie']!,
                            );
                            await caloPhosSodController.addPhosphate(
                              uid,
                              _output![0]['label']
                                  .split(' ')
                                  .sublist(1)
                                  .join(' '),
                              foodMap[_output![0]['label']
                                  .split(' ')
                                  .sublist(1)
                                  .join(' ')]!['phosphate']!,
                            );
                            await caloPhosSodController.addSodium(
                              uid,
                              _output![0]['label']
                                  .split(' ')
                                  .sublist(1)
                                  .join(' '),
                              foodMap[_output![0]['label']
                                  .split(' ')
                                  .sublist(1)
                                  .join(' ')]!['sodium']!,
                            );
                            LoadingDialog.dismiss();
                            await Get.dialog(MyDialog(
                                title: "Added",
                                message: "Successfully",
                                dialogType: DialogType.success,
                                withBtn: false));

                            setState(() {
                              _output = null;
                            });
                          } catch (e) {
                            LoadingDialog.dismiss();
                            print('Error: $e');
                            Get.dialog(MyDialog(
                                title: "Error",
                                message: e.toString(),
                                dialogType: DialogType.error,
                                withBtn: false));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(100, 40),
                        ),
                        child: const Text('ADD'),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${widget.date.day}-${widget.date.month}-${widget.date.year}",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.menu_book),
                      onPressed: () async {
                        await generatePDF();
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text("TOTAL"),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Center(child: Text("CURRENT")),
                    ),
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Text(
                          "BALANCE",
                          style: TextStyle(color: Colors.blue.shade900),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Text(
                          "LIMIT",
                          style: TextStyle(color: Colors.red.shade900),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text("Calories: "),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Obx(() {
                        Color textColor =
                            caloPhosSodController.totalCalories > caloLimit
                                ? Colors.red
                                : Colors.black.withOpacity(0.7);
                        return Center(
                          child: Text(
                            "${caloPhosSodController.totalCalories}",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: textColor),
                          ),
                        );
                      }),
                    ),
                    Expanded(
                      flex: 3,
                      child: Obx(() {
                        int bal = caloLimit -
                            caloPhosSodController.totalCalories.value;
                        Color textColor =
                            bal.isNegative ? Colors.red : Colors.blue.shade900;
                        return Center(
                          child: Text(
                            bal.toString(),
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: textColor),
                          ),
                        );
                      }),
                    ),
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Text(
                          caloLimit.toString(),
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.red.shade900),
                        ),
                      ),
                    ),
                    // Text(" calories"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text("Phosphate: "),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Obx(() {
                        Color textColor =
                            caloPhosSodController.totalPhospahte > phosLimit
                                ? Colors.red
                                : Colors.black.withOpacity(0.7);
                        return Center(
                          child: Text(
                            "${caloPhosSodController.totalPhospahte}",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: textColor),
                          ),
                        );
                      }),
                    ),
                    Expanded(
                      flex: 3,
                      child: Obx(() {
                        int bal = phosLimit -
                            caloPhosSodController.totalPhospahte.value;
                        Color textColor =
                            bal.isNegative ? Colors.red : Colors.blue.shade900;
                        return Center(
                          child: Text(
                            bal.toString(),
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: textColor),
                          ),
                        );
                      }),
                    ),
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Text(
                          phosLimit.toString(),
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.red.shade900),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Text("Sodium: "),
                        )),
                    Expanded(
                      flex: 3,
                      child: Obx(() {
                        Color textColor =
                            caloPhosSodController.totalSodium > sodLimit
                                ? Colors.red
                                : Colors.black.withOpacity(0.7);
                        return Center(
                          child: Text(
                            "${caloPhosSodController.totalSodium}",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: textColor),
                          ),
                        );
                      }),
                    ),
                    Expanded(
                      flex: 3,
                      child: Obx(() {
                        int bal =
                            sodLimit - caloPhosSodController.totalSodium.value;
                        Color textColor =
                            bal.isNegative ? Colors.red : Colors.blue.shade900;
                        return Center(
                          child: Text(
                            bal.toString(),
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: textColor),
                          ),
                        );
                      }),
                    ),
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Text(
                          sodLimit.toString(),
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.red.shade900),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(flex: 1, child: Container()),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      takephoto();
                    },
                    child: SizedBox.expand(
                      child: Card(
                        color: Colors.grey[350],
                        child: Center(
                            child: Text(
                          "Take Photo",
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 20),
                        )),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      pickImage();
                    },
                    child: SizedBox.expand(
                      child: Card(
                        color: Colors.grey[350],
                        child: Center(
                            child: Text(
                          "Choose from Gallery",
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 20),
                        )),
                      ),
                    ),
                  ),
                ),
                Expanded(flex: 2, child: Container()),
              ],
            ),
    );
  }

  takephoto() async {
    var status = await Permission.camera.status;

    if (status.isDenied) {
      await Permission.camera.request();
      status = await Permission.camera.status;
    }

    if (status.isGranted) {
      var image = await picker.pickImage(source: ImageSource.camera);

      if (image == null) return null;

      setState(() {
        _image = File(image.path);
      });

      await classifyImage(_image!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Camera permission is required. Please enable it in your device settings.'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () {
              openAppSettings();
            },
          ),
        ),
      );
    }
  }

  pickImage() async {
    var image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return null;

    setState(() {
      _image = File(image.path);
    });

    await classifyImage(_image!);
  }

  Future<void> generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  "${widget.date.day}-${widget.date.month}-${widget.date.year}",
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  "Food List",
                  style: pw.TextStyle(
                      fontSize: 15, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text("Food Name"),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text("Calories"),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text("Phosphate"),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text("Sodium"),
                        ),
                      ],
                    ),
                    for (int i = 0;
                        i < caloPhosSodController.caloList.length;
                        i++)
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child:
                                pw.Text(caloPhosSodController.caloList[i].name),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                                "${caloPhosSodController.caloList[i].calories}"),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                                "${caloPhosSodController.phosList[i].phosphate}"),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                                "${caloPhosSodController.sodList[i].sodium}"),
                          ),
                        ],
                      ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text("Total",
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                              "${caloPhosSodController.totalCalories.value}",
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                              "${caloPhosSodController.totalPhospahte.value}",
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                              "${caloPhosSodController.totalSodium.value}",
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    final tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;
    final pdfPath =
        '$tempPath/food_list_${widget.date.day}-${widget.date.month}-${widget.date.year}.pdf';
    final pdfFile = File(pdfPath);
    await pdfFile.writeAsBytes(await pdf.save());

    OpenFile.open(pdfPath);
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}
