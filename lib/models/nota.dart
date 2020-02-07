import 'usuario.dart';

class Nota{
  int uid =  0;
  String tipo = "";
  String descricao = "";
  String image = "";
  String status = "";
  Usuario usuario =  null;
  DateTime dateTime = DateTime.now();

  static DateTime stringToDatetime(String d){
    try {
      return DateTime.parse(d);
    }catch(e){
      print(e);
      return DateTime.now();
    }
  }


  Nota();
  
  Nota.fromSnapshot(snapshot):
        uid = snapshot["uid"],
        tipo = snapshot["tipo"],
        status = snapshot["status"],
        image = snapshot["image"],
        dateTime = stringToDatetime(snapshot["dateTime"]),
        usuario = Usuario.fromSnapshot(snapshot["usuario"]),
        descricao = snapshot["descricao"];

  toJson() {
    return {
      "uid" : uid,
      "tipo": tipo,
      "status": status,
      "descricao": descricao,
      "image" : image,
      "dateTime": dateTime.toIso8601String(),
      "usuario" : usuario.toJson()
    };
  }
}