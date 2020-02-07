import 'package:flutter/material.dart';
import 'package:eletroveiculos/services/authentication.dart';
import 'package:eletroveiculos/pages/root_page.dart';
import 'package:eletroveiculos/services/util.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Util.nomeApp,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Util.primaryColor(),
          primaryColor:Util.primaryColor(),
          primaryColorDark: Colors.green,
          accentColor: Colors.amber,
          fontFamily: 'Lato',
          textTheme: TextTheme(
            headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold, fontFamily: 'Lato'),
            title: TextStyle(fontSize: 24.0,  fontWeight: FontWeight.bold, fontFamily: 'Lato'),
            display1 : TextStyle(fontSize: 20.0,  fontWeight: FontWeight.bold, fontFamily: 'Lato' ,color:  Colors.black54),
            display2 : TextStyle(fontSize: 14.0,  fontWeight: FontWeight.bold, fontFamily: 'Lato'),
            display3 : TextStyle(fontSize: 24.0,  fontWeight: FontWeight.bold, fontFamily: 'Lato' , color:  Colors.red, ),
            body1: TextStyle(fontSize: 17.0, fontFamily: 'Lato'),
          )
      ),
      home: RootPage(auth: new Auth()),
    );
  }
}
