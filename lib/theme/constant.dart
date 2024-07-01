import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

const Color appBarColor = Color.fromARGB(255, 45, 50, 59);
const Color textColor = Color.fromARGB(255, 215, 215, 215);
const Color textPaddingColor = Color.fromARGB(255, 45, 50, 59);
const Color canvasColor = Color(0xFF282C34);
const Color buttonColor = Color.fromARGB(255, 108, 131, 213);
const Color scaffoldColor = Color(0xFF21252A);
const Color borderColor = Color(0xFF585A5D);
const Color greyCanvasColor = Color(0xFF282C34);

void toast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.grey.shade800,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
