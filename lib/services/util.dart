import 'package:flutter/material.dart';

class Util{

  static String nomeApp = "EletroVeiculos";

  Util();

  static Color hexToColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  static Color primaryColor(){
    return Colors.amber;
  }

}