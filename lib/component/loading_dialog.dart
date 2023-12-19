import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingDialog {

  static void show({String? message}) {
    Get.dialog(WillPopScope(
      onWillPop: () => Future.value(false),
      child: Align(
        alignment: Alignment.center,
        child: Container(
          margin: const EdgeInsets.all(50.0),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
          //padding: const EdgeInsets.all(16),
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                  ),
                  height: 40.0,
                  width: 40.0,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20.0),
                ),
                Material(
                  child: Text(
                    message ?? "Loading...",
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.black87,
                      fontStyle: FontStyle.normal,
                      decoration: TextDecoration.none,
                      fontFamily: "Roboto",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ), barrierDismissible: false);
  }

  static void dismiss() {
    if (Get.isDialogOpen != null) {
      Get.until((_) => !Get.isDialogOpen!);
    }
  }
}