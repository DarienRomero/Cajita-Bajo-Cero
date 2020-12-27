import 'package:caja_bajo_cero/models/temperatura_data.dart';
import 'package:caja_bajo_cero/providers/lista_temperaturas.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService{

  DatabaseService._privateConstructor();
  static final DatabaseService _instance = DatabaseService._privateConstructor();
  factory DatabaseService() => _instance;
  Database database;

  Future<void> init() async {
      database = await openDatabase(
        join(await getDatabasesPath(), 'temperatura_database.db'),
        onCreate: (db, version) {
          return db.execute(
            "CREATE TABLE tabla_temperatura(temperatura text, instanteMedicion text)",
          );
        },
      version: 1,
      );
  }
  Future<void> insertarMedicionTemperatura(TemperaturaData data) async {
    await this.database.insert(
      'tabla_temperatura',
      {
        'temperatura': data.temperatura.toStringAsFixed(1),
        'instanteMedicion': data.dateTime.toString()
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  /* Future<void> insertarTemperaturas(BuildContext context ) async {
    List<TemperaturaData> temperaturas = Provider.of<ListaTemperaturas>(context).getAllTemperaturas();
    for(TemperaturaData temperatura in temperaturas){
      await this.insertarMedicionTemperatura(temperatura);
    }
  } */
  Future<List<Map<String, dynamic>>> obtenerMedicionesTemperatura() async {
    final List<Map<String, dynamic>> maps = await database.query('tabla_temperatura');
    return maps;
  }
  List<TemperaturaData> mapearDataTemperatura(List<Map<String, dynamic>> queries){
    List<TemperaturaData> listaTemperatura = new List<TemperaturaData>();
    for (Map<String, dynamic> query in queries){
      listaTemperatura.add(
        TemperaturaData(
          DateTime.parse(query["instanteMedicion"]),
          double.parse(query["temperatura"])
        )
      );
    }
    return listaTemperatura; 
  }
  
  Future<List<TemperaturaData>> getTemperaturaData() async {
    List<Map<String, dynamic>> maps = await this.obtenerMedicionesTemperatura();
    return this.mapearDataTemperatura(maps);
  }
}