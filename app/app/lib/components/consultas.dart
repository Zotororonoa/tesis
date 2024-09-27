import 'dart:convert';
import 'package:http/http.dart' as http;

String direccion = "127.0.0.1:5000";

class Consultas {
  Future<String> postAlgoritmo(String? algoritmo, int neurons, String vari,
      int paso, String nombre_archivo, int? n, int? t) async {
    Uri url;
    String json;
    if (algoritmo == "Exhaustiva") {
      url = Uri.http(direccion, "/start_task");
      Map<String, dynamic> data = {
        "M": 0.8,
        "neurons": neurons,
        "entradaBD": nombre_archivo,
        "var": vari,
        "paso": paso
      };
      json = jsonEncode(data);
    } else if (algoritmo == "aquila" && n != null && t != null) {
      url = Uri.http(direccion, "/start_aquila_task");
      Map<String, dynamic> data = {
        "M": 0.8,
        "neurons": 120,
        "entradaBD": nombre_archivo,
        "var": vari,
        "paso": paso,
        "N": n,
        "T": t
      };
      json = jsonEncode(data);
    } else {
      throw ArgumentError("Algoritmo desconocido: $algoritmo");
    }

    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json,
      );
      String task_id =
          response.body.substring(16, response.body.length - 4).toString();
      return task_id;
    } catch (e) {
      print('fallo al enviar: $e');
    }
    return '';
  }

  Future<String> postArchivo(String base64, String nombre) async {
    Map<String, dynamic> archivo = {'base64': "", 'filename': ""};
    archivo["base64"] = base64;
    archivo["filename"] = nombre;
    String json = jsonEncode(archivo);
    Uri url;

    try {
      url = Uri.http(direccion, "/upload_csv");

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json,
      );

      return response.body;
    } catch (e) {
      print('fallo al enviar: $e');
    }
    return '';
  }

  Future<String> postContar(String nombreArchivo) async {
    Uri url;
    url = Uri.http(direccion, "/start_archivos_task");
    Map<String, dynamic> contar = {'nombre_archivo': ""};
    contar['nombre_archivo'] = nombreArchivo;

    try {
      String json = jsonEncode(contar);

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json,
      );

      return response.body;
    } catch (e) {
      print('fallo al enviar: $e');
    }
    return '';
  }

  Future<String> postnormalizado(
      String base64, String nombreArchivo, String normalizacion) async {
    Uri url;
    url = Uri.http(direccion, "/normalizar_csv");
    Map<String, dynamic> archivo = {
      "base64_csv": base64,
      "tipo_normalizacion": normalizacion,
      "nombre_archivo_salida": nombreArchivo
    };
    try {
      String json = jsonEncode(archivo);

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json,
      );

      return response.body;
    } catch (e) {
      print('fallo al enviar: $e');
    }
    return '';
  }
}
