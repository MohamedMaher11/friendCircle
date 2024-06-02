import 'package:flutter/material.dart';

Widget myfun(
  TextEditingController controller,
  String labeltext,
  Icon prefixIcon,
  bool obscureText, {
  String? Function(String?)? validator,
  int? maxLines,
  TextInputType? keyboardType,
  Function? onTap,
}) {
  return TextFormField(
    controller: controller,
    obscureText: obscureText,
    validator: validator,
    maxLines: maxLines ?? 1,
    keyboardType: keyboardType ?? TextInputType.text,
    onTap: onTap as void Function()? ?? null,
    style: TextStyle(
      fontSize: 16.0,
      color: Colors.black,
    ),
    decoration: InputDecoration(
      labelText: labeltext,
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: Colors.grey[200],
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          color: Colors.purple,
          width: 2.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          color: Colors.red,
          width: 2.0,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          color: Colors.red,
          width: 2.0,
        ),
      ),
      errorStyle: TextStyle(
        color: Colors.red,
      ),
      labelStyle: TextStyle(
        color: Colors.grey[600],
        fontSize: 16.0,
      ),
      hintStyle: TextStyle(
        color: Colors.grey[400],
      ),
    ),
  );
}
