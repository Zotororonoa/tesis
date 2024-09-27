import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';

class TerceraPage extends StatefulWidget {
  final dynamic dato;
  final bool tipo;

  const TerceraPage({super.key, required this.dato, required this.tipo});

  @override
  State<TerceraPage> createState() => _TerceraPage();
}

class _TerceraPage extends State<TerceraPage> {
  String? base64Image;
  int i = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.dato["dataset"])),
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          widget.tipo
              ? Text(
                  "La cantidad de neuronas fueron: ${widget.dato["cantidad_neurons"]}")
              : const SizedBox(),
          !widget.tipo
              ? Text("El número de aguilas es: ${widget.dato["result"]["N"]}")
              : const SizedBox(),
          !widget.tipo
              ? Text("El número de iteraciones: ${widget.dato["result"]["T"]}")
              : const SizedBox(),
          Text(widget.dato["var"] == "0"
              ? "Parametrizado por Accuracy"
              : "Parametrizado por G-mean"),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            flex: 2,
            child: Image.memory(
              Uint8List.fromList(
                  base64Decode(widget.dato["result"]["graphs_base64"][0])),
            ),
          )
        ])));
  }
}
