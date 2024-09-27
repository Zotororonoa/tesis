import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/icon_park_solid.dart';
import 'package:iconify_flutter/icons/healthicons.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/game_icons.dart';
import 'package:app/pages/second_paje.dart';

class Datasets extends StatefulWidget {
  const Datasets({super.key});

  @override
  State<Datasets> createState() => _DatasetsState();
}

class _DatasetsState extends State<Datasets> {
  String hero1 = "Iris";
  String hero2 = "Diabetes";
  String hero3 = "Cardio";
  String hero4 = "UCIC";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double iconSize = constraints.maxWidth / 3;
                        double textSize = constraints.maxWidth / 10;
                        return FloatingActionButton(
                          heroTag: hero1,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SecondPage(
                                  dato: "Iris",
                                  hero: hero1,
                                  hero2: hero4,
                                  dataset: "iris.dt",
                                ),
                              ),
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Iconify(
                                GameIcons.flower_pot,
                                size: iconSize,
                              ),
                              Text(
                                'Iris',
                                style: TextStyle(fontSize: textSize),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double iconSize = constraints.maxWidth / 3;
                        double textSize = constraints.maxWidth / 10;
                        return FloatingActionButton(
                          heroTag: hero2,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SecondPage(
                                    dato: "Diabetes",
                                    hero: hero2,
                                    hero2: hero3,
                                    dataset: "diabetes2.dt"),
                              ),
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Iconify(Healthicons.diabetes_measure,
                                  size: iconSize),
                              Text(
                                'Diabetes 2',
                                style: TextStyle(fontSize: textSize),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double iconSize = constraints.maxWidth / 3;
                        double textSize = constraints.maxWidth / 10;
                        return FloatingActionButton(
                          heroTag: hero3,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SecondPage(
                                    dato: "Hearth",
                                    hero: hero3,
                                    hero2: hero2,
                                    dataset: "heartNorm.csv"),
                              ),
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Iconify(MaterialSymbols.heart_plus,
                                  size: iconSize),
                              Text(
                                'HearthNorm',
                                style: TextStyle(fontSize: textSize),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double iconSize = constraints.maxWidth / 3;
                        double textSize = constraints.maxWidth / 10;
                        return FloatingActionButton(
                          heroTag: hero4,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SecondPage(
                                    dato: "UCIC",
                                    hero: hero4,
                                    hero2: hero1,
                                    dataset: "UCICarduicography3ClassNorm.csv"),
                              ),
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Iconify(IconParkSolid.electrocardiogram,
                                  size: iconSize),
                              Text(
                                'UCICardiography',
                                style: TextStyle(fontSize: textSize),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
