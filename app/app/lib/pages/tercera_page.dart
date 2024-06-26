import 'dart:ffi';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:app/components/consultasmongo.dart';

class TerceraPage extends StatefulWidget {
  final dato;

  const TerceraPage({super.key, required this.dato});

  @override
  State<TerceraPage> createState() => _TerceraPage();
}

class _TerceraPage extends State<TerceraPage> {
  String? base64Image;
  int i = 0;
  final ScrollController _controller = ScrollController();

  void scrollRight() {
    _controller.animateTo(_controller.offset + 400,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutCubicEmphasized);
  }

  void scrollLeft() {
    _controller.animateTo(_controller.offset - 400,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutCubicEmphasized);
  }

  void snapItem() {
    double offset = _controller.offset;
    double itemWidth = 390;
    int index = (offset / itemWidth).round();
    double target = index * itemWidth;
    _controller.animateTo(target,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutCubicEmphasized);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.dato["result"]["data_set"])),
        body: NotificationListener<ScrollEndNotification>(
          onNotification: (scrollEnd) {
            snapItem();
            return true;
          },
          child: CustomScrollView(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  crossAxisSpacing: 10,
                  mainAxisExtent: 400, //
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Column(
                      children: [
                        Text("Grafico ${index + 1}"),
                        Expanded(
                          flex: 2,
                          child: Image.memory(
                            Uint8List.fromList(base64Decode(
                                widget.dato["result"]["graphs_base64"][index])),
                          ),
                        )
                      ],
                    );
                  },
                  childCount: widget.dato["result"]["graphs_base64"].length,
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      scrollLeft();
                    },
                    label: const Text("Anterior"),
                    icon: const Icon(Icons.arrow_back),
                  )),
              const Expanded(child: SizedBox()),
              FloatingActionButton.extended(
                heroTag: "Claudio_carry",
                onPressed: () {
                  scrollRight();
                },
                label: const Row(
                  children: [
                    Text("Siguiente"),
                    SizedBox(width: 7),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ])));
  }
}
