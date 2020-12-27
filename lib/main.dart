import 'package:caja_bajo_cero/providers/configuration.dart';
import 'package:caja_bajo_cero/providers/lista_temperaturas.dart';
import 'package:caja_bajo_cero/ui/principal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
void main() => runApp(MyApp());

 
class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Configuration()),
        ChangeNotifierProvider(create: (_) => ListaTemperaturas()),
      ],
      child: MaterialApp(
        title: 'Material App',
        debugShowCheckedModeBanner: false,
        home: Principal()
      ),
    );
  }
}
