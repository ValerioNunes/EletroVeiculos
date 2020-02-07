import 'package:flutter/material.dart';
import 'package:eletroveiculos/models/usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eletroveiculos/services/crud.dart';
import 'dart:async';

class CadUsuario extends StatefulWidget {

  CadUsuario({Key key, this.userId, }) : super(key: key);
  final String userId;

  @override
  State<StatefulWidget> createState() => new _CadUsuarioState();

}
enum FormMode { EDIT, VIEW }

class _CadUsuarioState extends State<CadUsuario> {

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController _Nome = new TextEditingController();
  TextEditingController _CPF = new TextEditingController();

  FormMode _formMode = FormMode.VIEW;


  Firestore database = Firestore.instance;
  static String collection = 'Usuario';
  CrudMedthods crud = new CrudMedthods(collection);

  int _selectedDrawerIndex = 1;

  Usuario _model = new Usuario();

  _getDrawerItemWidget(int pos,BuildContext context) {
    switch (pos) {
      case 1:
        return _showCadEdt(context);
      default:
        return new Text("Error");
    }
  }
  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
  }

  _addNewModel(Usuario model) {
    if(model  != null) {
      crud.addData(model);
    }
  }

  _updateModel(Usuario model){
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
      _formKey.currentState.reset();

      _model.uid = widget.userId;

      if(_model.uid != "") {
        _updateModel(_model);
        _showInfo(context,"Salvo com Sucesso!");
      }

      _formKey.currentState.deactivate();
      return true;
    }
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


    database.collection(collection)
            .document(widget.userId)
            .snapshots()
            .listen((doc) => _setModel(doc));
  }

  @override
  void dispose() {
    super.dispose();
  }

  _setModel(DocumentSnapshot doc){

    _model = Usuario.fromSnapshot(doc);
    _Nome.text = _model.nome;
    _CPF.text = _model.cpf;
  }


  Widget _showCadEdt(BuildContext context) {

    return new SafeArea(
        top: false,
        bottom: false,
        child: new Form(
            key: this._formKey,
            autovalidate: true,
            child: new ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: <Widget>[
                new TextFormField(
                    controller : _Nome,
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.person),
                      hintText: 'Nome Usuario',
                      labelText: 'Name',
                    ),
                    validator: (value) => value.isEmpty ? 'Digite o Nome do Usuario' : null,
                    onSaved: (String value) {
                      this._model.nome = value;
                    }
                ),
                new TextFormField(
                    controller : _CPF,
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.credit_card),
                      hintText: 'CPF',
                      labelText: 'CPF',
                    ),
                    validator: (value) => value.isEmpty ? 'Digite a CPF' : null,
                    keyboardType: TextInputType.number,
                    onSaved: (String value) {
                      this._model.cpf = value;
                    }
                ),
                new Container(

                  child: new RaisedButton(
                    child: new Text(
                      'Salvar',
                      style: new TextStyle(
                          color: Colors.white
                      ),
                    ),
                    onPressed: () => (submit(context)),
                    color: Colors.lightGreen,
                  ),

                  margin: new EdgeInsets.only(
                      top: 20.0
                  ),
                )
              ],
            )));
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Meu Dados'),
        ),
        body: _getDrawerItemWidget(_selectedDrawerIndex,context)
    );
  }
}