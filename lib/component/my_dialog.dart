import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyDialog extends StatefulWidget {
  final String title;
  final String message;
  final DialogType dialogType;
  final bool withBtn;
  final VoidCallback? okPressed;
  final VoidCallback? cancelPressed;
  final String? okText;
  final String? cancelText;

  const MyDialog(
      {Key? key,
      required this.title,
      required this.message,
      required this.dialogType,
      required this.withBtn,
      this.okPressed,
      this.cancelPressed,
      this.okText,
      this.cancelText})
      : super(key: key);

  @override
  State<MyDialog> createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  void initState() {
    super.initState();
    _showDialog();
  }

  void _showDialog() async {
    await Future.delayed(Duration.zero);

    AwesomeDialog(
      context: context,
      dialogType: widget.dialogType,
      animType: AnimType.bottomSlide,
      title: widget.title,
      desc: widget.message,
      btnOkOnPress: widget.okPressed,
      btnCancelOnPress: widget.cancelPressed,
      btnOkText: widget.okText,
      btnCancelText: widget.cancelText,
      dismissOnBackKeyPress: false,
      dismissOnTouchOutside: false,
    ).show();

    if (!widget.withBtn) {
      const duration = Duration(seconds: 3);

      Future.delayed(duration, () {
        Get.back();
        Get.back();
      });
    }
  }
}
