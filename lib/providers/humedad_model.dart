import 'package:flutter/material.dart';

class HumedadModel with ChangeNotifier{
  double _humedad = 50;
  double get humedad => this._humedad;

  set humedad(double humedad){
    this._humedad = humedad;
    notifyListeners();
  }
}