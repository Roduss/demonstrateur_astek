import 'package:flutter/material.dart';
import 'Accueil.dart';
import 'Help.dart';
import 'package:flutter/rendering.dart';
import 'package:demonstrateur_astek/size_config.dart';
import 'package:auto_size_text/auto_size_text.dart';


///Page de démarrage

void main() {
  //debugPaintSizeEnabled = true;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demonstrateur Astek',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: "Appairage auto",
      ),
    );
  }
}

///Redirection vers la page d'appairage automatique

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

 //Fonction pour rediriger vers l'accueil
  _pushtoAccueil() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) => Accueil()));
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(
            widget.title,
          ),
          actions: <Widget>[
            Image.asset('images/logo_astek.png'),
          ]),
      body: //SingleChildScrollView(
          //child:
          Column(
        children: <Widget>[
          appairingText,
          Expanded(
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: Container(
                margin: EdgeInsets.only(bottom: 20),
                child: ButtonTheme(
                  height: SizeConfig.blockSizeVertical * 20,
                  minWidth: SizeConfig.blockSizeHorizontal * 90,
                  child: RaisedButton(
                    color: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.black),
                    ),
                    onPressed: () {
                      _pushtoAccueil();
                    },
                    child: Text(
                      "Arreter la recherche",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget appairingText = Expanded(
    child: Align(
      alignment: FractionalOffset.center,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: AutoSizeText(
          "Appairage automatique du récepteur ... "
          "Assurez vous d'avoir le récepteur allumé et a portée",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 48,
          ),
          maxLines: 5,
        ),
      ),
    ),
  );

  //Cette fonction permet d'afficher une SnackBar, elle peut etre utile dans une future version
  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }
}
