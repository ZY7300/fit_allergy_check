import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fit_allergy_check/component/loading_dialog.dart';
import 'package:fit_allergy_check/component/my_dialog.dart';
import 'package:fit_allergy_check/model/underweight.dart';
import 'package:fit_allergy_check/pages/underweight_page.dart';
import 'package:get/get.dart';

class UnderweightController extends GetxController {
  var _firestore = FirebaseFirestore.instance;

  RxList<Underweight> underwList = <Underweight>[].obs;

  Future<void> fetchUnderweights(String uid) async {
    try {
      LoadingDialog.show();
      final userUnderweightQuery = await _firestore
          .collection('UserUnderweight')
          .where('uid', isEqualTo: uid)
          .get();

      if (userUnderweightQuery.docs.isNotEmpty) {
        final userUnderweights = userUnderweightQuery.docs.map((doc) {
          final data = doc.data();
          return Underweight(
            underwID: data['underwID'],
            underwName: data['underwName'],
            desc: data['desc'],
            isSelected: data['isSelected'],
            status: data['status'],
          );
        }).toList();
        underwList.assignAll(userUnderweights);
      } else {
        underwList.clear();
        final defaultUnderweightQuery =
            await _firestore.collection('Underweight').get();

        final defaultUnderweights = defaultUnderweightQuery.docs.map((doc) {
          final data = doc.data();
          return Underweight(
            underwID: data['underwID'],
            underwName: data['underwName'],
            desc: data['desc'],
            isSelected: data['isSelected'],
            status: data['status'],
          );
        }).toList();
        underwList.assignAll(defaultUnderweights);

        updateUnderweight(uid, underwList);
      }

      LoadingDialog.dismiss();

      await Get.to(UnderweightPage(underweightList: underwList));
    } catch (e) {
      LoadingDialog.dismiss();
      print('Error fetching underweight data: $e');
      Get.dialog(MyDialog(title: "Error", message: "Error fetching underweight data: $e", dialogType: DialogType.error, withBtn: false));
    }
  }

  Future<void> addUnderweight(
      String uid, int index, String name, String desc) async {
    try {
      final collection = _firestore.collection('UserUnderweight');
      final underweightData = {
        'uid': uid,
        'underwID': index,
        'underwName': name,
        'desc': desc,
        'isSelected': true,
        'status': 1,
      };

      await collection.add(underweightData);
    } catch (e) {
      print('Error adding underweight to UserUnderweight: $e');
      Get.dialog(MyDialog(title: "Error", message: "Error adding underweight to database: $e", dialogType: DialogType.error, withBtn: false));
    }
  }

  Future<void> updateUnderweight(
      String uid, List<Underweight> underwList) async {
    try {
      LoadingDialog.show();
      final collection = _firestore.collection('UserUnderweight');

      for (final underweight in underwList) {
        final query = await collection
            .where('uid', isEqualTo: uid)
            .where('underwID', isEqualTo: underweight.underwID)
            .get();

        if (query.docs.isNotEmpty) {
          final docId = query.docs.first.id;
          await collection.doc(docId).update({
            'uid': uid,
            'underwID': underweight.underwID,
            'underwName': underweight.underwName,
            'desc': underweight.desc,
            'isSelected': underweight.isSelected,
            'status': underweight.status,
          });
        } else {
          final underweightData = {
            'uid': uid,
            'underwID': underweight.underwID,
            'underwName': underweight.underwName,
            'desc': underweight.desc,
            'isSelected': underweight.isSelected,
            'status': underweight.status,
          };
          await collection.add(underweightData);
        }
      }
      LoadingDialog.dismiss();
    } catch (e) {
      LoadingDialog.dismiss();
      print('Error updating underweight data: $e');
      Get.dialog(MyDialog(title: "Error", message: "Error updating underweight data: $e", dialogType: DialogType.error, withBtn: false));
    }
  }

  Future<void> editUnderweight(
      String uid, int id, String name, String desc) async {
    try {
      LoadingDialog.show();
      final collection = _firestore.collection('UserUnderweight');

      final query = await collection
          .where('uid', isEqualTo: uid)
          .where('underwID', isEqualTo: id)
          .get();

      if (query.docs.isNotEmpty) {
        final docId = query.docs.first.id;

        await collection.doc(docId).update({
          'underwName': name,
          'desc': desc,
        });

        LoadingDialog.dismiss();

        print("Underweight updated successfully");
      } else {
        LoadingDialog.dismiss();
        print("Underweight ingredient not found");
        Get.dialog(MyDialog(title: "Error", message: "Underweight ingredient not found", dialogType: DialogType.error, withBtn: false));
      }
    } catch (e) {
      LoadingDialog.dismiss();
      Get.dialog(MyDialog(title: "Error", message: e.toString(), dialogType: DialogType.error, withBtn: false));
    }
  }

  Future<void> deleteUnderweight(String uid, int id) async {
    try {
      LoadingDialog.show();
      final collection = _firestore.collection('UserUnderweight');

      final query = await collection
          .where('uid', isEqualTo: uid)
          .where('underwID', isEqualTo: id)
          .get();

      if (query.docs.isNotEmpty) {
        final docId = query.docs.first.id;

        await collection.doc(docId).delete();

        LoadingDialog.dismiss();

        print("Underweight ingredient deleted successfully");
      } else {
        LoadingDialog.dismiss();
        print("Underweight ingredient not found");
        Get.dialog(MyDialog(title: "Error", message: "Underweight ingredient not found", dialogType: DialogType.error, withBtn: false));
      }
    } catch (e) {
      LoadingDialog.dismiss();
      Get.dialog(MyDialog(title: "Error", message: e.toString(), dialogType: DialogType.error, withBtn: false));
    }
  }
}
