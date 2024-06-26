import 'package:flutter/material.dart';
import 'package:app/components/consultas.dart';

class SecondPage extends StatefulWidget {
  final dato;

  const SecondPage({super.key, required this.dato});

  @override
  State<SecondPage> createState() => _SecondPageState(); //Estudiar esta wea
}

class _SecondPageState extends State<SecondPage> {
  final List<DropdownMenuItem> _algoritmos = [
    const DropdownMenuItem(
      value: "Exhaustiva",
      child: Text("Búsqueda Exhaustiva"),
    ),
    const DropdownMenuItem(
      value: "aquila",
      child: Text("AO"),
    ),
  ];

  bool pestanna = false;
  String? _selectedAlgoritmo = "Exhaustiva";
  int _currentSliderValue = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seleccionar algoritmo")),
      floatingActionButton: pestanna == true
          ? FloatingActionButton.extended(
              onPressed: () async {
                String task_id = await Consultas().postAlgoritmo(
                    _selectedAlgoritmo!, _currentSliderValue.round());
              },
              label: const Text("Siguiente"),
            )
          : null,
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center the buttons vertically
          children: <Widget>[
            ElevatedButton(
              child: const Text("Extreme Learning Machine (ELM)",
                  style: TextStyle(fontSize: 20)),
              onPressed: () {
                setState(() {
                  pestanna = true;
                });
              },
            ),
            const SizedBox(
                height: 20), // Add a SizedBox with a height of 10 pixels
            pestanna == true
                ? DropdownButton(
                    items: _algoritmos,
                    value: _selectedAlgoritmo,
                    onChanged: (value) {
                      setState(() {
                        _selectedAlgoritmo = value.toString();
                      });
                    },
                  )
                : const SizedBox(height: 10),
            pestanna == true && _selectedAlgoritmo == "Exhaustiva"
                ? Slider(
                    value: _currentSliderValue.toDouble(),
                    max: 120,
                    divisions: 120,
                    label: _currentSliderValue.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        _currentSliderValue = value.round();
                      });
                    },
                  )
                : const SizedBox(),
            const SizedBox(height: 20),
            //ElevatedButton(
            //  child: Text("Regularized Extreme Learning Machine (R-ELM)",
            //      style: TextStyle(fontSize: 20)),
            //  onPressed: () {
            //    _showTerceraPage(context);
            //  },
            //),
          ],
        ),
      ),
    );
  }
}
