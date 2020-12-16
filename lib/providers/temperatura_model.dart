
import 'package:flutter/material.dart';

class TemperaturaModel with ChangeNotifier{
  double _temperatura = 24;
  double get temperatura => this._temperatura;

  set temperatura(double temperatura){
    this._temperatura = temperatura;
    notifyListeners();
  }
}