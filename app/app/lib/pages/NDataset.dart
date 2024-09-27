import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:app/components/consultas.dart';
import 'package:validatorless/validatorless.dart';

class NuevoDataset extends StatefulWidget {
  const NuevoDataset({super.key});

  @override
  State<NuevoDataset> createState() => _NuevoDatasetState();
}

class _NuevoDatasetState extends State<NuevoDataset> {
  final List<DropdownMenuItem> _algoritmos = [
    const DropdownMenuItem(
        alignment: Alignment.center,
        value: "Exhaustiva",
        child: Center(
          child: Text(
            "Búsqueda Exhaustiva",
          ),
        )),
    const DropdownMenuItem(
      alignment: Alignment.center,
      value: "aquila",
      child: Center(child: Text("AO")),
    ),
  ];
  bool pestanna = false;
  bool pestanna2 = false;
  bool button = true;
  bool button2 = true;
  bool? check1 = true;
  bool? check2 = false;
  bool switchvalue = false;
  bool switchvalue2 = false;
  bool cambio = false;
  bool estadoboton = false;
  bool loadingsiguiente = false;
  bool loading = false;

  double muestra = 0.8;
  double maxneurona = 150;
  int _currentSliderValue = 1;
  int valueaux = 50;

  String? _selectedAlgoritmo = "Exhaustiva";
  String _fileName = "";
  String _base64File = "";
  String bmensaje = "Añadir dataset";
  Icon bicon = const Icon(Icons.add_circle);

  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final controllerP = TextEditingController();
  final controllerN = TextEditingController();
  final controllerT = TextEditingController();
  void _pickFile() async {
    setState(() {
      loading = true;
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['dt', 'csv'],
    );

    setState(() {
      loading = false;
      bmensaje = "Cambiar dataset";
      bicon = const Icon(Icons.change_circle);
    });

    if (result != null) {
      File file = File(result.files.single.path!);
      List<int> fileBytes = await file.readAsBytes();
      String base64String = base64Encode(fileBytes);

      setState(() {
        _fileName = result.files.single.name;
        _base64File = base64String;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Seleccionaste el archivo $_fileName'),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Operación Cancelada'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: pestanna == !loadingsiguiente
            ? pestanna2 == true
                ? FloatingActionButton.extended(
                    onPressed: () async {
                      setState(() {
                        cambio = !cambio;
                      });
                      if (cambio && !estadoboton) {
                        setState(() {
                          loadingsiguiente = true;
                        });
                        !switchvalue
                            ? await Consultas()
                                .postArchivo(_base64File, _fileName)
                            : await Consultas().postnormalizado(_base64File,
                                _fileName, switchvalue2 ? "0" : "1");

                        String r = await Consultas().postContar(_fileName);
                        setState(() {
                          loadingsiguiente = false;
                        });

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
                          estadoboton = true;
                        });
                      }
                      if (_formKey.currentState?.validate() == true &&
                          estadoboton &&
                          _selectedAlgoritmo == "Exhaustiva") {
                        await Consultas().postAlgoritmo(
                            _selectedAlgoritmo,
                            _currentSliderValue,
                            check1 == true ? "1" : "0",
                            int.parse(controllerP.text),
                            _fileName,
                            null,
                            null);
                        setState(() {
                          estadoboton = false;
                        });
                      }
                      if (_formKey2.currentState?.validate() == true &&
                          estadoboton &&
                          _selectedAlgoritmo == "aquila") {
                        await Consultas().postAlgoritmo(
                            _selectedAlgoritmo,
                            _currentSliderValue,
                            check1 == true ? "1" : "0",
                            1,
                            _fileName,
                            int.parse(controllerN.text),
                            int.parse(controllerT.text));
                      }
                    },
                    label: Text(estadoboton ? "Finalizar" : "Siguiente"),
                    icon: Icon(estadoboton
                        ? Icons.send_and_archive_rounded
                        : Icons.arrow_forward_ios),
                  )
                : null
            : null,
        body: !loading == !loadingsiguiente
            ? Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Flexible(
                      child: SizedBox(
                    height: 100,
                  )),
                  estadoboton
                      ? const SizedBox()
                      : button
                          ? FloatingActionButton.extended(
                              label: const Text(
                                  "Extreme Learning Machine (ELM)",
                                  style: TextStyle(fontSize: 20)),
                              onPressed: () {
                                setState(() {
                                  pestanna = true;
                                  button2 = false;
                                });
                              },
                            )
                          : const SizedBox(),
                  const SizedBox(height: 20),
                  !estadoboton
                      ? pestanna == true
                          ? SizedBox(
                              child: FloatingActionButton.extended(
                                onPressed: () {
                                  _pickFile();
                                  setState(() {
                                    pestanna2 = true;
                                  });
                                },
                                icon: bicon,
                                label: Text(bmensaje),
                              ),
                            )
                          : const SizedBox()
                      : const SizedBox(),
                  const SizedBox(height: 20),
                  !estadoboton
                      ? pestanna == true
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  const Text('Normalizar dataset',
                                      style: TextStyle(color: Colors.black)),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Switch(
                                      value: switchvalue,
                                      onChanged: (newvalue) {
                                        setState(() {
                                          switchvalue = newvalue;
                                          if (!switchvalue) {
                                            switchvalue2 = false;
                                          }
                                        });
                                      }),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(switchvalue ? 'Si' : 'No',
                                      style:
                                          const TextStyle(color: Colors.black)),
                                ])
                          : const SizedBox()
                      : const SizedBox(),
                  !estadoboton
                      ? !switchvalue
                          ? const SizedBox()
                          : pestanna == true
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                      const Text('¿Como desea normalizar?',
                                          style:
                                              TextStyle(color: Colors.black)),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Switch(
                                          value: switchvalue2,
                                          onChanged: (newvalue) {
                                            setState(() {
                                              switchvalue2 = newvalue;
                                            });
                                          }),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                          switchvalue2 ? '[0 , 1]' : '[-1 , 1]',
                                          style: const TextStyle(
                                              color: Colors.black)),
                                    ])
                              : const SizedBox()
                      : const SizedBox(),
                  !estadoboton
                      ? const SizedBox()
                      : pestanna2 == true
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
                  !estadoboton
                      ? const SizedBox()
                      : pestanna2 == true && _selectedAlgoritmo == "Exhaustiva"
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
                                      label: _currentSliderValue
                                          .round()
                                          .toString(),
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
                  !estadoboton
                      ? const SizedBox()
                      : const Text('Parametrizar por:',
                          style: TextStyle(color: Colors.black)),
                  !estadoboton
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
                  !estadoboton
                      ? const SizedBox()
                      : const SizedBox(
                          height: 20,
                        ),
                  !estadoboton
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
                child: CircularProgressIndicator(),
              ));
  }
}
