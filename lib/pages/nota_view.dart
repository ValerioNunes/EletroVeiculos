import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:eletroveiculos/models/veiculo.dart';
import 'package:eletroveiculos/models/usuario.dart';
import 'package:eletroveiculos/models/nota.dart';
import 'package:eletroveiculos/services/crud.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class NotaView extends StatefulWidget {
  NotaView({
    Key key,
    this.user,
    this.model,
    this.nota,
  }) : super(key: key);
  Veiculo model;
  Usuario user;
  Nota nota;

  @override
  _NotaViewState createState() => new _NotaViewState();
}

class _NotaViewState extends State<NotaView> {
  File sampleImage;
  String urlImg = "";
  bool isCarregando = false;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController _descricao = new TextEditingController();
  MaskedTextController _datetime = new MaskedTextController(mask: '0000-00-00');
  static String collection = 'Veiculos';
  CrudMedthods crud = new CrudMedthods(collection);

  Nota nota = new Nota();

  List _tipo = ["Corretiva", "Melhoria", "Alerta"];
  List _status = ["Andamento", "Cancelado","Concluído"];

  String _currentTipo;
  String _currentStatus;

  List<DropdownMenuItem<String>> _dropDownMenuItemsTipo;
  List<DropdownMenuItem<String>> _dropDownMenuItemsStatus;

  List<DropdownMenuItem<String>> getDropDownMenuItemsTipo() {
    List<DropdownMenuItem<String>> items = new List();
    for (String c in _tipo) {
      items.add(new DropdownMenuItem(value: c, child: new Text(c)));
    }
    return items;
  }
  List<DropdownMenuItem<String>> getDropDownMenuStatus() {
    List<DropdownMenuItem<String>> items = new List();
    for (String c in _status) {
      items.add(new DropdownMenuItem(value: c, child: new Text(c)));
    }
    return items;
  }


  @override
  void initState() {
    super.initState();
    _dropDownMenuItemsTipo =  getDropDownMenuItemsTipo();
    _dropDownMenuItemsStatus =  getDropDownMenuStatus();

    if(widget.nota != null){
      print(widget.nota.status);
      setState(() {
        setNota(widget.nota);
      });
    }else{
      _datetime.text = DateTime.now().toIso8601String();
    }
  }

  setNota(Nota notaEdit){
    nota = notaEdit;
    _currentTipo = nota.tipo;
    _currentStatus = nota.status;
    _descricao.text =  nota.descricao;
    _datetime.text = nota.dateTime.toIso8601String();
  }

  Future getImage() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      sampleImage = tempImage;
    });
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

  _updateModel(Veiculo model) {
    //Toggle completed
    if (model != null) {
      print(model.toJson());
      crud.updateData(model);
    }
  }

  bool submit(BuildContext context) {
    // First validate form.
     setState(() {
       isCarregando = true;
     });
    if (this._formKey.currentState.validate() && _currentStatus != "" && _currentTipo != "" ) {
       // Save our form now.

      if (widget.model.uid != "" ) {
        _formKey.currentState.save();

        if (sampleImage != null) {
          final StorageReference firebaseStorageRef = FirebaseStorage.instance
              .ref().child("/img_notas/" + widget.model.placa + '-' + DateTime
              .now()
              .millisecondsSinceEpoch
              .toString() + '.jpg');
          final StorageUploadTask task = firebaseStorageRef.putFile(
              sampleImage);
          task.events.listen((onData) {
            if (onData.type == StorageTaskEventType.success) {
              firebaseStorageRef.getDownloadURL().then((onValue) {
                print(onValue);
                setState(() {
                  nota.image = onValue;
                  addNovaNota();
                });
              });

            }
            if (onData.type == StorageTaskEventType.failure) {
              setState(() {
                isCarregando = false;
              });
            }
          });
        } else {
          addNovaNota();
        }

        return true;
      }
    }
    _showInfo(context, "Ops, Alguns dados estão inválidos!");
    return false;
  }

  addNovaNota(){

    if(widget.nota != null) {
      widget.model.notas[nota.uid] = nota.toJson();
      crud.updateData(widget.model);
    }else{
      this.nota.uid = widget.model.notas.length ?? 0;
      this.nota.usuario = widget.user;
      crud.addDataList(widget.model, 'notas', this.nota.toJson());
    }

    Navigator.pop(context, true);

    setState(() {
      isCarregando = false;
    });
  }

  _showInfoConfirmar(String msg, {String info = "Info"}) async {

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(info,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: info.contains("Atenção")
                      ? Colors.redAccent
                      : Colors.green)),
          content: new Text(msg),
          actions: <Widget>[
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            new FlatButton(
              child: new Text("CANCELAR"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            )
          ],
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Nota de Veículo'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            color: Colors.white,
            iconSize: 32,
            onPressed: () => (submit(context)),
          ),
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Form(
              key: this._formKey,
              autovalidate: true,
              child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    (sampleImage != null)
                        ? Expanded(
                        child : Image.file(sampleImage, height: 200.0, width: 200.0))
                        : Container(),
                    (isCarregando) ? Center(child: CircularProgressIndicator()) : Container(),
                    new Container(
                        padding: EdgeInsets.all(4),
                        color: Colors.white,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                          new Text("Tipo de Nota:", style:  Theme.of(context).textTheme.display1),

                          Container  (padding: EdgeInsets.only( left: 6),child :new DropdownButton(
                            value: _currentTipo,
                            items: _dropDownMenuItemsTipo,
                            onChanged: (value) {
                              setState(() {
                                _currentTipo = value;
                                nota.tipo =  value;
                              });
                            },
                          )),
                        ])),
                    new Container(
                      padding: EdgeInsets.all(4),
                        color: Colors.white,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                          new Text("Status:", style:  Theme.of(context).textTheme.display1),
                            Container  (padding: EdgeInsets.only( left: 6), child :new DropdownButton(
                            value: _currentStatus,
                            items: _dropDownMenuItemsStatus,
                            onChanged: (value) {
                              setState(() {
                                _currentStatus = value;
                                nota.status = value;
                              });
                            },
                          )),
                            Expanded(
                                child :Container(
                                    padding:  EdgeInsets.only(left : 12),
                                    child: new TextFormField(
                                        controller: _datetime,
                                        decoration: const InputDecoration(
                                          icon: const Icon(Icons.calendar_today),
                                          hintText: 'AAAA-MM-DD',
                                          labelText: 'Data da Nota',
                                        ),
                                        validator: (value) => value.isEmpty ? 'Data inválida!' : null,
                                        keyboardType: TextInputType.number,
                                        onSaved: (String value) {
                                          this.nota.dateTime = DateTime.parse(value);
                                        }))
                            )
                        ])),

                    new Expanded(
                        child: TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 8,
                      controller: _descricao,
                      decoration: InputDecoration(
                        contentPadding:EdgeInsets.all(10), // Set new height here
                        border: OutlineInputBorder(),
                        labelText: "Descrição",
                        hintText: "Descrição",
                      ),
                      onSaved: (String value) {
                        this.nota.descricao = value;
                      }
                    ))

                  ]))),
      floatingActionButton: new FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Add Image',
        child: new Icon(Icons.add_photo_alternate),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget enableUpload() {

    return Container(
      child: Column(
        children: <Widget>[
          Image.file(sampleImage, height: 300.0, width: 300.0),
          RaisedButton(
            elevation: 7.0,
            child: Text('Upload Imagem'),
            textColor: Colors.white,
            color: Colors.blue,
            onPressed: () {
              final StorageReference firebaseStorageRef =
                  FirebaseStorage.instance.ref().child('myimage.jpg');
              final StorageUploadTask task =
                  firebaseStorageRef.putFile(sampleImage);
              task.events.listen((onData) {
                if (onData.type == StorageTaskEventType.success) {
                  firebaseStorageRef.getDownloadURL().then((onValue) {
                    print(onValue);
                    setState(() {
                      urlImg = onValue;
                    });
                  });
                }
              });
            },
          )
        ],
      ),
    );
  }
}
