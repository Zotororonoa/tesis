import 'dart:convert';
import 'package:http/http.dart' as http;

String direccion = "127.0.0.1:5000";

Map<String, dynamic> data = {"N": 10, "T": 10, "UB": 0};

class Consultas {
  Future<String> postAlgoritmo(String algoritmo, int value) async {
    data["UB"] = value;
    String json = jsonEncode(data);
    Uri url;

    if (algoritmo == "Exhaustiva") {
      url = Uri.http(direccion, "/start_task");
    } else if (algoritmo == "aquila") {
      url = Uri.http(direccion, "/start_aquila_task");
    } else {
      throw ArgumentError("Algoritmo desconocido: $algoritmo");
    }

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json,
    );

    String task_id =
        response.body.substring(16, response.body.length - 4).toString();
    print(task_id);
    return task_id;
  }
}
