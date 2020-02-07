import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:google_maps_webservice/places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:eletroveiculos/models/local.dart';

class Search extends StatefulWidget {
  Search({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _SearchState createState() => new _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController editingController = TextEditingController();
  String filter = "";
  List<Placemark> placemark = null;

  @override
  void initState() {
    super.initState();
  }

  _updateItens() async {

    try {
      List<Placemark> lvplacemark = await Geolocator().placemarkFromAddress(filter);
      setState(() {
          placemark = lvplacemark;
        });

    } catch (e) {
      print(e);
    }
  }

  Widget _showCircularProgress() {
    return Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Row(children: [
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(9.0),
                    child: TextField(
                      onChanged: (value) {
                        filter = value;
                      },
                      controller: editingController,
                      decoration: InputDecoration(
                          labelText: "Pesquisar Local",
                          hintText:  "Pesquisar Local",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25.0)))),
                    )),
              ),
              new RaisedButton(
                elevation: 5.0,
                padding: const EdgeInsets.all(4.0),
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                color: Colors.green,
                child: Icon( Icons.search , color: Colors.white,),
                onPressed: _updateItens,
              )
            ]),
            Expanded(
              child: (placemark != null) ? ListView.builder(
                itemCount: placemark.length,
                itemBuilder: (context, index) {
                  Placemark place = placemark[index];

                  return ListTile(
                    title: Text(place.name),
                    subtitle: Text(place.subAdministrativeArea +" "+ place.administrativeArea +" "+ place.country),
                    trailing: IconButton(
                        icon: Icon(
                          Icons.add_location,
                          color: Colors.black,
                        )),
                    onTap:() {
                      {  Navigator.pop(context, Local.fromPlace(place) ); }
                    },
                  );
                },
              ) : Container()
            ),
          ],
        ),
      ),
    );
  }
}
