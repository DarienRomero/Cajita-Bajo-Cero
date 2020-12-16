class DataMesured{
  final double humedad;
  final double temperatura;
  final DateTime instanteMedicion;

  DataMesured({
    this.humedad, 
    this.temperatura, 
    this.instanteMedicion
  });

  Map<String, dynamic> toMap() {
    return {
      'humedad': humedad,
      'temperatura': temperatura,
      'instanteMedicion': instanteMedicion.millisecondsSinceEpoch,
    };
  }

}