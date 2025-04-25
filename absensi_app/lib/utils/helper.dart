import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

/// Menampilkan toast umum
void showToast(String message, {Color bgColor = Colors.black}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: bgColor,
    textColor: Colors.white,
    fontSize: 14,
  );
}

/// Toast sukses
void showSuccessToast(String message) =>
    showToast(message, bgColor: Colors.green);

/// Toast error
void showErrorToast(String message) => showToast(message, bgColor: Colors.red);

/// Cek apakah string kosong
bool isEmpty(String? text) {
  return text == null || text.trim().isEmpty;
}

/// Validasi format email umum
bool isValidEmail(String email) {
  final regex = RegExp(
    r"^[a-zA-Z0-9]+([._]?[a-zA-Z0-9]+)*@[a-zA-Z0-9-]+\.[a-zA-Z]{2,}$",
  );
  return regex.hasMatch(email);
}
