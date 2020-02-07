import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
class Local{

  String nome = "";
  double latitude = 0;
  double longitude = 0;
  DateTime data =  DateTime.now();

  Local();
  Local.fromPlace(Placemark place):
      nome = ((place.subAdministrativeArea !=  place.name) ? place.name : "" )+" "+ place.subAdministrativeArea +" "+ place.administrativeArea,
      longitude = place.position.longitude,
      latitude = place.position.latitude;


  Local.fromSnapshot(snapshot):
        nome = snapshot["nome"],
        longitude = snapshot["longitude"],
        latitude = snapshot["latitude"],
        data = DateTime.parse(snapshot["data"]);

  toJson() {
    return {
      "nome":nome,
      "longitude":longitude,
      "latitude":latitude,
      "data" : data.toIso8601String(),
    };
  }
}