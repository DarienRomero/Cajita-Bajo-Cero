import 'package:caja_bajo_cero/models/temperatura_data.dart';
import 'package:flutter/material.dart';

class ListaTemperaturas with ChangeNotifier {

  List<TemperaturaData> _listaTemperaturas = List<TemperaturaData>();
  
  void insertarTemperatura(TemperaturaData temperaturaData){
    this._listaTemperaturas.add(temperaturaData);
    notifyListeners();
  }

  List<TemperaturaData> getTemperaturas(){
    int length = this._listaTemperaturas.length;
    if(length >= 5){
      return this._listaTemperaturas.sublist(length - 5, length - 1);
    }else{
      return this._listaTemperaturas;
    }
    
  }
  List<TemperaturaData> getAllTemperaturas(){
    return this._listaTemperaturas;
  }

}