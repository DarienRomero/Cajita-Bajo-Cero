import 'package:caja_bajo_cero/helpers/helpers.dart';
import 'package:flutter/material.dart';

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