import 'package:caja_bajo_cero/ui/principal.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
void main() async {
  //https://stackoverflow.com/questions/63492211/no-firebase-app-default-has-been-created-call-firebase-initializeapp-in
  WidgetsFlutterBinding.ensureInitialized();
  final Database database = await openDatabase(

  join(await getDatabasesPath(), 'data_mesured_db.db'),
  onCreate: (db, version) {
    return db.execute(
      "CREATE TABLE data_mesured(temperatura FLOAT(1), humedad FLOAT(1), instanteMedicion INTEGER)",
    );
  },
  // Set the version. This executes the onCreate function and provides a
  // path to perform database upgrades and downgrades.
  version: 1,
  );
  runApp(MyApp(database));
}

class MyApp extends StatelessWidget {
  Database database;
  MyApp(this.database);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Principal(database)
    );
  }
}
