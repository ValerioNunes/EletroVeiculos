import 'package:flutter/material.dart';
import 'package:eletroveiculos/models/usuario.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:eletroveiculos/services/authentication.dart';
import 'package:eletroveiculos/services/crud.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateUser extends StatefulWidget {
  UpdateUser({Key key, this.userId, }) : super(key: key);
  final String userId;

  @override
  _UpdateUserState createState() => new _UpdateUserState();
}

class _UpdateUserState extends State<UpdateUser> {
  int currStep = 0;
  static var _focusNode = new FocusNode();
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  Usuario _data = new Usuario();
  String _errorMessage = "";
  List _uf = [
    "Acre (AC)",
    "Alagoas (AL)",
    "Amazonas (AM)",
    "Amapá (AP)",
    "Bahia (BA)",
    "Ceará (CE)",
    "Distrito Federal (DF)",
    "Espírito Santo (ES)",
    "Goiás (GO)",
    "Maranhão (MA)",
    "Mato Grosso (MT)",
    "Mato Grosso do Sul (MS)",
    "Minas Gerais (MG)",
    "Pará (PA)",
    "Paraíba (PB)",
    "Paraná (PR)",
    "Pernambuco (PE)",
    "Piauí (PI)",
    "Rio de Janeiro (RJ)",
    "Rio Grande do Norte (RN)",
    "Rio Grande do Sul (RS)",
    "Rondônia (RO)",
    "Roraima (RR)",
    "Santa Catarina (SC)",
    "São Paulo (SP)",
    "Sergipe (SE)",
    "Tocantins (TO)"
  ];

  bool _isLoading = false;

  static String collection = 'Usuario';
  CrudMedthods crud = new CrudMedthods(collection);

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentCity;
  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String city in _uf) {
      items.add(new DropdownMenuItem(value: city, child: new Text(city)));
    }
    return items;
  }


  TextEditingController _nome = new TextEditingController();
  TextEditingController _sobrenome = new TextEditingController();
  TextEditingController _matricula = new TextEditingController();
  TextEditingController _nivel = new TextEditingController();

  DateTime _dateNascimento = null;

  var _cpf = new MaskedTextController(mask: '000.000.000-00');
  var _telefonefixopessoal = new MaskedTextController(mask: '(00)0.0000-0000');
  var _telefonepessoal = new MaskedTextController(mask: '(00)0.0000-0000');

  void setForm(Usuario usuario){
    _nome.text = usuario.nome;
    _matricula.text = usuario.matricula;
    _sobrenome.text = usuario.sobrenome;
    _cpf.text = usuario.cpf;
    _telefonepessoal.text = usuario.telefonePessoal;
    _nivel.text = usuario.nivel.toString();
  }


  List<Step> getSteps(){
    return [
      new Step(
          title: const Text('Nome'),
          //subtitle: const Text('Enter your name'),
          isActive: true,
          //state: StepState.error,

          state: StepState.indexed,
          content: Column(children: <Widget>[
            new TextFormField(
              keyboardType: TextInputType.text,
              autocorrect: true,
              controller: _nome,
              onSaved: (String value) {
                _data.nome = value;
              },
              maxLines: 1,
              //initialValue: 'Aseem Wangoo',
              validator: (value) {
                if (value.isEmpty && value.length < 1) {
                  return 'Digite seu Nome';
                }
              },
              decoration: new InputDecoration(
                  labelText: 'Digite seu Nome',
                  hintText: 'Nome',
                  //filled: true,
                  icon: const Icon(Icons.person_pin),
                  labelStyle: new TextStyle(
                      decorationStyle: TextDecorationStyle.solid)),
            ),
            new TextFormField(
              keyboardType: TextInputType.text,
              autocorrect: false,
              controller: _sobrenome,
              onSaved: (String value) {
                _data.sobrenome = value;
              },
              maxLines: 1,
              //initialValue: 'Aseem Wangoo',
              validator: (value) {
                if (value.isEmpty && value.length < 1) {
                  return 'Digite seu Sobrenome';
                }
              },
              decoration: new InputDecoration(
                  labelText: 'Digite seu Sobrenome',
                  hintText: 'Sobrenome',
                  //filled: true,
                  icon: const Icon(Icons.person),
                  labelStyle: new TextStyle(
                      decorationStyle: TextDecorationStyle.solid)),
            ),
            new TextFormField(
              keyboardType: TextInputType.text,
              autocorrect: false,
              controller: _nivel,
              enabled:  false,
              maxLines: 1,
              decoration: new InputDecoration(
                  labelText: 'Nivel Acesso',
                  hintText: 'Nivel Acesso',
                  //filled: true,
                  icon: const Icon(Icons.lock),
                  labelStyle: new TextStyle(
                      decorationStyle: TextDecorationStyle.solid)),
            ),
          ])),
      new Step(
          title: const Text('Matrícula'),
          //subtitle: const Text('Enter your name'),
          isActive: true,
          //state: StepState.error,
          state: StepState.indexed,
          content: Column(children: <Widget>[
            new TextFormField(
              keyboardType: TextInputType.text,
              autocorrect: true,
              controller: _matricula,
              onSaved: (String value) {
                _data.matricula = value;
              },
              maxLines: 1,
              //initialValue: 'Aseem Wangoo',
              validator: (value) {
                if (value.isEmpty && value.length < 1) {
                  return 'Digite sua Matrícula não coloque 01';
                }
              },
              decoration: new InputDecoration(
                  labelText: 'Digite sua Matrícula, não coloque 01',
                  hintText: 'Matrícula',
                  //filled: true,
                  icon: const Icon(Icons.card_membership),
                  labelStyle: new TextStyle(
                      decorationStyle: TextDecorationStyle.solid)),
            ),
          ])),
      new Step(
          title: const Text('Telefone'),
          //subtitle: const Text('Subtitle'),
          isActive: true,
          //state: StepState.editing,
          state: StepState.indexed,
          content: Column(children: <Widget>[
            new TextFormField(
              controller: _telefonepessoal,
              keyboardType: TextInputType.phone,
              autocorrect: false,
              validator: (value) {
                if (value.isEmpty && value.length < 10) {
                  return 'Celular';
                }
              },
              onSaved: (String value) {
                _data.telefonePessoal = value;
              },
              maxLines: 1,
              decoration: new InputDecoration(
                  labelText: 'Digite seu o número do celular',
                  hintText: 'Celular',
                  icon: const Icon(Icons.smartphone),
                  labelStyle: new TextStyle(
                      decorationStyle: TextDecorationStyle.solid)),
            ),
          ])),
      new Step(
          title: const Text('CPF'),
          //subtitle: const Text('Subtitle'),
          isActive: true,
          //state: StepState.editing,
          state: StepState.indexed,
          content: new TextFormField(
            controller: _cpf,
            keyboardType: TextInputType.number,
            autocorrect: false,
            validator: (value) {
              if (value.isEmpty && value.length < 10) {
                return 'Please enter valid CPF';
              }
            },
            onSaved: (String value) {
              _data.cpf = value;
            },
            maxLines: 1,
            decoration: new InputDecoration(
                labelText: 'Digite seu CPF',
                hintText: 'CPF',
                icon: const Icon(Icons.perm_identity),
                labelStyle:
                new TextStyle(decorationStyle: TextDecorationStyle.solid)),
          )),
    ];
  }


  @override
  void initState() {
    _dropDownMenuItems = getDropDownMenuItems();
    Firestore.instance.collection(collection)
        .document(widget.userId)
        .get().then((visitorSnapshot) {
      _data = Usuario.fromSnapshot(visitorSnapshot.data);
       setState(() {
         setForm(_data);
       });
    }).catchError((error) {

    });

  super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }


  _showDialog(String msg) {
    showDialog(
        context: context,
        child: new AlertDialog(
          title: new Text("Info"),
          //content: new Text("Hello World"),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[new Text(msg)],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    bool _isIos = Theme.of(context).platform == TargetPlatform.iOS;

    void _submit() {
      final FormState formState = _formKey.currentState;

      if (!formState.validate()) {
        _showDialog('Dado(s) de cadastro inválido(s) !');
      } else {
        formState.save();
        crud.updateData(_data).then((onValue){
          _showDialog('Salvo com Sucesso!');
        });
      }
    }

    Widget _showCircularProgress() {
      if (_isLoading) {
        return Center(child: CircularProgressIndicator());
      }
      return Container(
        height: 0.0,
        width: 0.0,
      );
    }

    Widget _showPrimaryButton() {
      return new Padding(
          padding: EdgeInsets.all(16.0),
          child: SizedBox(
            height: 40.0,
            child: new RaisedButton(
              elevation: 5.0,
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
              color: Colors.green,
              child: new Text('Salvar',
                  style: new TextStyle(fontSize: 20.0, color: Colors.white)),
              onPressed: _isLoading ? null : _submit,
            ),
          ));
    }

    return new Scaffold(
        appBar: AppBar(title: Text('Minha Conta'), actions: <Widget>[
          new FlatButton(
              child: new Text('Salvar',
                  style: new TextStyle(fontSize: 17.0, color: Colors.white)),
              onPressed: _isLoading ? null : _submit)
        ]),
        body: Stack(
          children: <Widget>[
            Container(

                child: new Form(
                  key: _formKey,
                  child: (_data.uid != "" ) ? new ListView(children: <Widget>[
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
                    _showPrimaryButton(),
                  ]) : Center(child: CircularProgressIndicator()) ,
                )),
            _showCircularProgress(),
          ],
        ));
  }
}
