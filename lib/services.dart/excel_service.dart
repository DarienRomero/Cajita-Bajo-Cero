import 'dart:io';

import 'package:caja_bajo_cero/models/temperatura_data.dart';
import 'package:excel/excel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';

class ExcelService{
  ExcelService._privateConstructor();
  static final ExcelService _instance = ExcelService._privateConstructor();
  factory ExcelService() => _instance;

  Future<void> crearExcel(List<Map<String, dynamic>> maps) async {
    /* if (await Permission.mediaLibrary) {
      // The OS restricts access, for example because of parental controls.
    } */
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Temperatura'];
    CellStyle cellStyle = CellStyle(backgroundColorHex: "#1AFF1A", fontFamily : getFontFamily(FontFamily.Calibri));
    cellStyle.underline = Underline.Double;
    int count = 2;
    sheetObject.insertRowIterables(["Instante de Medición", "Temperatura", "Estado"], 1);
    for(Map<String, dynamic> map in maps){
      List<String> lista = [ map["instanteMedicion"].toString(), map["temperatura"].toString(), double.parse(map["temperatura"]) < 20 ? "En rango": "Fuera de rango" ];
      sheetObject.insertRowIterables(lista, count);
      count++;
    }
    //excel.link('Temperatura', sheetObject);
    // Directory tempDir = await getTemporaryDirectory();
    // String tempPath = tempDir.path;
    DateTime instanteDescarga = DateTime.now();
    String completePath = join("/storage/emulated/0/Download/resumen_temperaturas_${instanteDescarga.minute}_${instanteDescarga.second}.xlsx");
    List<int> onValue = await excel.encode();
    if (await Permission.storage.request().isGranted) {
      File(completePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(onValue);
    }
    await OpenFile.open(completePath);
  }
}