import 'dart:async';
import 'dart:typed_data';
import 'dart:math';

import 'package:caja_bajo_cero/models/data_mesured.dart';
import 'package:caja_bajo_cero/models/temperatura_data.dart';
import 'package:caja_bajo_cero/ui/bluetooth/background_collecting_task.dart';
import 'package:caja_bajo_cero/ui/bluetooth/discovery_page.dart';
import 'package:caja_bajo_cero/ui/bluetooth/select_bonded_device_page.dart';
import 'package:caja_bajo_cero/ui/humedad_vista.dart';
import 'package:caja_bajo_cero/ui/temperatura_vista.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:sqflite/sqflite.dart';

class Principal extends StatefulWidget {
  final Database database;
  Principal(this.database);
  @override
  _PrincipalState createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal>  with SingleTickerProviderStateMixin{
  
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  BluetoothDevice selectedDevice;
  
  String _address = "...";
  String _name = "...";

  Timer _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;

  List<_Message> messages = List<_Message>();
  String _messageBuffer = '';

  BackgroundCollectingTask _collectingTask;

  bool _autoAcceptPairingRequests = false;

  BluetoothConnection connection;
  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;
  bool isDisconnecting = false;

  final List<Tab> myTabs = <Tab> [
    Tab(
      icon: Container(
        width: 30,
        height: 30,
        child: Image.asset(
          'assets/img/icono_temperatura.png',
          fit: BoxFit.contain,
        )
      )
    ),
    Tab(
      icon: Container(
        width: 30,
        height: 30,
        child: Image.asset(
          'assets/img/icono_humedad.png',
          fit: BoxFit.contain,
        )
      )
    ),
  ];

  bool notificacionesHabilitadas = false;
  TabController _tabController;

  Timer timer;
  Random random = Random();
  List<DataMesured> dataMedida = [
    DataMesured(
      humedad: 50 ,
      temperatura: 50, 
      instanteMedicion: DateTime.now()
    )
  ];

  @override
  void initState() {
    super.initState();
    
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => updateChart());
    
    _tabController = TabController
    (vsync: this, 
    length: myTabs.length);
    
    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
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
        setState(() {
          _address = address;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
        _discoverableTimeoutSecondsLeft = 0;
      });
    });
    //Si el bluetooth del dispositivo no está activado
    //Se solicita la habilitación
    future() async {
      if (await FlutterBluetoothSerial.instance.isEnabled) {
        return false;
      }else{
        await FlutterBluetoothSerial.instance.requestEnable();
      }
    }

    future().then((_) {
      setState(() {});
    });
  }

  void updateChart() async {
    
    double temperatura = random.nextDouble() * 30;
    double humedad = random.nextDouble() * 30;
    
    DataMesured dataMesured = DataMesured(
      humedad: humedad,
      temperatura: temperatura,
      instanteMedicion: DateTime.now()
    );
    await widget.database.insert(
      'data_mesured',
      dataMesured.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    setState(() {
      
      if(dataMedida.length >= 5){
        dataMedida.removeAt(0);
      }
      dataMedida.add(
        DataMesured(
          humedad: humedad ,
          temperatura: temperatura, 
          instanteMedicion: DateTime.now()
        )
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    timer?.cancel();
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _collectingTask?.dispose();
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  Future<void> imprimirDatos() async {
  // Get a reference to the database.
  final Database db = widget.database;

  // Query the table for all The Dogs.
  final List<Map<String, dynamic>> maps = await db.query('data_mesured');

  // Convert the List<Map<String, dynamic> into a List<Dog>.
  List.generate(maps.length, (i) {
    print(maps[i]['temperatura']);
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              onPressed: () => emparejarYSeleccionarDispositivoBluetooth()
            ),
            IconButton(
              icon: Icon(
                Icons.notifications,
                color: notificacionesHabilitadas ? Colors.blue: Colors.grey
              ),
              onPressed: (){
                setState(() {
                  notificacionesHabilitadas = !notificacionesHabilitadas;
                });
              },
            ),
            /* IconButton(
              icon: Icon(
                Icons.refresh_sharp,
                color: Colors.blue
              ),
              // onPressed: () => cambiarDispositivoBluetoothSeleccionado()
            ), */
          ],
          bottom: TabBar(
            indicatorColor: Theme.of(context).primaryColor,
            labelColor: Theme.of(context).primaryColor,
            controller: _tabController,
            tabs: myTabs,
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          TemperaturaVista(
            cargarValoresTemperatura(),
            widget.database
          ),
          Container()
          //HumedadVista()  
        ],
      ),
    );
  }
  List<TemperaturaData> cargarValoresTemperatura(){
    List<TemperaturaData> valoresTemperatura = List<TemperaturaData>();
    dataMedida.forEach((element) {
        valoresTemperatura.add(
          TemperaturaData(
            element.instanteMedicion,
            element.temperatura,
          )
        );
    });
    return valoresTemperatura;
  }
  /*La funcion te lleva a otra pantalla para seleccionar entre uno
    de los dispositivos blueooth emparejados */
  void cambiarDispositivoBluetoothSeleccionado() async {
    /*Se va a la pantalla de dispositivos conectados
      y luego cuando se selecciona uno se va a la pantalla
      de chat */
    selectedDevice =
        await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return SelectBondedDevicePage(checkAvailability: false);
        },
      ),
    );
    //Luego de seleccionar un dispositivo se establece el canal
    //de lectura de datos y se van almacenando en messages
    //establecerBluetoothConnection(selectedDevice);  
    if (selectedDevice != null) {
      print('Connect -> selected ' + selectedDevice.address);
    } else {
      print('Connect -> no device selected');
    }
  }
  void emparejarYSeleccionarDispositivoBluetooth() async {
    selectedDevice =
        await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return DiscoveryPage();
        },
      ),
    );
    //Luego de seleccionar un dispositivo se establece el canal
    //de lectura de datos y se van almacenando en messages
    //establecerBluetoothConnection(selectedDevice);
    if (selectedDevice != null) {
      print('Discovery -> selected ' + selectedDevice.address);
    } else {
      print('Discovery -> no device selected');
    }
  }
  /*La funcion establece el canal de lectura de datos desde un dispositivo
    bluetooth determinado */
  void establecerBluetoothConnection(BluetoothDevice server){
    /*La funcion convierte la dirección del Bluetooth Device a un Bluetooth Connection */
    BluetoothConnection.toAddress(server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });
      //Se establece el canal de lectura de datos
      connection.input.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  /*La funcion lee si hay data nueva, lo convierte a un string y lo almacena en la 
  lista de mensajes*/
  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }
}
class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}
