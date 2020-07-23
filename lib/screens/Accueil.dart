import 'package:auto_size_text/auto_size_text.dart';
import 'main.dart';
import 'package:demonstrateur_astek/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:demonstrateur_astek/db_utils/database_helper.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:sqflite/sqflite.dart';

import 'Help.dart';
import 'Settings.dart';

///TODO :
///Ajouter une petite barre d'info (snackbar) lorsque le code-barre est trouvé.
///
/// Page d'Accueil de l'application

enum TtsState { playing, stopped, paused, continued }

class Accueil extends StatefulWidget {
  double volume ;
  double pitch;
  double rate;
  String language;

  Accueil([this.volume = 0.5, this.pitch =1, this.rate = 0.5, this.language = 'fr-FR']);



  @override
  _Accueil_State createState() {
    return _Accueil_State(this.volume, this.pitch, this.rate, this.language);
  }
}

class _Accueil_State extends State<Accueil> {

  //Déclaration des variables

  FlutterTts flutterTts;
  dynamic languages;
  String language;
  double volume;
  double pitch ;
  double rate ;

  String _newVoiceText;

  TtsState ttsState = TtsState.stopped;


  //Constructeur & getters

  _Accueil_State(this.volume , this.pitch, this.rate, this.language);



  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  get isPaused => ttsState == TtsState.paused;

  get isContinued => ttsState == TtsState.continued;

  @override
  initState() {
    super.initState();
    initTts();
    print("value volume init : $volume");
  }

  //Permet de récupérer la liste des langages disponibles
  initTts() {
    flutterTts = FlutterTts();

    _getLanguages();
  }
  Future _getLanguages() async {
    languages = await flutterTts.getLanguages;
    if (languages != null) setState(() => languages);
  }

  //Permet d'utiliser les hauts parleurs du smartphone
  Future _speak() async {
    print("Val volume : $volume, rate : $rate pitch : $pitch");
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (_newVoiceText != null) {
      if (_newVoiceText.isNotEmpty) {
        var result = await flutterTts.speak(_newVoiceText);
        if (result == 1) setState(() => ttsState = TtsState.playing);
      }
    }
  }

  //Stop l'élocution

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  //Met en pause l'élocution

  Future _pause() async {
    var result = await flutterTts.pause();
    if (result == 1) setState(() => ttsState = TtsState.paused);
  }
  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems() {
    var items = List<DropdownMenuItem<String>>();
    for (dynamic type in languages) {
      items.add(
          DropdownMenuItem(value: type as String, child: Text(type as String)));
    }
    return items;
  }

  void changedLanguageDropDownItem(String selectedType) {
    setState(() {
      language = selectedType;
      flutterTts.setLanguage(language);
    });
  }

  //Fonction a appeler pour le Text_To_Speech
  //Elle prend en argument ce que l'on veut entendre
  void _onChange(String text) {
    setState(() {
      _newVoiceText = text;
    });
    _speak();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Bonjour",
        ),
        actions: <Widget>[
          Image.asset('images/logo_astek.png'),
        ],
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.help),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        Help(title: "Page d'aide")));
              },
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                height: SizeConfig.blockSizeVertical * 10,
                width: SizeConfig.blockSizeHorizontal * 90,
                margin: EdgeInsets.only(bottom: 50),
                child: AutoSizeText(
                  "Bonjour ! Touchez un produit svp",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                  ),
                  maxLines: 2,
                ),
              ),
              Container(
                height: SizeConfig.blockSizeVertical * 10,
                width: SizeConfig.blockSizeHorizontal * 90,
                child: AutoSizeText(
                  "Autonomie récepteur:",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 48,
                  ),
                  maxLines: 2,
                ),
              ),
              Container(
                ///TODO : Pour le texte, il faudra faire une changement de couleur avec le pourcentage de batterie.
                ///On pourra peut etre utiliser Fractionnaly sized box.
                ///Faire parler au démarrage avec le pourcentage de batterie envoyé
                //color: Colors.green,
                height: SizeConfig.blockSizeVertical * 10,
                width: SizeConfig.blockSizeHorizontal * 90,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.red, Colors.green],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        stops: [0, 0.3]

                        /// Ici on aura du rouge jusqu'a 30% de la barre.
                        )),
                child: AutoSizeText(
                  "Ex : 50%",
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 90,
                  ),
                ),
              ),
              Container(
                height: SizeConfig.blockSizeVertical * 8,
                width: SizeConfig.blockSizeHorizontal * 90,
                margin: EdgeInsets.only(top: 15),
                child: AutoSizeText(
                  "Paramètres :",
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                height: SizeConfig.blockSizeVertical * 30,
                width: SizeConfig.blockSizeHorizontal * 90,
                //margin: EdgeInsets.symmetric(vertical: 10),
                child: Transform.scale(
                  scale: 9,
                  child: IconButton(
                    icon: Icon(
                      Icons.settings,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) =>
                              Settings(volume,pitch,rate,language, title: "Paramètres")));
                    },
                  ),
                ),
              ),
              ButtonTheme(
                height: SizeConfig.blockSizeVertical * 10,
                minWidth: SizeConfig.blockSizeHorizontal * 90,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(color: Colors.black)),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => MyHomePage(
                              title: "Appairage récepteur",
                            )));
                  },
                  child: Text(
                    "Apparairage récepteur",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }
}
