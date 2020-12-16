import 'dart:io';

import 'package:caja_bajo_cero/models/temperatura_data.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

import 'package:syncfusion_flutter_charts/charts.dart';

class TemperaturaVista extends StatefulWidget {
  
  final List<TemperaturaData> valoresTemperatura;
  final Database database;

  TemperaturaVista(this.valoresTemperatura, this.database);
  
  @override
  _TemperaturaVistaState createState() => _TemperaturaVistaState();
}

class _TemperaturaVistaState extends State<TemperaturaVista> {
  
  double temperatura;

  @override
  Widget build(BuildContext context) {
    temperatura = widget.valoresTemperatura.last.temperatura;
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(height: 20),
          EstadoTemperatura(temperatura),
          Text(
            temperatura.toStringAsFixed(1) + " °C",
            style: TextStyle(
              color: evaluarColores(temperatura),
              fontSize: 30,
              fontWeight: FontWeight.bold
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 20
            ),
            child: Column(
              children: [
                Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Center(child: Text('Histórico de temperatura')),
                    Row(
                      children: [
                        Expanded(child: Container()),
                        IconButton(
                          icon: Icon(
                            Icons.download_sharp,
                            color: Theme.of(context).primaryColor
                          ), 
                          onPressed: (){
                            imprimirDatos();
                          }
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 250,
                  child: SfCartesianChart(
                    primaryXAxis: DateTimeAxis(
                      title: AxisTitle(
                        text: "Tiempo (min:seg)"
                      ),
                    ),
                    primaryYAxis: NumericAxis(
                      title: AxisTitle(
                        text: "Temperatura (°C)"
                      ),
                      minimum: 0,
                      maximum: 50,
                      anchorRangeToVisiblePoints: false,
                      plotBands: <PlotBand>[
                        PlotBand(
                          isVisible: true,
                          start: 0,
                          end: 10,
                          color: Colors.blue[100],
                          text: "Zona recomendada",
                          textStyle: TextStyle(
                            fontSize: 18,
                            color: Colors.blue
                          ),
                          verticalTextAlignment: TextAnchor.middle,
                          horizontalTextAlignment: TextAnchor.middle,
                          verticalTextPadding: '-5%',
                        )
                      ],
                    ),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <ChartSeries<TemperaturaData, DateTime>>[
                      StackedLineSeries<TemperaturaData, DateTime>(
                        dataSource: widget.valoresTemperatura,
                        xValueMapper: (TemperaturaData temperatura, _) => temperatura.dateTime,
                        yValueMapper: (TemperaturaData temperatura, _) => temperatura.temperatura.round(),
                        animationDuration: 200,
                        dataLabelSettings: DataLabelSettings(isVisible: true)
                      )
                    ]
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
  Future<void> imprimirDatos() async {
    // Get a reference to the database.
    final Database db = widget.database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('data_mesured');
    await crearExcel(maps);
    // Convert the List<Map<String, dynamic> into a List<Dog>.
    List.generate(maps.length, (i) {
      print(maps[i]['temperatura']);
    });
  }
  Future<void> crearExcel(List<Map<String, dynamic>> maps) async {
    /* if (await Permission.mediaLibrary) {
      // The OS restricts access, for example because of parental controls.
    } */
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Data medida'];
    CellStyle cellStyle = CellStyle(backgroundColorHex: "#1AFF1A", fontFamily : getFontFamily(FontFamily.Calibri));
    cellStyle.underline = Underline.Double;
    int count = 1;
    sheetObject.insertRowIterables(["Temperatura", "Humendad", "Instante de Medición"], 0);
    for(Map<String, dynamic> map in maps){
      List<dynamic> lista = [map["temperatura"], map["humedad"], map["instanteMedicion"]];
      sheetObject.insertRowIterables(lista, count);
      count++;
    }
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    DateTime instanteDescarga = DateTime.now();
    excel.encode().then((onValue) {
        // File(join("$tempPath/data_medida_${instanteDescarga.toString()}.xlsx"))
        File(join("/storage/emulated/0/Download/${instanteDescarga.toString()}.xlsx"))
        ..createSync(recursive: true)
        ..writeAsBytesSync(onValue);
    });
  }
}

class EstadoTemperatura extends StatelessWidget {
  
  final double temperatura;

  EstadoTemperatura(
    this.temperatura
  );
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomStart,
      children: [
        Container(
          width: 30,
          height: 130,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.all(Radius.circular(50))
          ),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 500),
          width: 30,
          height: 15 + temperatura * 2,
          decoration: BoxDecoration(
            color: evaluarColores(temperatura),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            )
          ),
        ),
        Positioned(
          // left: -20,
          child: Column(
            children: [
              Container(
                height: 20,
                width: 30,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "40",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black26
                      )
                    ),
                  ],
                ),
              ),
              Container(
                height: 20,
                width: 30,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "30",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black26
                      )
                    ),
                  ],
                ),
              ),
              Container(
                height: 20,
                width: 30,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "20",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black26
                      )
                    ),
                  ],
                ),
              ),
              Container(
                height: 20,
                width: 30,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "10",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black26
                      )
                    ),
                  ],
                ),
              ),
              Container(
                height: 20,
                width: 30,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "0",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black26
                      )
                    ),
                  ],
                ),
              ),
              Container(
                height: 15,
                width: 30,
              ),
            ],
          ),
        )
      ],
    );
  }
}
Color evaluarColores(double temperatura){
  if(temperatura < 5){
    return Colors.blue;
  }else if (temperatura < 10){
    return Colors.blue[200];
  }else if (temperatura < 15){
    return Colors.yellow[200];
  }else if (temperatura < 20){
    return Colors.orange[200];
  }else if (temperatura < 25){
    return Colors.orange[400];
  }else if (temperatura < 30){
    return Colors.orange[900];
  }else{
    return Colors.red;
  }
}