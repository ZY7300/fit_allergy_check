import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fit_allergy_check/component/loading_dialog.dart';
import 'package:fit_allergy_check/component/my_dialog.dart';
import 'package:fit_allergy_check/model/allergen.dart';
import 'package:fit_allergy_check/pages/allergen_page.dart';
import 'package:get/get.dart';

class AllergenController extends GetxController {
  var _firestore = FirebaseFirestore.instance;

  RxList<Allergen> allerList = <Allergen>[].obs;

  Future<void> fetchAllergens(String uid) async {
    try {
      LoadingDialog.show();
      final userAllergenQuery = await _firestore
          .collection('UserAllergen')
          .where('uid', isEqualTo: uid)
          .get();

      if (userAllergenQuery.docs.isNotEmpty) {
        final userAllergens = userAllergenQuery.docs.map((doc) {
          final data = doc.data();
          return Allergen(
            allerID: data['allerID'],
            allerName: data['allerName'],
            desc: data['desc'],
            isSelected: data['isSelected'],
            status: data['status'],
          );
        }).toList();
        allerList.assignAll(userAllergens);
      } else {
        allerList.clear();
        final defaultAllergenQuery =
            await _firestore.collection('Allergen').get();

        final defaultAllergens = defaultAllergenQuery.docs.map((doc) {
          final data = doc.data();
          return Allergen(
            allerID: data['allerID'],
            allerName: data['allerName'],
            desc: data['desc'],
            isSelected: data['isSelected'],
            status: data['status'],
          );
        }).toList();
        allerList.assignAll(defaultAllergens);

        updateAllergen(uid, allerList);
      }

      LoadingDialog.dismiss();

      await Get.to(AllergenPage(allergenList: allerList));
    } catch (e) {
      LoadingDialog.dismiss();
      print('Error fetching allergen data: $e');
      Get.dialog(MyDialog(title: "Error", message: "Error fetching allergen data: $e", dialogType: DialogType.error, withBtn: false));
    }
  }

  Future<void> addAllergen(
      String uid, int index, String name, String desc) async {
    try {
      final collection = _firestore.collection('UserAllergen');
      final allergenData = {
        'uid': uid,
        'allerID': index,
        'allerName': name,
        'desc': desc,
        'isSelected': true,
        'status': 1,
      };

      await collection.add(allergenData);
    } catch (e) {
      print('Error adding allergen to UserAllergen: $e');
      Get.dialog(MyDialog(title: "Error", message: "Error adding allergen to database: $e", dialogType: DialogType.error, withBtn: false));
    }
  }

  Future<void> updateAllergen(String uid, List<Allergen> allergenList) async {
    try {
      LoadingDialog.show();
      final collection = _firestore.collection('UserAllergen');

      for (final allergen in allergenList) {
        final query = await collection
            .where('uid', isEqualTo: uid)
            .where('allerID', isEqualTo: allergen.allerID)
            .get();

        if (query.docs.isNotEmpty) {
          final docId = query.docs.first.id;
          await collection.doc(docId).update({
            'uid': uid,
            'allerID': allergen.allerID,
            'allerName': allergen.allerName,
            'desc': allergen.desc,
            'isSelected': allergen.isSelected,
            'status': allergen.status,
          });
        } else {
          final allergenData = {
            'uid': uid,
            'allerID': allergen.allerID,
            'allerName': allergen.allerName,
            'desc': allergen.desc,
            'isSelected': allergen.isSelected,
            'status': allergen.status,
          };
          await collection.add(allergenData);
        }
      }
      LoadingDialog.dismiss();
    } catch (e) {
      LoadingDialog.dismiss();
      print('Error updating allergen data: $e');
      Get.dialog(MyDialog(title: "Error", message: "Error updating allergen data: $e", dialogType: DialogType.error, withBtn: false));
    }
  }

  Future<void> editAllergen(
      String uid, int id, String name, String desc) async {
    try {
      LoadingDialog.show();
      final collection = _firestore.collection('UserAllergen');

      final query = await collection
          .where('uid', isEqualTo: uid)
          .where('allerID', isEqualTo: id)
          .get();

      if (query.docs.isNotEmpty) {
        final docId = query.docs.first.id;

        await collection.doc(docId).update({
          'allerName': name,
          'desc': desc,
        });

        LoadingDialog.dismiss();

        print("Allergen updated successfully");
      } else {
        LoadingDialog.dismiss();
        print("Allergen not found");
        Get.dialog(MyDialog(title: "Error", message: "Allergen not found", dialogType: DialogType.error, withBtn: false));
      }
    } catch (e) {
      LoadingDialog.dismiss();
      Get.dialog(MyDialog(title: "Error", message: e.toString(), dialogType: DialogType.error, withBtn: false));
    }
  }

  Future<void> deleteAllergen(String uid, int id) async {
    try {
      LoadingDialog.show();
      final collection = _firestore.collection('UserAllergen');

      final query = await collection
          .where('uid', isEqualTo: uid)
          .where('allerID', isEqualTo: id)
          .get();

      if (query.docs.isNotEmpty) {
        final docId = query.docs.first.id;

        await collection.doc(docId).delete();

        LoadingDialog.dismiss();

        print("Allergen deleted successfully");
      } else {
        LoadingDialog.dismiss();
        print("Allergen not found");
        Get.dialog(MyDialog(title: "Error", message: "Allergen not found", dialogType: DialogType.error, withBtn: false));
      }
    } catch (e) {
      LoadingDialog.dismiss();
      Get.dialog(MyDialog(title: "Error", message: e.toString(), dialogType: DialogType.error, withBtn: false));
    }
  }
}
