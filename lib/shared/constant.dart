import 'package:flutter/material.dart';

InputDecoration kGetTextFieldDecoration({
  required String hintText,
  required IconData icon,
  String? errorText,
}) {
  return InputDecoration(
    hintText: hintText,
    prefixIcon: Icon(icon, color: Colors.grey[600]),
    errorText: errorText, // Ambil dari parameter

    filled: true,
    fillColor: Colors.grey[100],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: Colors.blue),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: Colors.blue, width: 2),
    ),
    errorStyle: const TextStyle(color: Colors.red),
    errorMaxLines: 2,
  );
}
