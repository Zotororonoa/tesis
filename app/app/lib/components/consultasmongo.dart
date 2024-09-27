import "package:mongo_dart/mongo_dart.dart";

class ConsultasMongo {
  static Db? db;
  static DbCollection? exhaustiva_tasks, AO_tasks;

  static Future<void> connectar() async {
    db = await Db.create("mongodb://localhost:27017/tasks_db");
    await db!.open();
    if (db!.state == State.open) {
      exhaustiva_tasks = db!.collection('exhaustiva_tasks');
      AO_tasks = db!.collection('AO_tasks');
    } else {
      print("No se pudo conectar a la base de datos");
    }
  }

  static Future<List<Map<String, dynamic>>> obtenerAlgoritmosE() async {
    final algoritmos = await exhaustiva_tasks!.find().toList();
    return algoritmos;
  }

  static Future<List<Map<String, dynamic>>> obtenerAlgoritmosAO() async {
    final algoritmos = await AO_tasks!.find().toList();
    return algoritmos;
  }
}
