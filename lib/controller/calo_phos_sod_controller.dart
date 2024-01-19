  import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fit_allergy_check/component/my_dialog.dart';
  import 'package:fit_allergy_check/model/calories.dart';
import 'package:fit_allergy_check/model/phosphate.dart';
  import 'package:get/get.dart';

import '../model/sodium.dart';

  class CaloPhosSodController extends GetxController {
    var _firestore = FirebaseFirestore.instance;

    RxList<Calories> caloList = <Calories>[].obs;
    RxList<Phosphate> phosList = <Phosphate>[].obs;
    RxList<Sodium> sodList = <Sodium>[].obs;
    RxInt totalCalories = 0.obs;
    RxInt totalPhospahte = 0.obs;
    RxInt totalSodium = 0.obs;
    DateTime currentDate = DateTime.now();
    String date = "";

    Future<void> fetchCalories(String uid, String selectedDate) async {
      try {
        final calories = await _firestore
            .collection('Calories')
            .where('uid', isEqualTo: uid)
            .where('date', isEqualTo: selectedDate)
            .get();

        final userCalories = calories.docs.map((doc) {
          final data = doc.data();
          return Calories(
            name: data['name'],
            calories: data['calories'],
          );
        }).toList();

        caloList.assignAll(userCalories);
        totalCalories.value = calcTotalCalories();

      } catch (e) {
        print('Error fetching calories: $e');
        Get.dialog(MyDialog(title: "Error", message: "Error fetching calories: $e", dialogType: DialogType.error, withBtn: false));
      }
    }

    Future<void> addCalories(String uid, String name, int calories) async {
      try {
        date = "${currentDate.year}-${currentDate.month}-${currentDate.day}";

        final collection = _firestore.collection('Calories');
        final caloData = {
          'uid': uid,
          'date': date,
          'name': name,
          'calories': calories,
        };

        caloList.add(Calories(name: name, calories: calories));

        await collection.add(caloData);
        totalCalories.value = calcTotalCalories();

        print(totalCalories.value);
      } catch (e) {
        print('Error adding daily calories to Calories: $e');
        Get.dialog(MyDialog(title: "Error", message: "Error adding daily calories to database: $e", dialogType: DialogType.error, withBtn: false));
      }
    }

    int calcTotalCalories() {
      int sum = 0;
      for (Calories calories in caloList) {
        sum += calories.calories;
      }
      return sum;
    }

    Future<void> fetchPhosphate(String uid, String selectedDate) async {
      try {
        final phosphate = await _firestore
            .collection('Phosphate')
            .where('uid', isEqualTo: uid)
            .where('date', isEqualTo: selectedDate)
            .get();

        final userPhosphate = phosphate.docs.map((doc) {
          final data = doc.data();
          return Phosphate(
            name: data['name'],
            phosphate: data['phosphate'],
          );
        }).toList();

        phosList.assignAll(userPhosphate);
        totalPhospahte.value = calcTotalPhosphate();

      } catch (e) {
        print('Error fetching phosphate: $e');
        Get.dialog(MyDialog(title: "Error", message: "Error fetching phosphate: $e", dialogType: DialogType.error, withBtn: false));
      }
    }

    Future<void> addPhosphate(String uid, String name, int phosphate) async {
      try {
        date = "${currentDate.year}-${currentDate.month}-${currentDate.day}";

        final collection = _firestore.collection('Phosphate');
        final phosData = {
          'uid': uid,
          'date': date,
          'name': name,
          'phosphate': phosphate,
        };

        phosList.add(Phosphate(name: name, phosphate: phosphate));

        await collection.add(phosData);
        totalPhospahte.value = calcTotalPhosphate();

        print(totalPhospahte.value);
      } catch (e) {
        print('Error adding daily phosphate to Phosphate: $e');
        Get.dialog(MyDialog(title: "Error", message: "Error adding daily phosphate to database: $e", dialogType: DialogType.error, withBtn: false));
      }
    }

    int calcTotalPhosphate() {
      int sum = 0;
      for (Phosphate phosphate in phosList) {
        sum += phosphate.phosphate;
      }
      return sum;
    }

    Future<void> fetchSodium(String uid, String selectedDate) async {
      try {
        final sodium = await _firestore
            .collection('Sodium')
            .where('uid', isEqualTo: uid)
            .where('date', isEqualTo: selectedDate)
            .get();

        final userSodium = sodium.docs.map((doc) {
          final data = doc.data();
          return Sodium(
            name: data['name'],
            sodium: data['sodium'],
          );
        }).toList();

        sodList.assignAll(userSodium);
        totalSodium.value = calcTotalSodium();

      } catch (e) {
        print('Error fetching sodium: $e');
        Get.dialog(MyDialog(title: "Error", message: "Error fetching sodium: $e", dialogType: DialogType.error, withBtn: false));
      }
    }

    Future<void> addSodium(String uid, String name, int sodium) async {
      try {
        date = "${currentDate.year}-${currentDate.month}-${currentDate.day}";

        final collection = _firestore.collection('Sodium');
        final sodData = {
          'uid': uid,
          'date': date,
          'name': name,
          'sodium': sodium,
        };

        sodList.add(Sodium(name: name, sodium: sodium));

        await collection.add(sodData);
        totalSodium.value = calcTotalSodium();

        print(totalSodium.value);
      } catch (e) {
        print('Error adding daily sodium to Sodium: $e');
        Get.dialog(MyDialog(title: "Error", message: "Error adding daily sodium to database: $e", dialogType: DialogType.error, withBtn: false));
      }
    }

    int calcTotalSodium() {
      int sum = 0;
      for (Sodium sodium in sodList) {
        sum += sodium.sodium;
      }
      return sum;
    }

    Future<Map<String, dynamic>> fetchLimits(String uid) async {
      try {
        DocumentSnapshot limitSnapshot =
        await FirebaseFirestore.instance.collection('Limit').doc(uid).get();

        if (limitSnapshot.exists) {
          Map<String, dynamic> limits = {
            'caloLimit': limitSnapshot['caloLimit'] ?? 2200,
            'phosLimit': limitSnapshot['phosLimit'] ?? 4000,
            'sodLimit': limitSnapshot['sodLimit'] ?? 2300,
          };

          return limits;
        }

        return {};
      } catch (e) {
        print('Error fetching limits: $e');
        Get.dialog(MyDialog(title: "Error", message: "Error fetching limits", dialogType: DialogType.error, withBtn: false));
        return {};
      }
    }

    Future<void> updateLimits(String uid, int caloLimit, int phosLimit, int sodLimit) async {
      try {
        await FirebaseFirestore.instance.collection('Limit').doc(uid).set({
          'caloLimit': caloLimit,
          'phosLimit': phosLimit,
          'sodLimit': sodLimit,
        }, SetOptions(merge: true));
      } catch (e) {
        print('Error updating limits: $e');
        Get.dialog(MyDialog(title: "Error", message: "Error updating limits", dialogType: DialogType.error, withBtn: false));
      }
    }
  }
