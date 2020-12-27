import 'dart:async';
import 'dart:typed_data';

import 'package:caja_bajo_cero/models/message.dart';
import 'package:caja_bajo_cero/models/temperatura_data.dart';
import 'package:caja_bajo_cero/providers/lista_temperaturas.dart';
import 'package:caja_bajo_cero/services.dart/bluetooth/background_collecting_task.dart';
import 'package:caja_bajo_cero/services.dart/bluetooth/discovery_page.dart';
import 'package:caja_bajo_cero/services.dart/database_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

class BluetoothService{
  BluetoothService._privateConstructor();
  static final BluetoothService _instance = BluetoothService._privateConstructor();
  factory BluetoothService() => _instance;

  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  DatabaseService databaseService;
  BuildContext context;
  BluetoothConnection connection;
  BluetoothDevice selectedDevice;
  String _address = "...";
  String _name = "...";
  String buffer = "";
  bool secondCaracterArrived;
  Timer _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;
  bool _autoAcceptPairingRequests = false;
  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;
  bool isDisconnecting = false;
  List<Message> messages = List<Message>();

  BackgroundCollectingTask _collectingTask;
  
  Future<void> init() async {
    FlutterBluetoothSerial.instance.state.then((state) {
      _bluetoothState = state;
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if (await FlutterBluetoothSerial.instance.isEnabled) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        _address = address;
      });
    });
       // Get current state
    FlutterBluetoothSerial.instance.name.then((name) {
        _name = name;
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
      .onStateChanged()
      .listen((BluetoothState state) {
      _bluetoothState = state;

      // Discoverable mode is disabled when Bluetooth gets disabled
      _discoverableTimeoutTimer = null;
      _discoverableTimeoutSecondsLeft = 0;
    });
    //Si el bluetooth del dispositivo no está activado
    //Se solicita la habilitación
    if (await FlutterBluetoothSerial.instance.isEnabled) {
      return false;
    }else{
      await FlutterBluetoothSerial.instance.requestEnable();
    }
  }
  void dispose(){
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _collectingTask?.dispose();
    _discoverableTimeoutTimer?.cancel();
  }
  Future<void> emparejarYSeleccionarDispositivoBluetooth(BuildContext context) async {
    this.selectedDevice = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return DiscoveryPage();
        },
      ),
    );
    if (selectedDevice != null) {
      print('Discovery -> selected ' + selectedDevice.address);
    } else {
      print('Discovery -> no device selected');
    }
  }
  /*La funcion convierte la dirección del Bluetooth Device a un Bluetooth Connection */
  Future<void> establecerBluetoothConnection() async {
    try{
      BluetoothConnection conexion = await BluetoothConnection.toAddress(selectedDevice.address);
      this.connection = conexion;
      print("Conexión entrante: ${this.connection}");
    }catch(error){
      print("Error al establecer conexión Bluetooth");
    }
  }
  void establecerLecturaDatos(){
    connection.input.listen(onDataReceived).onDone(() {
      if (isDisconnecting) {
        print('Disconnecting locally!');
      } else {
        print('Disconnected remotely!');
      }
    });
  }
  void onDataReceived(Uint8List data) async {
    String mensaje = new String.fromCharCodes(data);
    if(mensaje.length == 1){
      buffer = buffer + mensaje;
    }else if (mensaje.length == 3){
      buffer = buffer + mensaje;
      print(buffer);
      if (double.tryParse(buffer) != null){
        double tempDouble =  double.parse(buffer);
        if(tempDouble > 20){
          if (await Vibration.hasVibrator()) {
            Vibration.vibrate();
          }
        }
        TemperaturaData temperaturaData = new TemperaturaData(DateTime.now(), tempDouble);
        await this.databaseService.insertarMedicionTemperatura(temperaturaData);
        Provider.of<ListaTemperaturas>(context, listen: false).insertarTemperatura(temperaturaData);  
      }
      buffer = "";
    }
  }
}