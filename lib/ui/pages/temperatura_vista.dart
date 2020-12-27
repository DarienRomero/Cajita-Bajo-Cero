import 'package:caja_bajo_cero/helpers/helpers.dart';
import 'package:caja_bajo_cero/models/temperatura_data.dart';
import 'package:caja_bajo_cero/providers/lista_temperaturas.dart';
import 'package:caja_bajo_cero/services.dart/database_service.dart';
import 'package:caja_bajo_cero/ui/widgets/estado_temperatura.dart';
import 'package:caja_bajo_cero/services.dart/excel_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:syncfusion_flutter_charts/charts.dart';

class TemperaturaVista extends StatefulWidget {

  @override
  _TemperaturaVistaState createState() => _TemperaturaVistaState();
}

class _TemperaturaVistaState extends State<TemperaturaVista> {

  @override
  Widget build(BuildContext context) {
    List<TemperaturaData> valoresTemperatura = Provider.of<ListaTemperaturas>(context).getTemperaturas();
    double temperatura = 0;
    if(valoresTemperatura.isNotEmpty){
      temperatura = valoresTemperatura.last.temperatura;
    }
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
          valoresTemperatura.isNotEmpty ? Container(
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
                          onPressed: () async {
                            ExcelService excelService = new ExcelService();
                            DatabaseService databaseService = new DatabaseService();
                            mostrarLoading(context);
                            List<Map<String, dynamic>> excelData = await databaseService.obtenerMedicionesTemperatura();
                            await excelService.crearExcel(excelData);
                            Navigator.pop(context);
                            mostrarAlerta(context, "Archivo creado", "Puedes encontarlo en Descargas");
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
                        dataSource: valoresTemperatura,
                        xValueMapper: (TemperaturaData temperatura, _) => temperatura.dateTime,
                        yValueMapper: (TemperaturaData temperatura, _) => temperatura.temperatura.round(),
                        animationDuration: 200,
                        dataLabelSettings: DataLabelSettings(isVisible: true)
                      )
                    ]
                  ),
                )
              ],
            ),
          ) : SizedBox(
            height: 250,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(child: Text("No hay data que mostrar")),
          ),
        ],
      ),
    );
  }
}


  /* void updateChart() async {
    
    double temperatura = random.nextDouble() * 30;
    double humedad = random.nextDouble() * 30;
    
    DataMesured dataMesured = DataMesured(
      humedad: humedad,
      temperatura: temperatura,
      instanteMedicion: DateTime.now()
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
  } */

