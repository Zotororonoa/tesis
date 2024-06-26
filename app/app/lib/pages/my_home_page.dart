import 'package:app/pages/second_paje.dart';
import 'package:flutter/material.dart';
import 'package:app/components/consultasmongo.dart';
import 'package:app/pages/tercera_page.dart';
import 'package:flutter/services.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> respuesta = [];

  @override
  void initState() {
    super.initState();
    _getHistorial();
  }

  void _getHistorial() async {
    print("iniciando getHistorial");
    var respuestaTemp = await getAlgoritmos();
    print("Respuesta obtenida: $respuestaTemp");
    setState(() {
      respuesta = respuestaTemp;
    });
  }

  Future<List<Map<String, dynamic>>> getAlgoritmos() async {
    List<Map<String, dynamic>> respuesta =
        await ConsultasMongo.obtenerAlgoritmos();
    return respuesta;
  }

  @override
  Widget build(BuildContext context) {
    const int largopantalla = 1000;
    return Scaffold(
      appBar: AppBar(title: Text("Historial"), actions: [
        IconButton(
            onPressed: () {
              _getHistorial();
            },
            icon: const Icon(Icons.refresh)),
      ]),
      body: CustomScrollView(
        slivers: [
          SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return GestureDetector(
                    onTap: () {
                      respuesta[index]["status"] == "SUCCESS"
                          ? Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    TerceraPage(dato: respuesta[index]),
                              ),
                            )
                          : null;
                      HapticFeedback.mediumImpact();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        color: Colors.blue[100],
                        child: Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              respuesta[index]["_id"],
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            Text(respuesta[index]["status"]),
                          ],
                        )),
                      ),
                    ),
                  );
                },
                childCount: respuesta.length,
              ),
              gridDelegate: MediaQuery.of(context).size.width <= largopantalla
                  ? const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      crossAxisSpacing: 10,
                      mainAxisExtent: 200,
                    )
                  : const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisExtent: 200)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "Claudio_carry",
        onPressed: () {
          _showSecondPage(context);
        },
        label: const Text("Nuevo"),
        icon: const Icon(Icons.file_upload),
      ),
    );
  }
}

void _showSecondPage(context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) =>
          SecondPage(dato: "Dato enviado desde la primera pantalla"),
    ),
  );
}
