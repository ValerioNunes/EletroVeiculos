import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eletroveiculos/models/veiculo.dart';

class MapView extends StatefulWidget {
  @override
  State<MapView> createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  static const LatLng _center = const LatLng(-6.058519116235293, -45.102117732167244);
  Firestore database = Firestore.instance;
  static String collection = 'Veiculos';
  List<Veiculo> _modelList;
  bool viewAll = true;
  String tipoFilter = "";

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: _center,
    zoom: 5.7084760665893555,
  );

  LatLng _lastMapPosition =  _center;

  @override
  void initState() {
    super.initState();

    database.collection(collection).snapshots().listen((data) {
      if (mounted){
        _modelList = new List<Veiculo>();
        data.documents.forEach((doc) {
          _addModelList(doc);
        });
        _modelList.sort((a, b) => a.tipo.compareTo(b.tipo));
        _updateMap();
      }
    });
  }

 _updateMap(){
     setState(() {
       _markers.clear();
     });
    _modelList.forEach((f) {
      if(viewAll || f.tipo.toUpperCase() == tipoFilter.toUpperCase()) {
        if (f.local_atual.nome != "") {
          final pos = LatLng(f.local_atual.latitude, f.local_atual.longitude);
          setState(() {
            _markers.add(Marker(
                markerId: MarkerId(f.placa),
                position: pos,
                infoWindow: InfoWindow(
                  title: f.tipo ,
                  snippet: f.local_atual.nome+ " " + f.placa,
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    (f.tipo == "MUNCK") ? BitmapDescriptor.hueBlue : (f.tipo ==
                        "HILUX SOCAGE")
                        ? BitmapDescriptor.hueYellow
                        : BitmapDescriptor
                        .hueOrange) //BitmapDescriptor.defaultMarker,
            ));
          });
        }
      }
    });

 }

  _addModelList(DocumentSnapshot doc) {
    _modelList.add(Veiculo.fromSnapshot(doc));
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
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
      body: Column(
        children : [
          new Text("Selecine tipo de veículo:",style: Theme.of(context).textTheme.display2),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children : [
            FilterChip(
            label: Text("TUDO" , style: Theme.of(context).textTheme.display2,),
            shape: StadiumBorder(side: BorderSide()),
            backgroundColor: Colors.black38,
            selectedColor: Colors.green,
            selected: viewAll,
            onSelected: (bool value) {  setState(() {
              viewAll = true;
              tipoFilter = "";
              _updateMap();
            }); }),
            FilterChip(
                label: Text("MUNCK" , style: Theme.of(context).textTheme.display2,),
                shape: StadiumBorder(side: BorderSide()),
                backgroundColor: Colors.black38,
                selectedColor: Colors.blue,
                selected: tipoFilter == "MUNCK",
                onSelected: (bool value) {  setState(() {
                  viewAll =  false;
                  tipoFilter = "MUNCK";
                  _updateMap();
                }); }),
            FilterChip(
                label: Text("HILUX SOCAGE" , style: Theme.of(context).textTheme.display2,),
                shape: StadiumBorder(side: BorderSide()),
                backgroundColor: Colors.black38,
                selectedColor: Colors.yellow[300],
                selected: tipoFilter == "HILUX SOCAGE",
                onSelected: (bool value) {  setState(() {
                  viewAll =  false;
                  tipoFilter = "HILUX SOCAGE";
                  _updateMap();
                }); }),
            FilterChip(
                label: Text("SKY MUNCK" , style: Theme.of(context).textTheme.display2,),
                shape: StadiumBorder(side: BorderSide()),
                backgroundColor: Colors.black38,
                selectedColor: Colors.orange,
                selected: tipoFilter == "SKY MUNCK",
                onSelected: (bool value) {  setState(() {
                  viewAll =  false;
                  tipoFilter = "SKY MUNCK";
                  _updateMap();
                }); }),
          ]),

          Expanded(child: GoogleMap(
            mapType: MapType.normal,
            markers: _markers,
            initialCameraPosition: _kGooglePlex,
            onCameraMove: _onCameraMove,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ))
        ]),
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

  void _onAddMarkerButtonPressed() async {

    final LatLng meuLocal =   await getUserLocation();

    setState(() {
      _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId(_lastMapPosition.toString()),
        position: meuLocal,

        infoWindow: InfoWindow(
          title: 'Really cool place',
          snippet: '5 Star Rating',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }
}