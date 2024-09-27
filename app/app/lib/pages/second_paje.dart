import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:app/components/consultas.dart';
import 'package:validatorless/validatorless.dart';

class SecondPage extends StatefulWidget {
  final String dato;
  final String hero;
  final String hero2;
  final String dataset;
  const SecondPage(
      {super.key,
      required this.dato,
      required this.hero,
      required this.hero2,
      required this.dataset});

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
  bool button = true;
  bool? check1 = true;
  bool? check2 = false;
  bool switchvalue = false;
  bool switchvalue2 = false;
  bool cambio = false;
  bool loading = false;
  double maxneurona = 150;
  String? _selectedAlgoritmo = "Exhaustiva";
  int _currentSliderValue = 1;
  double muestras = 0.8;
  int valueaux = 50;

  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final controllerP = TextEditingController();
  final controllerN = TextEditingController();
  final controllerT = TextEditingController();

  void contar() async {
    setState(() {
      loading = false;
    });
    String r = await Consultas().postContar(widget.dataset);
    Map<String, dynamic> jsonData = jsonDecode(r);
    setState(() {
      maxneurona = jsonData["muestras"] * 0.8;
      maxneurona = maxneurona.truncateToDouble();
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            "Atributos: ${jsonData["atributos"]}, Clases: ${jsonData["clases"]}, Muestras: ${jsonData["muestras"]}"),
      ),
    );
    setState(() {
      loading = true;
    });
  }

  @override
  void initState() {
    super.initState();
    contar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Seleccionar algoritmo")),
        floatingActionButton: pestanna == true
            ? FloatingActionButton.extended(
                onPressed: () async {
                  if (_formKey.currentState?.validate() == true &&
                      _selectedAlgoritmo == "Exhaustiva") {
                    await Consultas().postAlgoritmo(
                        _selectedAlgoritmo,
                        _currentSliderValue,
                        check1 == true ? "1" : "0",
                        int.parse(controllerP.text),
                        widget.dataset,
                        null,
                        null);
                  }
                  if (_formKey2.currentState?.validate() == true &&
                      _selectedAlgoritmo == "aquila") {
                    await Consultas().postAlgoritmo(
                        _selectedAlgoritmo,
                        _currentSliderValue,
                        check1 == true ? "1" : "0",
                        1,
                        widget.dataset,
                        int.parse(controllerN.text),
                        int.parse(controllerT.text));
                  }
                  if (!mounted) return;
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.send),
                label: const Text("Enviar"),
              )
            : null,
        body: loading
            ? Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Flexible(
                      child: SizedBox(
                    height: 100,
                  )),
                  button
                      ? FloatingActionButton.extended(
                          label: const Text("Extreme Learning Machine (ELM)",
                              style: TextStyle(fontSize: 20)),
                          onPressed: () {
                            setState(() {
                              pestanna = true;
                            });
                          },
                        )
                      : const SizedBox(),
                  const SizedBox(height: 20),
                  pestanna == true
                      ? Container(
                          width: 199,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(color: Colors.blue),
                          ),
                          child: Center(
                              child: DropdownButton(
                            focusColor: const Color(0xFFf8f7fe),
                            items: _algoritmos,
                            value: _selectedAlgoritmo,
                            alignment: Alignment.center,
                            borderRadius: BorderRadius.circular(20.0),
                            underline: const SizedBox(),
                            onChanged: (value) {
                              setState(() {
                                _selectedAlgoritmo = value.toString();
                              });
                            },
                          )))
                      : const SizedBox(),
                  pestanna == true && _selectedAlgoritmo == "Exhaustiva"
                      ? Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              const Text("Cantidad de neuronas"),
                              SizedBox(
                                width: 500,
                                child: Slider(
                                  value: _currentSliderValue.toDouble(),
                                  max: maxneurona,
                                  divisions: 120,
                                  label: _currentSliderValue.round().toString(),
                                  onChanged: (value) {
                                    setState(() {
                                      _currentSliderValue = value.round();
                                    });
                                  },
                                ),
                              )
                            ],
                          ),
                        )
                      : const SizedBox(),
                  !pestanna
                      ? const SizedBox()
                      : const Text('Parametrizar por:',
                          style: TextStyle(color: Colors.black)),
                  !pestanna
                      ? const SizedBox()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Accuracy',
                                style: TextStyle(color: Colors.black)),
                            Checkbox(
                                value: check1,
                                onChanged: (value) {
                                  setState(() {
                                    if (value != null) {
                                      check1 = value;
                                      check2 = !value;
                                    }
                                  });
                                }),
                            const SizedBox(width: 20),
                            const Text('G-mean',
                                style: TextStyle(color: Colors.black)),
                            Checkbox(
                                value: check2,
                                onChanged: (value) {
                                  setState(() {
                                    if (value != null) {
                                      check1 = !value;
                                      check2 = value;
                                    }
                                  });
                                }),
                          ],
                        ),
                  const SizedBox(
                    height: 20,
                  ),
                  !pestanna
                      ? const SizedBox()
                      : _selectedAlgoritmo == "aquila"
                          ? Flexible(
                              child: SizedBox(
                                  width: 350,
                                  child: Form(
                                      key: _formKey2,
                                      child: Column(
                                        children: [
                                          TextFormField(
                                            controller: controllerN,
                                            decoration: InputDecoration(
                                              labelText:
                                                  'Ingrese el paramtero N (Aguilas)',
                                              hintText: 'Ejemplo: 20',
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(
                                                    20.0), // Esquinas redondeadas
                                              ),
                                            ),
                                            validator: Validatorless.multiple([
                                              Validatorless.required(
                                                  'Este campo es requerido'),
                                              Validatorless.number(
                                                  'Por favor, ingrese un número válido'),
                                            ]),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          TextFormField(
                                            controller: controllerT,
                                            decoration: InputDecoration(
                                              labelText:
                                                  'Ingrese el paramtero T (Iteraciones)',
                                              hintText: 'Ejemplo: 20',
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(
                                                    20.0), // Esquinas redondeadas
                                              ),
                                            ),
                                            validator: Validatorless.multiple([
                                              Validatorless.required(
                                                  'Este campo es requerido'),
                                              Validatorless.number(
                                                  'Por favor, ingrese un número válido'),
                                            ]),
                                          )
                                        ],
                                      ))))
                          : Flexible(
                              child: SizedBox(
                                  width: 250,
                                  child: Form(
                                      key: _formKey,
                                      child: TextFormField(
                                        controller: controllerP,
                                        decoration: InputDecoration(
                                          labelText: 'Ingrese tamaño de paso',
                                          hintText: 'Ejemplo: 20',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                20.0), // Esquinas redondeadas
                                          ),
                                        ),
                                        validator: Validatorless.multiple([
                                          Validatorless.required(
                                              'Este campo es requerido'),
                                          Validatorless.number(
                                              'Por favor, ingrese un número válido'),
                                        ]),
                                      )))),
                  const SizedBox(height: 20),
                ],
              ))
            : const Center(
                child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    width: 5,
                  ),
                  Text("Contando...")
                ],
              )));
  }
}
