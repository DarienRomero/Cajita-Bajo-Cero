import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HumedadVista extends StatefulWidget {

  @override
  _HumedadVistaState createState() => _HumedadVistaState();
}

class _HumedadVistaState extends State<HumedadVista> {
  
  Timer timer;
  Random random = Random();
  double humedad = 50;
  List<_HumedadData> valoresHumedad = [_HumedadData(DateTime.now(), 50)];

  
  List<HumedadInstantanea> humedadInstantanea = [
    HumedadInstantanea('Humedad', 80, Colors.blue[200]),
    HumedadInstantanea('Complemento', 20, Colors.grey[200]),
  ];

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => updateChart());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
  void updateChart(){
    setState(() {
      humedad = random.nextDouble() * 10 + 70;
      if(valoresHumedad.length >= 5){
        valoresHumedad.removeAt(0);
      }
      humedadInstantanea = [
        HumedadInstantanea('Humedad', humedad.truncate(), Colors.blue[200]),
        HumedadInstantanea('Complemento', 100 - humedad.truncate(), Colors.grey[200]),
      ];
      valoresHumedad.add(
        _HumedadData(DateTime.now(), humedad.truncate()),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      //mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(height: 20),
        EstadoHumedad(humedadInstantanea, valoresHumedad),
        Container(
          margin: EdgeInsets.only(top: 180),
          child: GraficaHumedad(valoresHumedad: valoresHumedad)
        )
      ],
    );
  }
}

class GraficaHumedad extends StatelessWidget {
  const GraficaHumedad({
    Key key,
    @required this.valoresHumedad,
  }) : super(key: key);

  final List<_HumedadData> valoresHumedad;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        right: 20,
      ),
      child: Column(
        children: [
          Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Center(child: Text('Histórico de humedad')),
              Row(
                children: [
                  Expanded(child: Container()),
                  IconButton(
                    icon: Icon(
                      Icons.download_sharp,
                      color: Theme.of(context).primaryColor
                    ), 
                    onPressed: (){

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
                  text: "Humedad (%)"
                ),
                minimum: 0,
                maximum: 100,
                anchorRangeToVisiblePoints: false,
                plotBands: <PlotBand>[
                  PlotBand(
                    isVisible: true,
                    start: 70,
                    end: 100,
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
              series: <ChartSeries<_HumedadData, DateTime>>[
                SplineSeries<_HumedadData, DateTime>(
                  dataSource: valoresHumedad,
                  // color: Theme.of(context).primaryColor.withOpacity(0.5),
                  xValueMapper: (_HumedadData humedad, _) => humedad.dateTime,
                  yValueMapper: (_HumedadData humedad, _) => humedad.humedad,
                  dataLabelSettings: DataLabelSettings(isVisible: true),
                  animationDuration: 200,
                  markerSettings: MarkerSettings(
                    isVisible: true
                )
                )
              ]
            ),
          ),
        ],
      ),
    );
  }
}
class EstadoHumedad extends StatelessWidget {
  List<HumedadInstantanea> humedadInstantanea;
  List<_HumedadData> valoresHumedad;
  EstadoHumedad(
    this.humedadInstantanea,
    this.valoresHumedad
  );
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: AlignmentDirectional.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: SfCircularChart(
                series: <CircularSeries>[
                  DoughnutSeries<HumedadInstantanea, String>(
                    dataSource: humedadInstantanea,
                    xValueMapper: (HumedadInstantanea data, _) => data.label,
                    yValueMapper: (HumedadInstantanea data, _) => data.humedad,
                    pointColorMapper: (HumedadInstantanea data, _) => data.color,
                    startAngle: 270, // starting angle of pie
                    endAngle: 90, // ending angle of pie
                    animationDuration: 500
                  )
                ],
                margin: EdgeInsets.only(bottom: 0),
              ),
            ),
            Text(
              humedadInstantanea[0].humedad.toStringAsFixed(0) + "%",
              style: TextStyle(
                color: Colors.blue[200],
                fontSize: 30,
                fontWeight: FontWeight.bold
              ),
            )
          ],
        ),
      ],
    );
  }
}
class _HumedadData {
  _HumedadData(this.dateTime, this.humedad);
  final DateTime dateTime;
  final int humedad;
}
class HumedadInstantanea {
  HumedadInstantanea(this.label, this.humedad, [this.color]);
    final String label;
    final int humedad;
    final Color color;
}