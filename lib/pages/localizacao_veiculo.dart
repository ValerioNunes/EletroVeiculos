import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:google_maps_webservice/places.dart';
import 'package:geolocator/geolocator.dart';


const kGoogleApiKey = "AIzaSyAurKUpzACtdST20AD9Phw7YEI1a3viO6Y";
GoogleMapsPlaces _places =    GoogleMapsPlaces(apiKey: kGoogleApiKey);
final places1 = new GoogleMapsPlaces(apiKey: kGoogleApiKey);


class LocalizacaoVeiculo extends StatefulWidget {
  @override
  State<LocalizacaoVeiculo> createState() => LocalizacaoVeiculoState();
}

class LocalizacaoVeiculoState extends State<LocalizacaoVeiculo> {
  Completer<GoogleMapController> _controller = Completer();
  final LocalViewScaffoldKey = GlobalKey<ScaffoldState>();

  final Set<Marker> _markers = {};
  static const LatLng _center = const LatLng(-6.058519116235293, -45.102117732167244);
  List<PlacesSearchResult> places = [];
  LatLng meuLocal = _center;
  LatLng _lastMapPosition =  _center;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: _center,
    zoom: 5.7084760665893555,
  );


  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
    print(position);
  }

  Future<LatLng> getUserLocation() async {
    var currentLocation ;
    final location = LocationManager.Location();
    try {
      currentLocation = await location.getLocation();

      final lat = currentLocation.latitude;
      final lng = currentLocation.longitude;
      final center = LatLng(lat, lng);

      return center;
    } on Exception {
      currentLocation = null;
      return null;
    }
  }

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(2.313296265331129, 44.18832357078792),
      tilt: 59.440717697143555,
      zoom: 5.151926040649414);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: LocalViewScaffoldKey,
      appBar: AppBar(
        title: Text('Localização do Veículo'),
        actions: <Widget>[
          new FlatButton(
              child: new Text('Confirmar',
                  style: new TextStyle(fontSize: 17.0, color: Colors.white)),
              onPressed: () { Navigator.pop(context,  meuLocal ); }  )
        ],
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        markers: _markers,
        initialCameraPosition: _kGooglePlex,
        onCameraMove: _onCameraMove,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAddMarkerButtonPressed,
        label: Text('Meu Local'),
        icon: Icon(Icons.adjust),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
  void onError(PlacesAutocompleteResponse response) {
    LocalViewScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  void getNearbyPlaces(LatLng center) async {

    final location = Location(center.latitude, center.longitude);

    //final result = await _places.searchNearbyWithRadius(location, 7);
    PlacesSearchResponse reponse = await places1.searchNearbyWithRadius(location, 500);
    List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(center.latitude, center.longitude);
    List<Placemark> placemark1 = await Geolocator().placemarkFromAddress("São Luis");
   // placemark[0].name
    print(placemark1[0].locality);
//    setState(() {
//      if (result.status == "OK") {
//        this.places = result.results;
//        print(result.results.length);
//        if(result.results.length > 0){
//          var f = result.results[0];
//          _markers.add(Marker(
//            // This marker id can be anything that uniquely identifies each marker.
//            markerId: MarkerId(_lastMapPosition.toString()),
//            position: LatLng(f.geometry.location.lat, f.geometry.location.lng),
//            infoWindow: InfoWindow(
//              title: f.name,
//              snippet: f.types?.first,
//            ),
//            icon: BitmapDescriptor.defaultMarker,
//
//          ));
//        }
////        result.results.forEach((f) {
////
////          _markers.add(Marker(
////            // This marker id can be anything that uniquely identifies each marker.
////            markerId: MarkerId(_lastMapPosition.toString()),
////            position: LatLng(f.geometry.location.lat, f.geometry.location.lng),
////            infoWindow: InfoWindow(
////              title: f.name,
////              snippet: f.types?.first,
////            ),
////            icon: BitmapDescriptor.defaultMarker,
////
////          ));
//
////          final markerOptions = MarkerOptions(
////              position:
////              LatLng(f.geometry.location.lat, f.geometry.location.lng),
////              infoWindowText: InfoWindowText("${f.name}", "${f.types?.first}"));
////          mapController.addMarker(markerOptions);
// //       });
//      } else {
//        print(result.errorMessage);
//      }
//    });
  }
  void _onAddMarkerButtonPressed() async {
     meuLocal =   await getUserLocation();

    setState(() {
     getNearbyPlaces(meuLocal);
    });
  }
}