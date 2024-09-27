import 'package:flutter/material.dart';
import 'package:app/components/consultasmongo.dart';
import 'package:app/pages/tercera_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class Historial extends StatefulWidget {
  const Historial({Key? key}) : super(key: key);

  @override
  State<Historial> createState() => _HistorialState();
}

class _HistorialState extends State<Historial>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> respuestaE = [];
  List<Map<String, dynamic>> respuestaAO = [];
  late AnimationController controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _getHistorial();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _getHistorial() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    var respuestae = await getAlgoritmosE();
    var respuetsaao = await getAlgoritmosAO();
    setState(() {
      respuestaE = respuestae;
      respuestaAO = respuetsaao;
      _isLoading = false;
    });
  }

  Future<List<Map<String, dynamic>>> getAlgoritmosE() async {
    List<Map<String, dynamic>> respuestaE =
        await ConsultasMongo.obtenerAlgoritmosE();
    return respuestaE;
  }

  Future<List<Map<String, dynamic>>> getAlgoritmosAO() async {
    List<Map<String, dynamic>> respuestaE =
        await ConsultasMongo.obtenerAlgoritmosAO();
    return respuestaE;
  }

  @override
  Widget build(BuildContext context) {
    const int largopantalla = 1000;

    return Scaffold(
      body: _isLoading
          ? const Center(
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              CircularProgressIndicator(),
              SizedBox(
                width: 10,
              ),
              Flexible(
                  child: Text('Cargando información...',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold))),
            ]))
          : CustomScrollView(slivers: [
              SliverStickyHeader.builder(
                builder: (context, state) => Container(
                  color: !state.isPinned
                      ? const Color(0xFFf8f7fe)
                      : const Color(0xFFdbe1ed),
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.centerLeft,
                  child: const Text('Exaustiva',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return GestureDetector(
                          onTap: () {
                            respuestaE[index]["status"] == "SUCCESS"
                                ? Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => TerceraPage(
                                          dato: respuestaE[index], tipo: true),
                                    ),
                                  )
                                : null;
                            HapticFeedback.mediumImpact();
                          },
                          child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Card(
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        color: respuestaE[index]["status"] ==
                                                "SUCCESS"
                                            ? const Color.fromARGB(
                                                255, 0, 122, 4)
                                            : respuestaE[index]["status"] ==
                                                    "PENDING"
                                                ? const Color.fromARGB(
                                                    255, 194, 117, 3)
                                                : const Color.fromARGB(
                                                    255, 194, 28, 3),
                                        width: 5.0, // Ancho del borde
                                      ),
                                      borderRadius: BorderRadius.circular(30)),
                                  color: respuestaE[index]["status"] ==
                                          "SUCCESS"
                                      ? const Color(0xFFA8FFAD)
                                      : respuestaE[index]["status"] == "PENDING"
                                          ? const Color(0xFFFFD987)
                                          : const Color.fromARGB(
                                              255, 232, 136, 130),
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          const Text(
                                            "Nombre del Dataset:",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Flexible(
                                              child: Text(
                                            respuestaE[index]["dataset"],
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          )),
                                        ]),
                                        Row(children: [
                                          const Text(
                                            "Parametrización:",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            respuestaE[index]["var"] == "0"
                                                ? "Accuracy"
                                                : "G-mean",
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ]),
                                        Row(children: [
                                          const Text(
                                            "Estado:",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            respuestaE[index]["status"],
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ]),
                                        const Expanded(
                                          child: SizedBox(),
                                        ),
                                        Row(children: [
                                          const Text(
                                            "ID:",
                                            style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            respuestaE[index]["_id"],
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 9,
                                            ),
                                          )
                                        ]),
                                      ],
                                    ),
                                  ))));
                    },
                    childCount: respuestaE.length,
                  ),
                  gridDelegate:
                      MediaQuery.of(context).size.width <= largopantalla
                          ? const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              crossAxisSpacing: 10,
                              mainAxisExtent: 200,
                            )
                          : const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisExtent: 200),
                ),
              ),
              SliverStickyHeader.builder(
                builder: (context, state) => Container(
                  color: !state.isPinned
                      ? const Color(0xFFf8f7fe)
                      : const Color(0xFFdbe1ed),
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.centerLeft,
                  child: const Text('AO',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return GestureDetector(
                        onTap: () {
                          respuestaAO[index]["status"] == "SUCCESS"
                              ? Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => TerceraPage(
                                        dato: respuestaAO[index], tipo: false),
                                  ),
                                )
                              : null;
                          HapticFeedback.mediumImpact();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Card(
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: respuestaAO[index]["status"] ==
                                            "SUCCESS"
                                        ? const Color.fromARGB(255, 0, 122, 4)
                                        : respuestaAO[index]["status"] ==
                                                "PENDING"
                                            ? const Color.fromARGB(
                                                255, 194, 117, 3)
                                            : const Color.fromARGB(
                                                255, 194, 28, 3),
                                    width: 5.0, // Ancho del borde
                                  ),
                                  borderRadius: BorderRadius.circular(30)),
                              color: respuestaAO[index]["status"] == "SUCCESS"
                                  ? const Color(0xFFA8FFAD)
                                  : respuestaAO[index]["status"] == "PENDING"
                                      ? const Color(0xFFFFD987)
                                      : const Color.fromARGB(
                                          255, 232, 136, 130),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      const Text(
                                        "Nombre del Dataset:",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Flexible(
                                          child: Text(
                                        respuestaAO[index]["dataset"],
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      )),
                                    ]),
                                    Row(children: [
                                      const Text(
                                        "Parametrización:",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        respuestaAO[index]["var"] == "0"
                                            ? "Accuracy"
                                            : "G-mean",
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ]),
                                    Row(children: [
                                      const Text(
                                        "Estado:",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        respuestaAO[index]["status"],
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ]),
                                    const Expanded(
                                      child: SizedBox(),
                                    ),
                                    Row(children: [
                                      const Text(
                                        "ID:",
                                        style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        respuestaAO[index]["_id"],
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 9,
                                        ),
                                      )
                                    ]),
                                  ],
                                ),
                              )),
                        ),
                      );
                    },
                    childCount: respuestaAO.length,
                  ),
                  gridDelegate:
                      MediaQuery.of(context).size.width <= largopantalla
                          ? const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              crossAxisSpacing: 10,
                              mainAxisExtent: 200,
                            )
                          : const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisExtent: 200),
                ),
              ),
            ]),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          _getHistorial();
        },
        child: const Icon(Icons.update),
      ),
    );
  }
}
