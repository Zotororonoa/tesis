import 'package:flutter/material.dart';
import 'package:app/pages/datasets.dart';
import 'package:app/pages/historial.dart';
import 'package:app/pages/NDataset.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  int currentPage = 0;
  String titulo = 'Datasets Predeterminados';
  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [Datasets(), NuevoDataset(), Historial()];
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
      ),
      body: Center(child: pages[currentPage]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPage,
        onDestinationSelected: (value) {
          setState(() {
            if (value == 0) {
              titulo = 'Datasets Predeterminados';
            } else if (value == 2) {
              titulo = 'Historial';
            } else if (value == 1) {
              titulo = 'Nuevo Dataset';
            }
            currentPage = value;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(
              icon: Icon(Icons.add_circle), label: 'Nuevo dataset'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Historial'),
        ],
      ),
    );
  }
}
