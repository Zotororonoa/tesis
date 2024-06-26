import 'package:flutter/material.dart';
import 'package:app/pages/tercera_page.dart';

class SecondPage extends StatefulWidget {
  final dato;

  const SecondPage({super.key, required this.dato});

  @override
  State<SecondPage> createState() => _SecondPageState(); //Estudiar esta wea
}

class _SecondPageState extends State<SecondPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Seleccionar algoritmo")),
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center the buttons vertically
          children: <Widget>[
            ElevatedButton(
              child:
                  Text("ELM (No regularizada)", style: TextStyle(fontSize: 20)),
              onPressed: () {
                _showTerceraPage(context);
              },
            ),
            SizedBox(height: 20), // Add a SizedBox with a height of 10 pixels
            ElevatedButton(
              child: Text("ELM (Regularizada)", style: TextStyle(fontSize: 20)),
              onPressed: () {
                _showTerceraPage(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

void _showTerceraPage(context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) =>
          TerceraPage(dato: "Dato enviado desde la segunda pantalla"),
    ),
  );
}
