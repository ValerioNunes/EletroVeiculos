import 'package:flutter/material.dart';
import 'package:eletroveiculos/models/veiculo.dart';
import 'package:eletroveiculos/models/usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eletroveiculos/services/crud.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'nota_list.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:geolocator/geolocator.dart';
import 'package:eletroveiculos/models/local.dart';
import 'package:eletroveiculos/models/nota.dart';

import 'pesquisa_local.dart';

class VeiculoView extends StatefulWidget {
  VeiculoView({
    Key key,
    this.user,
    this.model,
  }) : super(key: key);
  Veiculo model;
  Usuario user;

  @override
  State<StatefulWidget> createState() => new _VeiculoViewState();
}

enum FormMode { EDIT, VIEW }

class _VeiculoViewState extends State<VeiculoView> {
  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentLocal;
  bool gps_status = false;
  Firestore database = Firestore.instance;
  static String collection = 'Veiculos';
  CrudMedthods crud = new CrudMedthods(collection);
  int _selectedDrawerIndex = 1;

  int currStep = 0;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController _tipo = new TextEditingController();
  TextEditingController _placa = new TextEditingController();
  TextEditingController _modelo = new TextEditingController();
  TextEditingController _patrimonio   = new TextEditingController();
  TextEditingController _renavan  = new TextEditingController();
  TextEditingController _chassi  = new TextEditingController();
  TextEditingController _codigo_sap  = new TextEditingController();
  TextEditingController _capacidade_carga = new TextEditingController();

  TextEditingController _km_atual = new TextEditingController();
  TextEditingController _km_ultima_revisao = new TextEditingController();
  TextEditingController _km_proxima_revisao = new TextEditingController();
  var _data_ultima_revisao = new MaskedTextController(mask: '0000-00-00');

  TextEditingController _sede_titular = new TextEditingController();
  TextEditingController _local_atual = new TextEditingController();

  var _validade_bengala = new MaskedTextController(mask: '0000-00-00');
  var _validade_teste_fumaca = new MaskedTextController(mask: '0000-00-00');
  var _validade_afericao = new MaskedTextController(mask: '0000-00-00');
  var _venc_licenciamento = new MaskedTextController(mask: '0000-00-00');

  _setModel() {
    _tipo.text = widget.model.tipo;
    _placa.text = widget.model.placa;
    _modelo.text = widget.model.modelo;
    _chassi.text  = widget.model.chassi;
    _renavan.text = widget.model.renavan;
    _patrimonio.text = widget.model.patrimonio;
    _codigo_sap.text = widget.model.codigo_sap;
    _capacidade_carga.text = widget.model.capacidade_carga;

    _km_atual.text = widget.model.km_atual;
    _km_ultima_revisao.text = widget.model.km_ultima_revisao;
    _km_proxima_revisao.text = widget.model.km_proxima_revisao;
    _data_ultima_revisao.text = widget.model.data_ultima_revisao;

    _sede_titular.text = widget.model.sede_titular;
    _local_atual.text = widget.model.local_atual.nome;

    _validade_bengala.text = widget.model.validade_bengala;
    _validade_teste_fumaca.text = widget.model.validade_teste_fumaca;
    _validade_afericao.text = widget.model.validade_afericao;
    _venc_licenciamento.text = widget.model.venc_licenciamento;
  }

  _navigateAndDisplaySelection(BuildContext context, {meuLocal: false}) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    if (meuLocal) {
      setState(() {
        gps_status = true;
      });

      var location = await getUserLocation();
      List<Placemark> lvplacemark = await Geolocator()
          .placemarkFromCoordinates(location.latitude, location.longitude);

      gps_status = false;

      if (lvplacemark.length > 0) {
        try {
          setState(() {
            widget.model.local_atual = Local.fromPlace(lvplacemark[0]);
          });
        } catch (e) {}
      }
    } else {
      var result = await Navigator.push(
        context,
        // Create the SelectionScreen in the next step.
        MaterialPageRoute(builder: (context) => Search(title: "Localização")),
      );

      setState(() {
        try {
          if (result != null) {
            widget.model.local_atual = result;
            _local_atual.text = result.nome;
          }
        } catch (e) {}
      });
    }
  }

  List<Step> getSteps() {
    return [
      new Step(
          isActive: currStep == 0,
          title: const Text('Localização'),
          state: StepState.indexed,
          content: Column(children: <Widget>[
            ListTile(
              title: Text(
                "Local Atual",
                style: Theme.of(context).textTheme.body1,
              ),
              subtitle: Text(widget.model.local_atual.nome),
              trailing: (widget.model.local_atual.nome != "")
                  ? Icon(
                      Icons.location_on,
                      color: Colors.red,
                    )
                  : Icon(
                      Icons.location_off,
                      color: Colors.black,
                    ),
            ),
            (gps_status) ? _showCircularProgress() : Container(),
            Row(children: [
              RaisedButton(
                elevation: 5.0,
                padding: const EdgeInsets.all(4.0),
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                color: Colors.green,
                child: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                onPressed: () {
                  _navigateAndDisplaySelection(context);
                },
              ),
              RaisedButton(
                elevation: 5.0,
                padding: const EdgeInsets.all(4.0),
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                color: Colors.blueAccent,
                child: Icon(
                  Icons.gps_fixed,
                  color: Colors.white,
                ),
                onPressed: () {
                  _navigateAndDisplaySelection(context, meuLocal: true);
                },
              )
            ])
          ])),
      new Step(
          isActive: currStep == 1,
          title: const Text('Quilometragem'),
          state: StepState.indexed,
          content: Column(children: <Widget>[
            new TextFormField(
                controller: _km_atual,
                decoration: const InputDecoration(
                  icon: const Icon(Icons.compare_arrows),
                  hintText: 'Km Atual',
                  labelText: 'Km Atual',
                ),
                //validator: (value) => value.isEmpty ? 'Valor inválida !' : null,
                keyboardType: TextInputType.number,
                onSaved: (String value) {
                  this.widget.model.km_atual = value;
                }),
            new TextFormField(
                controller: _km_ultima_revisao,
                decoration: const InputDecoration(
                  icon: const Icon(Icons.compare_arrows),
                  hintText: 'Km Ultima Revisão',
                  labelText: 'Km Ultima Revisão ',
                ),
                //validator: (value) => value.isEmpty ? 'Valor inválida !' : null,
                keyboardType: TextInputType.number,
                onSaved: (String value) {
                  this.widget.model.km_ultima_revisao = value;
                }),
            new TextFormField(
                controller: _km_proxima_revisao,
                decoration: const InputDecoration(
                  icon: const Icon(Icons.compare_arrows),
                  hintText: 'Km Próxima Revisão',
                  labelText: 'Km Próxima Revisão',
                ),
                //validator: (value) => value.isEmpty ? 'Valor inválida !' : null,
                keyboardType: TextInputType.number,
                onSaved: (String value) {
                  this.widget.model.km_proxima_revisao = value;
                }),
            new TextFormField(
                controller: _data_ultima_revisao,
                decoration: const InputDecoration(
                  icon: const Icon(Icons.calendar_today),
                  hintText: 'AAAA-MM-DD',
                  labelText: 'Data Ultima Revisão ',
                ),
                //validator: (value) => value.isEmpty ? 'Data inválida !' : null,
                keyboardType: TextInputType.number,
                onSaved: (String value) {
                  this.widget.model.data_ultima_revisao = value;
                }),
          ])),
      new Step(
          title: const Text('Validades do Veículo (AAAA-MM-DD)'),
          //subtitle: const Text('Enter your name'),
          isActive: currStep == 2,
          //state: StepState.error,

          state: StepState.indexed,
          content: Column(children: <Widget>[
            new TextFormField(
                controller: _validade_bengala,
                decoration: const InputDecoration(
                  icon: const Icon(Icons.calendar_today),
                  hintText: 'AAAA-MM-DD',
                  labelText: 'Validade Bengala ',
                ),
                //validator: (value) => value.isEmpty ? 'Data inválida !' : null,
                keyboardType: TextInputType.number,
                onSaved: (String value) {
                  this.widget.model.validade_bengala = value;
                }),
            new TextFormField(
                controller: _validade_teste_fumaca,
                decoration: const InputDecoration(
                  icon: const Icon(Icons.calendar_today),
                  hintText: 'AAAA-MM-DD',
                  labelText: 'Validade Teste Fumaça ',
                ),
                //validator: (value) => value.isEmpty ? 'Data inválida !' : null,
                keyboardType: TextInputType.number,
                onSaved: (String value) {
                  this.widget.model.validade_teste_fumaca = value;
                }),
            new TextFormField(
                controller: _validade_afericao,
                decoration: const InputDecoration(
                  icon: const Icon(Icons.calendar_today),
                  hintText: 'AAAA-MM-DD',
                  labelText: 'Validade Aferição ',
                ),
                //validator: (value) => value.isEmpty ? 'Data inválida !' : null,
                keyboardType: TextInputType.number,
                onSaved: (String value) {
                  this.widget.model.validade_afericao = value;
                }),
            new TextFormField(
                controller: _venc_licenciamento,
                decoration: const InputDecoration(
                  icon: const Icon(Icons.calendar_today),
                  hintText: 'AAAA-MM-DD',
                  labelText: 'Validade Licenciamento ',
                ),
                //validator: (value) => value.isEmpty ? 'Data inválida !' : null,
                keyboardType: TextInputType.number,
                onSaved: (String value) {
                  this.widget.model.venc_licenciamento = value;
                }),
          ])),
      new Step(
          title: const Text('Dados do Veículo'),
          //subtitle: const Text('Enter your name'),
          isActive: currStep == 3,
          //state: StepState.error,
          state: StepState.indexed,
          content: Column(children: <Widget>[
            new TextFormField(
                controller: _tipo,
                decoration: const InputDecoration(
                  icon: const Icon(Icons.directions_car),
                  hintText: 'Tipo Veiculo',
                  labelText: 'Tipo Veiculo',
                ),
                enabled: false,
                //validator: (value) =>value.isEmpty ? 'Digite o tipo do Veiculo' : null,
                onSaved: (String value) {
                  this.widget.model.tipo = value;
                }),
            new TextFormField(
                controller: _placa,
                enabled: false,
                decoration: const InputDecoration(
                  icon: const Icon(Icons.aspect_ratio),
                  hintText: 'Placa',
                  labelText: 'Placa',
                ),
                //validator: (value) => value.isEmpty ? 'Digite a placa' : null,
                keyboardType: TextInputType.number,
                onSaved: (String value) {
                  this.widget.model.placa = value;
                }),
            new TextFormField(
                controller: _modelo,
                enabled: false,
                decoration: const InputDecoration(
                  icon: const Icon(Icons.assignment),
                  hintText: 'Modelo',
                  labelText: 'Modelo',
                ),
                //validator: (value) => value.isEmpty ? 'Digite a Modelo' : null,
                keyboardType: TextInputType.number,
                onSaved: (String value) {
                  this.widget.model.modelo = value;
                }),
            new TextFormField(
                controller: _patrimonio,
                enabled: false,
                decoration: const InputDecoration(
                  icon: const Icon(Icons.assignment),
                  hintText: 'Patrimonio',
                  labelText: 'Patrimonio',
                ),
                //validator: (value) => value.isEmpty ? 'Digite a patrimonio' : null,
                keyboardType: TextInputType.number,
                onSaved: (String value) {
                  this.widget.model.patrimonio = value;
                }),
            new TextFormField(
                controller: _renavan,
                enabled: false,
                decoration: const InputDecoration(
                  icon: const Icon(Icons.assignment),
                  hintText: 'Renavan',
                  labelText: 'Renavan',
                ),
                //validator: (value) => value.isEmpty ? 'Digite a renavan' : null,
                keyboardType: TextInputType.number,
                onSaved: (String value) {
                  this.widget.model.renavan = value;
                }),
            new TextFormField(
                controller: _chassi,
                enabled: false,
                decoration: const InputDecoration(
                  icon: const Icon(Icons.assignment),
                  hintText: 'Chassi',
                  labelText: 'Chassi',
                ),
                //validator: (value) => value.isEmpty ? 'Digite a Chassi' : null,
                keyboardType: TextInputType.number,
                onSaved: (String value) {
                  this.widget.model.chassi = value;
                }),
            new TextFormField(
                controller: _codigo_sap,
                enabled: false,
                decoration: const InputDecoration(
                  icon: const Icon(Icons.assignment),
                  hintText: 'Codigo_sap',
                  labelText: 'Codigo_sap',
                ),
                //validator: (value) => value.isEmpty ? 'Digite a codigo_sap' : null,
                keyboardType: TextInputType.number,
                onSaved: (String value) {
                  this.widget.model.codigo_sap = value;
                }),
            new TextFormField(
                controller: _capacidade_carga,
                enabled: false,
                decoration: const InputDecoration(
                  icon: const Icon(Icons.assignment),
                  hintText: 'Capacidade_carga',
                  labelText: 'Capacidade_carga',
                ),
                //validator: (value) => value.isEmpty ? 'Digite a Capacidade_carga' : null,
                keyboardType: TextInputType.number,
                onSaved: (String value) {
                  this.widget.model.capacidade_carga = value;
                }),
          ])),
    ];
  }

  getUserLocation() async {
    var currentLocation;
    final location = LocationManager.Location();
    try {
      currentLocation = await location.getLocation();

      return currentLocation;
    } on Exception {
      currentLocation = null;
      return null;
    }
  }

  _getDrawerItemWidget(int pos, BuildContext context) {
    switch (pos) {
      case 1:
        _setModel();
        return _showCadEdt(context);
      default:
        return new Text("Error");
    }
  }

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
  }

  _addNewModel(Veiculo model) {
    if (model != null) {
      crud.addData(model);
    }
  }

  _updateModel(Veiculo model) {
    //Toggle completed
    if (model != null) {
      print(model.toJson());
      crud.updateData(model);
    }
  }

  bool submit(BuildContext context) {
    // First validate form.
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save(); // Save our form now.

      if (widget.model.uid != "") {
        _updateModel(widget.model);
        _showInfo(context, "Salvo com Sucesso!");
      }
      return true;
    }
    _showInfo(context, "Ops, Alguns dados estão inválidos!");
    return false;
  }

  void _showInfo(BuildContext context, String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Info"),
          content: new Text(msg),
          actions: <Widget>[
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    Firestore.instance
        .collection(collection)
        .document(widget.model.uid)
        .get()
        .then((visitorSnapshot) {
          print(visitorSnapshot.documentID);
      if (mounted) {
        widget.model = Veiculo.fromSnapshot2(visitorSnapshot);
        setState(() {
          _setModel();
        });
      }
    }).catchError((error) {

      print("Erro " + error.toString());
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  BoxDecoration myBoxDecoration() {
    return new BoxDecoration(
      color: Colors.white,
      shape: BoxShape.rectangle,
      borderRadius: new BorderRadius.circular(10.0),
      boxShadow: <BoxShadow>[
        new BoxShadow(
          color: Colors.black12,
          blurRadius: 20.0,
          //offset: new Offset(20.0, 20.0),
        ),
      ],
    );
  }

  Widget _showLogo() {
    return Card(
      child: Image.asset(
        'img/truck-icon.png',
        fit: BoxFit.cover,
        width: 100.0,
        height: 160.0,
      ),
    );
  }

  Widget imagemFirebase(String imageLink) {
    Widget img;
    try {
      img = Image.network(
        imageLink,
        width: 100.0,
        height: 160.0,
      );
      return _showLogo();
    } catch (e) {
      return null;
    }
  }

  Widget _listNotas(BuildContext context) {

    if (widget.model.notas != null) {
      print(widget.model.notas.length);
      return ListView.builder(
        itemCount: widget.model.notas.length,
        itemBuilder: (context, index) {
          Nota nota = Nota.fromSnapshot(widget.model.notas[index]);
          return Container(
              margin: new EdgeInsets.only(left: 2.0, right: 2.0, top: 5.0),
              //decoration: myBoxDecoration(),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /*2*/
                    ListTile(
                      // leading: imagemFirebase(nota.image),
                      title: Text(
                        nota.tipo,
                        style: Theme.of(context).textTheme.display1,
                      ),
                      subtitle: Text(nota.status,
                          style: Theme.of(context).textTheme.display2),
                      trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.green,
                                 // size: 35,
                                ),
                                onPressed: () {}),
                          ]),
                    ),
                  ]));
        },
      );
    } else
      return Container();
  }

  Widget _showCadEdt(BuildContext context) {
    return new Form(
        key: this._formKey,
        autovalidate: true,
        child: new ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: <Widget>[
            new Container(
              child: new Text(
                widget.model.tipo + " - Placa: " + widget.model.placa,
                style: Theme.of(context).textTheme.display1,
              ),
              margin: new EdgeInsets.only(top: 20.0),
            ),
            new Stepper(
              physics: ClampingScrollPhysics(),
              steps: getSteps(),
              type: StepperType.vertical,
              currentStep: this.currStep,
              onStepContinue: () {
                setState(() {
                  if (currStep < getSteps().length - 1) {
                    currStep = currStep + 1;
                  } else {
                    currStep = 0;
                  }
                });
              },
              onStepCancel: () {
                setState(() {
                  if (currStep > 0) {
                    currStep = currStep - 1;
                  } else {
                    currStep = 0;
                  }
                });
              },
              onStepTapped: (step) {
                setState(() {
                  currStep = step;
                });
              },
            ),
          ],
        ));
  }

  Widget _showCircularProgress() {
    return Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar:  new AppBar(title: new Text("Ficha do Veículo"), actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            color: Colors.white,
            iconSize: 32,
            onPressed: () => (submit(context)),
          ),
        ]),
        floatingActionButton: FloatingActionButton.extended(
          //onPressed: _onAddMarkerButtonPressed,
          label: Text('Nota'),
          icon: Icon(Icons.library_books),
          onPressed: () {
            var result = Navigator.push(
              context,
              // Create the SelectionScreen in the next step.
              MaterialPageRoute(
                  builder: (context) => NotaList(
                        model: widget.model,
                        user: widget.user,
                      )),
            );
          },
        ),
        body: _getDrawerItemWidget(_selectedDrawerIndex, context));
  }
}
