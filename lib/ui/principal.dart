import 'dart:math';

import 'package:caja_bajo_cero/models/temperatura_data.dart';
import 'package:caja_bajo_cero/providers/lista_temperaturas.dart';
import 'package:caja_bajo_cero/services.dart/bluetooth_service.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:caja_bajo_cero/providers/configuration.dart';
import 'package:caja_bajo_cero/services.dart/database_service.dart';
import 'package:caja_bajo_cero/ui/pages/temperatura_vista.dart';

class Principal extends StatefulWidget {
  @override
  _PrincipalState createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal>{

  final GlobalKey<State> principalKey = new GlobalKey<State>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      DatabaseService database = new DatabaseService();
      BluetoothService bluetoothService = new BluetoothService();
      bluetoothService.context = principalKey.currentContext;
      await database.init();
      await bluetoothService.init();
    });
  }

  @override
  void dispose() {
    BluetoothService bluetoothService = new BluetoothService();
    bluetoothService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: principalKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0),
        child: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "Cajita Bajo Cero",
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).primaryColor
            ),
          ),
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.blue
              ),
              onPressed: () async {
                BluetoothService service = BluetoothService();
                DatabaseService database = new DatabaseService();
                service.databaseService = database;
                await service.emparejarYSeleccionarDispositivoBluetooth(context);
                if (service.selectedDevice != null){
                  await service.establecerBluetoothConnection();
                  service.establecerLecturaDatos();
                } 
              }
            ),
            Builder(
              builder: (BuildContext context){
                bool notificacionesHabilitadas = Provider.of<Configuration>(context).notificacionesHabilitadas;
                return IconButton(
                  icon: Icon(
                    Icons.notifications,
                    color: notificacionesHabilitadas ? Colors.blue: Colors.grey,
                  ),
                  onPressed: (){
                    Provider.of<Configuration>(context, listen: false).notificacionesHabilitadas = !notificacionesHabilitadas;
                  },
                );
              }
            ),
          ],
        ),
      ),
      body: TemperaturaVista(),
      /* floatingActionButton: FloatingActionButton(
        onPressed: (){
          Random random = new Random();
          double temperaturaRandom = random.nextDouble() * 10 + 10;
          TemperaturaData temperaturaData = new TemperaturaData( DateTime.now(), temperaturaRandom);
          Provider.of<ListaTemperaturas>(context, listen: false).insertarTemperatura(temperaturaData);
          DatabaseService database = new DatabaseService();
          database.insertarMedicionTemperatura(temperaturaData);
        },
        child: Icon(Icons.add),
      ), */
    );
  }
}

