import 'package:app/pages/first_page.dart';
import 'package:flutter/material.dart';
import 'package:app/components/consultasmongo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConsultasMongo.connectar();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(colorSchemeSeed: Colors.blue),
        debugShowCheckedModeBanner: false,
        title: "AO_EX parametrizer",
        home: FirstPage());
  }
}
