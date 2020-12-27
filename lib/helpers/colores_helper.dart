part of 'helpers.dart';

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