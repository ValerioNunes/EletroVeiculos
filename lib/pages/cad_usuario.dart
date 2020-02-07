import 'package:flutter/material.dart';
import 'package:eletroveiculos/models/usuario.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:eletroveiculos/services/authentication.dart';
import 'package:eletroveiculos/services/crud.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class StepperBody extends StatefulWidget {
  StepperBody({this.auth, this.onSignedIn});
  final BaseAuth auth;
  final VoidCallback onSignedIn;

  @override
  _StepperBodyState createState() => new _StepperBodyState();
}

class _StepperBodyState extends State<StepperBody> {
  int currStep = 0;
  static var _focusNode = new FocusNode();
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  Usuario data = new Usuario();
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
              onSaved: (String value) {
                data.nome = value;
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
              onSaved: (String value) {
                data.sobrenome = value;
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
              onSaved: (String value) {
                data.matricula = value;
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
                data.telefonePessoal = value;
              },
              maxLines: 1,
              decoration: new InputDecoration(
                  labelText: 'Digite seu o número do celular',
                  hintText: 'Celular',
                  icon: const Icon(Icons.smartphone),
                  labelStyle: new TextStyle(
                      decorationStyle: TextDecorationStyle.solid)),
            )
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
              data.cpf = value;
            },
            maxLines: 1,
            decoration: new InputDecoration(
                labelText: 'Digite seu CPF',
                hintText: 'CPF',
                icon: const Icon(Icons.perm_identity),
                labelStyle:
                new TextStyle(decorationStyle: TextDecorationStyle.solid)),
          )),
      new Step(
          title: const Text('Credenciais'),
          // subtitle: const Text('Subtitle'),
          isActive: true,
          state: StepState.indexed,
          // state: StepState.disabled,
          content: Column(children: <Widget>[
            new TextFormField(
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              validator: (value) {
                if (value.isEmpty && !value.contains('@')) {
                  return 'Please enter valid email';
                }
              },
              onSaved: (String value) {
                data.email = value;
              },
              maxLines: 1,
              decoration: new InputDecoration(
                  labelText: 'Digite seu Email',
                  hintText: 'Email',
                  icon: const Icon(Icons.email),
                  labelStyle: new TextStyle(
                      decorationStyle: TextDecorationStyle.solid)),
            ),
            new TextFormField(
              obscureText: true,
              keyboardType: TextInputType.text,
              autocorrect: false,
              onSaved: (String value) {
                data.senha = value;
              },
              maxLines: 1,
              //initialValue: 'Aseem Wangoo',
              validator: (value) {
                if (value.isEmpty && value.length < 6) {
                  return 'Digite sua Senha';
                }
              },
              decoration: new InputDecoration(
                  labelText: 'Digite sua Senha',
                  hintText: 'Senha',
                  //filled: true,
                  icon: const Icon(Icons.lock),
                  labelStyle: new TextStyle(
                      decorationStyle: TextDecorationStyle.solid)),
            ),
          ])),
    ];
  }

  var _cpf = new MaskedTextController(mask: '000.000.000-00');
  var _telefonefixopessoal = new MaskedTextController(mask: '(00)0.0000-0000');
  var _telefonepessoal = new MaskedTextController(mask: '(00)0.0000-0000');
  @override
  void initState() {

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

    void _validateAndSubmit() async {
      setState(() {
        _errorMessage = "";
        _isLoading = true;
      });
      try {
        String userId = "";
        userId = await widget.auth.signUp(data.email, data.senha);
        widget.auth.sendEmailVerification();

        setState(() {
          _isLoading = false;
        });

        if (userId.length > 0 && userId != null) {
          data.uid = userId;
          crud.addDataUid(data);
          widget.onSignedIn();
          Navigator.of(context).pop();
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (_isIos) {
          _errorMessage = e.details;
        } else
          _errorMessage = e.message;

        _showDialog(_errorMessage);
      }
    }

    void _submit() {
      final FormState formState = _formKey.currentState;

      if (!formState.validate()) {
        _showDialog('Dado(s) de cadastro inválido(s) !');
      } else {
        formState.save();
        _validateAndSubmit();
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
              child: new Text('Cadastrar',
                  style: new TextStyle(fontSize: 20.0, color: Colors.white)),
              onPressed: _isLoading ? null : _submit,
            ),
          ));
    }

    return new Scaffold(
        appBar: AppBar(title: Text('Criação de Conta'), actions: <Widget>[
          new FlatButton(
              child: new Text('Cadastrar',
                  style: new TextStyle(fontSize: 17.0, color: Colors.white)),
              onPressed: _isLoading ? null : _submit)
        ]),
        body: Stack(
          children: <Widget>[
            Container(

                child: new Form(
                  key: _formKey,
                  child: new ListView(children: <Widget>[
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
                  ]),
                )),
            _showCircularProgress(),
          ],
        ));
  }
}
