import 'package:flutter/material.dart';

Widget inputField(String text, IconData icon, bool isPassword, TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.only(left: 20, right: 20),
    child: TextField(
      controller: controller,
      obscureText: isPassword,
      enableSuggestions: !isPassword,
      autocorrect: !isPassword,
      cursorColor: Colors.black.withOpacity(0.5),
      style: TextStyle(color: Colors.black.withOpacity(0.9)),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.black.withOpacity(0.5),),
        labelText: text,
        labelStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
        hintText: text,
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: Colors.white.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(width: 0, style: BorderStyle.solid),
        ),
      ),
      keyboardType: isPassword ? TextInputType.visiblePassword : TextInputType.emailAddress,
    ),
  );
}