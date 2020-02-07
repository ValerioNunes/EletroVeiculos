import 'package:flutter/material.dart';
import 'package:eletroveiculos/services/authentication.dart';
import 'package:eletroveiculos/services/util.dart';
import 'package:eletroveiculos/services/crud.dart';
import 'package:eletroveiculos/pages/edt_usuario.dart';
import 'package:eletroveiculos/pages/generate_qrcode.dart';
import 'package:eletroveiculos/models/usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eletroveiculos/pages/veiculo_list.dart';
import 'package:eletroveiculos/pages/map_view.dart';
class DrawerItem {
  String title;
  IconData icon;
  StatefulWidget page;
  List<String> user;
  DrawerItem(this.title, this.icon, this.page,{this.user});

}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);


  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final _textEditingController = TextEditingController();
  bool _isEmailVerified = false;
  int _selectedDrawerIndex = 0;

  static String collection = 'Usuario';
  Usuario _model = new Usuario();
  CrudMedthods crud = new CrudMedthods(collection);
  var drawerItems = [];

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    Navigator.of(context).pop(); // close the drawer
  }

  @override
  void initState(){

    Firestore.instance.collection(collection).document(widget.userId).get().then((visitorSnapshot) {

      setState(() {
        _model = Usuario.fromSnapshot(visitorSnapshot.data);
        drawerItems = [
          new DrawerItem("Gestão de Veículos", Icons.directions_car, new CadVeiculo(user: _model)),
          new DrawerItem("Localização de Veículos", Icons.location_on, new MapView()),
          new DrawerItem("Minha Conta", Icons.person_pin,new UpdateUser(userId: widget.userId,))
        ];

      });
    }).catchError((error) {

    });



    super.initState();
  }

  void _checkEmailVerification() async {
    _isEmailVerified = await widget.auth.isEmailVerified();
    if (!_isEmailVerified) {

    }
  }

  void _resentVerifyEmail(){
    widget.auth.sendEmailVerification();
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content: new Text("Link to verify account has been sent to your email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
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
  void dispose() {
    super.dispose();
  }


  _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }


  _showDialog(BuildContext context) async {
    _textEditingController.clear();
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
          return AlertDialog(
            content: new Row(
              children: <Widget>[
                new Expanded(child: new TextField(
                  controller: _textEditingController,
                  autofocus: true,
                  decoration: new InputDecoration(
                    labelText: 'Add new todo',
                  ),
                ))
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new FlatButton(
                  child: const Text('Save'),
                  onPressed: () {

                    Navigator.pop(context);
                  })
            ],
          );
      }
    );
  }

  Widget _showLogo() {
    return Hero(
      tag: 'hero',
      child: Card(
        child: Image.asset(
          'img/eletroveiculos.png',
          fit: BoxFit.cover,
          width: 120.0,
          height: 120.0,
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    var drawerOptions = <Widget>[];
    for (var i = 0; i < drawerItems.length; i++) {
      var d = drawerItems[i];
      drawerOptions.add(
          new ListTile(
            leading: new Icon(d.icon),
            title: new Text(d.title),
            selected: i == _selectedDrawerIndex,
            onTap: () => _onSelectItem(i),
          )
      );
    }
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(Util.nomeApp),
          actions: <Widget>[
            new FlatButton(
                child: new Text('Sair',
                            style: new TextStyle(fontSize: 17.0, color: Colors.white)),
                            onPressed: _signOut)
          ],
        ),
        drawer: new Drawer(
          child: new Column(
            children: <Widget>[

              new UserAccountsDrawerHeader(currentAccountPicture:  new CircleAvatar( radius: 120.0,backgroundImage:  new AssetImage('img/eletroveiculos.png'))
                                          , accountName: new Text("Ola, "+ _model.nome + " "+ _model.sobrenome), accountEmail:  new Text( _model.email)),
              new Column(children: drawerOptions)
            ],
          ),
        ),
        body: ( drawerItems.length > 0) ? drawerItems[_selectedDrawerIndex].page : Center(child: CircularProgressIndicator())
    );
  }
}
