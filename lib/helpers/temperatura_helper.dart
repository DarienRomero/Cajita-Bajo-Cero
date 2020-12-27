part of 'helpers.dart';

List<TemperaturaData> valoresTemperatura = List<TemperaturaData>();
List<TemperaturaData> cargarValoresTemperatura(){
  List<TemperaturaData> temperaturas = List<TemperaturaData>();
  valoresTemperatura.forEach((element) {
    temperaturas.add(
      TemperaturaData(
        element.dateTime,
        element.temperatura,
      )
    );
  });
  return temperaturas;
}