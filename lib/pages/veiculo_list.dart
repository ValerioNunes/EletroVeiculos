import 'package:flutter/material.dart';
import 'package:eletroveiculos/models/veiculo.dart';
import 'package:eletroveiculos/models/usuario.dart';
import 'package:eletroveiculos/pages/veiculo_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eletroveiculos/services/crud.dart';

import 'package:intl/intl.dart';

enum EvStatus { NAO_INSCRITO, INSCRITO, LISTA_ESPERA, SEM_VAGAS }

class CadVeiculo extends StatefulWidget {
  CadVeiculo({
    Key key,
    this.userId,
    this.user,
  }) : super(key: key);
  final String userId;
  final Usuario user;

  @override
  State<StatefulWidget> createState() => new _CadVeiculoState();
}

class _CadVeiculoState extends State<CadVeiculo> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  Firestore database = Firestore.instance;
  static String collection = 'Veiculos';
  CrudMedthods crud = new CrudMedthods(collection);

  List<Veiculo> _modelList;
  Veiculo _model = new Veiculo();
  bool viewAll = true;
  String viewFilter = "";

  TextEditingController _filter = new TextEditingController();

  void _showInfo(BuildContext context, String msg, {String info = "Info"}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(info,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: new Text(msg,
              textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
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

    database.collection(collection).snapshots().listen((data) {
      if (mounted) {
        _modelList = new List<Veiculo>();
        data.documents.forEach((doc) {
          setState(() => _addModelList(doc));
        });

        _modelList.sort((a, b) => a.tipo.compareTo(b.tipo));
      }
    });

    _filter = new TextEditingController();
    _filter.addListener(() {
      setFilter(_filter.text);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _addModelList(DocumentSnapshot doc) {
    _model = Veiculo.fromSnapshot(doc);
    _modelList.add(_model);
  }

  Widget _showCircularProgress() {
    return Center(child: CircularProgressIndicator());
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
    return Hero(
      tag: 'hero',
      child: Card(
        child: Image.asset(
          'img/truck-icon.png',
          fit: BoxFit.cover,
          width: 100.0,
          height: 160.0,
        ),
      ),
    );
  }

  Widget _getImg(String img) {
    return Card(
      child: Image.asset(
        img,
        fit: BoxFit.cover,
        width: 100.0,
        height: 160.0,
      ),
    );
  }

  Widget imagemVeiculo(Veiculo Veiculo) {
    Widget img;
    try {
      img = Image.network(
        Veiculo.getImageLocal(),
        width: 100.0,
        height: 160.0,
      );
    } catch (e) {
      img = _showLogo();
    }
    return img;
  }

  _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      // Create the SelectionScreen in the next step.
      MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => VeiculoView(model: _model, user: widget.user)),
    );
  }

  Widget _listVeiculos(BuildContext context) {
    return ListView.builder(
      itemCount: _modelList.length,
      itemBuilder: (context, index) {
        Veiculo veiculo = _modelList[index];
        List<String> status = veiculo.statusVeiculo();

        return (filterVeiculo(veiculo) ||
                viewFilter == "" ||
                viewFilter == null)
            ? Container(
                margin: new EdgeInsets.only(left: 2.0, right: 2.0, top: 5.0),
                decoration: myBoxDecoration(),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /*2*/
                      ListTile(
                        leading: _getImg(veiculo.getImageLocal()),
                        title: Text(
                          veiculo.tipo,
                          style: Theme.of(context).textTheme.display1,
                        ),
                        subtitle: Text(veiculo.placa.replaceAll(" ", ""),
                            style: Theme.of(context).textTheme.display2),
                        trailing: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                  icon: Icon(
                                    (status.length == 0)
                                        ? Icons.beenhere
                                        : Icons.cancel,
                                    color: (status.length == 0)
                                        ? Colors.green
                                        : Colors.red,
                                    size: 35,
                                  ),
                                  onPressed: () {}),
                            ]),
                      ),
                      (status.length > 0)
                          ? ListTile(
                              title: Text("Não Operacional",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.display3),
                              subtitle: Text("Item(s) não conforme:" +
                                  veiculo.getPendencia()), //
                            )
                          : Container(),
                      Card(
                          color: Colors.white70,
                          elevation: 12,
                          semanticContainer: true,
                          child: ListTile(
                                 leading: Column(
                                     mainAxisSize: MainAxisSize.min,
                                     children: <Widget>[
                                       (veiculo.local_atual.nome != "")
                                           ? IconButton(
                                           icon: Icon(
                                             Icons.location_on,
                                             color: Colors.red,
                                           ),
                                           onPressed: () {})
                                           : Icon(
                                         Icons.location_off,
                                         color: Colors.black,
                                       ),
                                     ]),
                                title: Text(
                                  veiculo.local_atual.nome,
                                  style: Theme.of(context).textTheme.display1,
                                ),
                                subtitle: Text(DateFormat.yMMMd().format(veiculo.local_atual.data) +
                                    " " +
                                    DateFormat.Hm().format(veiculo.local_atual.data) +
                                    "\nSede Titular: " +
                                    veiculo.sede_titular)
                      )),
                      IconButton(
                          icon: Icon(
                            Icons.more_horiz,
                            color: Colors.black,
                            size: 33,
                          ),
                          onPressed: () {
                            _model = veiculo;

                            _navigateAndDisplaySelection(context);
                          })
                    ]))
            : Container();
      },
    );
  }

  bool filterVeiculo(Veiculo veiculo) {
    viewFilter = viewFilter.toUpperCase();

    if (veiculo.tipo.toUpperCase().contains(viewFilter)) return true;
    if (veiculo.placa.toUpperCase().contains(viewFilter)) return true;
    if (veiculo.local_atual.nome.toUpperCase().contains(viewFilter))
      return true;
    if (veiculo.sede_titular.toUpperCase().contains(viewFilter)) return true;

    return false;
  }

  _showLisVeiculos(BuildContext context) {
    return _modelList == null
        ? Container(
            padding: const EdgeInsets.all(10),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  new Center(
                      child: new Text('Carregando...',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 26.0))),
                  _showCircularProgress()
                ]))
        : new Form(
            key: this._formKey,
            autovalidate: true,
            child: new ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                children: <Widget>[
                  new Container(
                      child: new Text("Gestão de Veículos",
                          style: Theme.of(context).textTheme.title),
                      margin: new EdgeInsets.only(top: 20.0)),
                  new TextField(
                    decoration: new InputDecoration(
                      labelText: "Pesquisar",
                      icon: const Icon(Icons.search),
                      hintText: 'Digite o nome do funcionário',
                    ),
                    controller: _filter,
                  ),
                  new Container(
                      margin: new EdgeInsets.only(top: 10.0),
                      height: 400,
                      child: _listVeiculos(context))
                ]));
  }

  void setFilter(String f) {
    setState(() {
      viewFilter = f;
      viewAll = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: _showLisVeiculos(context),
    );
  }
}
