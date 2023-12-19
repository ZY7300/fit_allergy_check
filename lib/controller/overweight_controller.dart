import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fit_allergy_check/component/loading_dialog.dart';
import 'package:fit_allergy_check/component/my_dialog.dart';
import 'package:fit_allergy_check/model/overweight.dart';
import 'package:fit_allergy_check/pages/overweight_page.dart';
import 'package:get/get.dart';

class OverweightController extends GetxController {
  var _firestore = FirebaseFirestore.instance;

  RxList<Overweight> overwList = <Overweight>[].obs;

  Future<void> fetchOverweights(String uid) async {
    try {
      LoadingDialog.show();

      final userOverweightQuery = await _firestore
          .collection('UserOverweight')
          .where('uid', isEqualTo: uid)
          .get();

      if (userOverweightQuery.docs.isNotEmpty) {
        final userOverweights = userOverweightQuery.docs.map((doc) {
          final data = doc.data();
          return Overweight(
            overwID: data['overwID'],
            overwName: data['overwName'],
            desc: data['desc'],
            isSelected: data['isSelected'],
            status: data['status'],
          );
        }).toList();
        overwList.assignAll(userOverweights);
      } else {
        overwList.clear();
        final defaultOverweightQuery =
            await _firestore.collection('Overweight').get();

        final defaultOverweights = defaultOverweightQuery.docs.map((doc) {
          final data = doc.data();
          return Overweight(
            overwID: data['overwID'],
            overwName: data['overwName'],
            desc: data['desc'],
            isSelected: data['isSelected'],
            status: data['status'],
          );
        }).toList();
        overwList.assignAll(defaultOverweights);

        updateOverweight(uid, overwList);
      }

      LoadingDialog.dismiss();

      await Get.to(OverweightPage(overweightList: overwList));
    } catch (e) {
      LoadingDialog.dismiss();
      print('Error fetching overweight data: $e');
      Get.dialog(MyDialog(title: "Error", message: "Error fetching overweight data: $e", dialogType: DialogType.error, withBtn: false));
    }
  }

  Future<void> addOverweight(
      String uid, int index, String name, String desc) async {
    try {
      final collection = _firestore.collection('UserOverweight');
      final overweightData = {
        'uid': uid,
        'overwID': index,
        'overwName': name,
        'desc': desc,
        'isSelected': true,
        'status': 1,
      };

      await collection.add(overweightData);
    } catch (e) {
      print('Error adding overweight to UserOverweight: $e');
      Get.dialog(MyDialog(title: "Error", message: "Error adding overweight to database: $e", dialogType: DialogType.error, withBtn: false));
    }
  }

  Future<void> updateOverweight(String uid, List<Overweight> overwList) async {
    try {
      LoadingDialog.show();
      final collection = _firestore.collection('UserOverweight');

      for (final overweight in overwList) {
        final query = await collection
            .where('uid', isEqualTo: uid)
            .where('overwID', isEqualTo: overweight.overwID)
            .get();

        if (query.docs.isNotEmpty) {
          final docId = query.docs.first.id;
          await collection.doc(docId).update({
            'uid': uid,
            'overwID': overweight.overwID,
            'overwName': overweight.overwName,
            'desc': overweight.desc,
            'isSelected': overweight.isSelected,
            'status': overweight.status,
          });
        } else {
          final overweightData = {
            'uid': uid,
            'overwID': overweight.overwID,
            'overwName': overweight.overwName,
            'desc': overweight.desc,
            'isSelected': overweight.isSelected,
            'status': overweight.status,
          };
          await collection.add(overweightData);
        }
      }
      LoadingDialog.dismiss();
    } catch (e) {
      LoadingDialog.dismiss();
      print('Error updating overweight data: $e');
      Get.dialog(MyDialog(title: "Error", message: "Error updating overweight data: $e", dialogType: DialogType.error, withBtn: false));
    }
  }

  Future<void> editOverweight(
      String uid, int id, String name, String desc) async {
    try {
      LoadingDialog.show();
      final collection = _firestore.collection('UserOverweight');

      final query = await collection
          .where('uid', isEqualTo: uid)
          .where('overwID', isEqualTo: id)
          .get();

      if (query.docs.isNotEmpty) {
        final docId = query.docs.first.id;

        await collection.doc(docId).update({
          'overwName': name,
          'desc': desc,
        });

        LoadingDialog.dismiss();

        print("Overweight updated successfully");
      } else {
        LoadingDialog.dismiss();
        print("Overweight ingredient not found");
        Get.dialog(MyDialog(title: "Error", message: "Overweight ingredient not found", dialogType: DialogType.error, withBtn: false));
      }
    } catch (e) {
      LoadingDialog.dismiss();
      Get.dialog(MyDialog(title: "Error", message: e.toString(), dialogType: DialogType.error, withBtn: false));
    }
  }

  Future<void> deleteOverweight(String uid, int id) async {
    try {
      LoadingDialog.show();
      final collection = _firestore.collection('UserOverweight');

      final query = await collection
          .where('uid', isEqualTo: uid)
          .where('overwID', isEqualTo: id)
          .get();

      if (query.docs.isNotEmpty) {
        final docId = query.docs.first.id;

        await collection.doc(docId).delete();

        LoadingDialog.dismiss();

        print("Overweight ingredient deleted successfully");
      } else {
        LoadingDialog.dismiss();
        print("Overweight ingredient not found");
        Get.dialog(MyDialog(title: "Error", message: "Overweight ingredient not found", dialogType: DialogType.error, withBtn: false));
      }
    } catch (e) {
      LoadingDialog.dismiss();
      Get.dialog(MyDialog(title: "Error", message: e.toString(), dialogType: DialogType.error, withBtn: false));
    }
  }
}
