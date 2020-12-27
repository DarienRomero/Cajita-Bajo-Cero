import 'package:flutter/material.dart';

class Configuration extends ChangeNotifier{
  bool _notificacionesHabilitadas = false;
  get notificacionesHabilitadas => this._notificacionesHabilitadas;
  set notificacionesHabilitadas(bool notificacionesHabilitadas){
    this._notificacionesHabilitadas = notificacionesHabilitadas;
    notifyListeners();
  }
}