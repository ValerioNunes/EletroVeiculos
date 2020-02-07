import 'package:flutter/material.dart';
import 'package:eletroveiculos/models/veiculo.dart';
import 'package:eletroveiculos/models/usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eletroveiculos/services/crud.dart';
import 'nota_view.dart';
import 'package:eletroveiculos/models/nota.dart';


class NotaList extends StatefulWidget {
  NotaList({
    Key key,
    this.user,
    this.model,
  }) : super(key: key);
  Veiculo model;
  Usuario user;

  @override
  State<StatefulWidget> createState() => new _NotaListState();
}

enum FormMode { EDIT, VIEW }

class _NotaListState extends State<NotaList> {

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  Firestore database = Firestore.instance;
  static String collection = 'Veiculos';
  CrudMedthods crud = new CrudMedthods(collection);
  int _selectedDrawerIndex = 1;
  bool isCarregando = false;
  int currStep = 0;

  Veiculo veiculo = null;

  _setModel() {

    isCarregando = true;
    Firestore.instance
        .collection(collection)
        .document(widget.model.uid)
        .get()
        .then((visitorSnapshot) {
        setState(() {
          veiculo = Veiculo.fromSnapshot2(visitorSnapshot);
          isCarregando = false;
        });

    }).catchError((error) {
      print("Erro"+ error.toString());
      setState(() {
      isCarregando = false;
    });});
  }


  @override
  void initState() {
    super.initState();
    _setModel();
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
        fit: BoxFit.cover
      ),
    );
  }

  Widget imagemFirebase(String imageLink) {
    Widget img;
    img = _showLogo();

    try {
      if(imageLink != "") {

        img = Image.network(
          imageLink,
        );
      }
    } catch (e) {
      return null;
    }

    return img;
  }

  Widget _listNotas(BuildContext context) {
    if (veiculo != null) {
      return ListView.builder(
        itemCount: veiculo.notas.length,
        itemBuilder: (context, index) {

          Nota nota = Nota.fromSnapshot(veiculo.notas[index]);

          return Container(
              margin: new EdgeInsets.only(top: 5.0),
              //decoration: myBoxDecoration(),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /*2*/
                    ListTile(
                      leading: imagemFirebase(nota.image),
                      title: Text(
                        nota.tipo,
                        style: Theme.of(context).textTheme.display1,
                      ),
                      subtitle: Text(nota.descricao+"\nStatus: "+nota.status+"\nCriador: "+nota.usuario.nome,
                          style: Theme.of(context).textTheme.display2),
                      trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.green,
                                ),
                                onPressed: () {
                                  _showNotaView(notaEdit: nota);
                                }),
                          ]),
                    ),
                  ]));
        },
      );
    } else
      return  _showCircularProgress() ;
  }

  Widget _showListNotas(BuildContext context) {
    return new Form(
        key: this._formKey,
        autovalidate: true,
        child: new ListView(
          padding: const EdgeInsets.symmetric(horizontal: 7.0),
          children: <Widget>[
            new Container(
              child: new Text(
                widget.model.tipo + " - Placa: " + widget.model.placa,
                style: Theme.of(context).textTheme.display1,
              ),
              margin: new EdgeInsets.only(top: 20.0),
            ),
           (isCarregando)  ? _showCircularProgress() : Container(),
            new Container(margin: new EdgeInsets.only(top: 10.0), height: 370,child: _listNotas(context)),
          ],
        ));
  }

  Widget _showCircularProgress() {
    return Center(child: CircularProgressIndicator());
  }

  _showNotaView({notaEdit: null}){

    var result = Navigator.push(
      context,
      // Create the SelectionScreen in the next step.
      MaterialPageRoute(
          builder: (context) => NotaView(
            model: veiculo,
            user: widget.user,
            nota: notaEdit,
          )),
    ).then((onValue) {
      setState(() {
        _setModel();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar:  new AppBar(title: new Text("Lista de Notas")),
        body:_showListNotas(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNotaView();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
