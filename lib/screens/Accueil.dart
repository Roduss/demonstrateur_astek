import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'main.dart';
import 'package:demonstrateur_astek/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:demonstrateur_astek/db_utils/database_helper.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sqflite/sqflite.dart';

import 'Help.dart';
import 'Settings.dart';

///TODO :
///Gérer la snackbar qui s'affiche 2 fois et le discover service qui se refait à chaque fois !
///Régler les tonalités pour les pb de sharedpreferences
///
/// Page d'Accueil de l'application

enum TtsState { playing, stopped, paused, continued }

class Accueil extends StatefulWidget {
  double volume ;
  double pitch;
  double rate;
  String language;

  BluetoothDevice device;
  final BluetoothCharacteristic characteristic;


  Accueil({this.volume = 0.5, this.pitch =1, this.rate = 0.5, this.language = 'fr-FR', this.device, this.characteristic});
//On met des "named arguments" ici pour pouvoir les utiliser dans l'ordre qu'on veut


  @override
  _Accueil_State createState() {
    return _Accueil_State(this.volume, this.pitch, this.rate, this.language, this.device,this.characteristic);
  }
}

class _Accueil_State extends State<Accueil> {

  //Déclaration des variables
  final BluetoothDevice device;
  final BluetoothCharacteristic characteristic;

  List<BluetoothService> _services;

  FlutterTts flutterTts;
  dynamic languages;
  String language;
  double volume;
  double pitch ;
  double rate ;
  String mystate;

  int _buildWidget = 0;

  String _newVoiceText;

  TtsState ttsState = TtsState.stopped;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();



  //Constructeur & getters

  _Accueil_State(this.volume , this.pitch, this.rate, this.language, this.device,this.characteristic);



  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  get isPaused => ttsState == TtsState.paused;

  get isContinued => ttsState == TtsState.continued;




  @override
  initState() {
    super.initState();
    _get_shared();
    _getServices();

    initTts();
    print("value volume init : $volume , $pitch, $rate");
  }



  _getServices()async{
      await BluetoothDeviceState.connected;
      _services = await device.discoverServices();//Vérifie que la valeur de _service ait le temps de s'initialiser avant de construire le container
      //Sinon ajoute une condition dans la boucle for, à voir !


      setState(() {
        _services;
        _buildWidget =_buildWidget+1;
      });
      print("buildwidget vaut $_buildWidget");
  }


  //Permet de récupérer la liste des langages disponibles
  initTts() {
    flutterTts = FlutterTts();

    _getLanguages();
  }
  Future<String> _getdeviceState() async{
    String _state = await device.state.toString();
    return _state;
  }

  Future _getLanguages() async {
    languages = await flutterTts.getLanguages;
    if (languages != null) setState(() => languages);
  }


  Future <Null> _get_shared() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final key4 = 'volume';
    final key5 = 'pitch';
    final key6 =  'rate';
   // final key7 = 'language';


    final value4 = prefs.getDouble(key4) ?? 0.5;
    final value5 = prefs.getDouble(key5) ?? 1;
    final value6 = prefs.getDouble(key6) ?? 0.5;
    //final value7 = prefs.getString(key7) ??'fr-FR';


    setState(() {
      volume = value4;
      pitch = value5;
      rate = value6;
      //language = value7;

    });
  }


  //Permet d'utiliser les hauts parleurs du smartphone
  Future _speak() async {

    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);
    print("Val volume : $volume, rate : $rate pitch : $pitch");
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

  ///Bluetooth part
  ///

  List<ButtonTheme> _buildReadWriteNotifyButton(
      BluetoothCharacteristic characteristic) {
    List<ButtonTheme> buttons = new List<ButtonTheme>();
  if(_buildWidget == 1){
    if (characteristic.properties.notify) {
      characteristic.setNotifyValue(true);
      print("notification listening");

    }
  }


    return buttons;
  }


  ListView _buildConnectDeviceView()  {
    List<Container> containers = new List<Container>();


  if(_buildWidget == 1){
    print("We are BUILDING SERVICES");
    for (BluetoothService service in _services) {
      List<Widget> characteristicsWidget = new List<Widget>();

      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if(characteristic.properties.notify){
          characteristicsWidget.add(

            Center(

              child: Column(
                children: <Widget>[
                  Align(alignment: Alignment.center,
                  child: StreamBuilder<List<int>>(
                    stream: characteristic.value,
                    initialData: characteristic.lastValue,
                    builder: (c, snapshot){

                      final value = snapshot.data;
                      if(snapshot.hasData && value.toString().length >2){
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scaffoldKey.currentState.showSnackBar(
                            SnackBar( content:
                            Center(

                                child: Text(((){

                                  String _val = value.toString();
                                  String _newcode = "";
                                  String res = "";
                                  int _code = 0;
                                  print("Val de la longueur de val: ${_val.length}");
                                  if (_val.length > 2) {
                                    for (int i = 0; i < _val.length / 4; i++) {
                                      //print("Val $i : ${value[i]}");
                                      _code = value[i] - 48;

                                      _newcode = _newcode + _code.toString();
                                    }
                                    print("Equivalent ds code : $_newcode");
                                  }
                                  res = "Code barre reçu : " + _newcode;
                                  _onChange(res);
                                  return res;

                                })())

                                  ,


                            )
                        ),
                          );
                        });
                      }
                      return Container();



                    },
                  ),
                    ),


                  Row(
                    children: <Widget>[
                      ..._buildReadWriteNotifyButton(characteristic),

                    ],
                  ),

                  Divider(),
                ],
              ),
            ),
          );
        }

      }
      containers.add(
        Container(
            child: Column(
              children: characteristicsWidget,
            ) ),

      );
    }
  }



    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      key: _scaffoldKey,
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
                        builder: (BuildContext context) => FindDevicesScreen(

                            )));
                  },
                  child: Text(
                    "Apparairage récepteur",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  color: Colors.grey,
                ),
              ),
              _buildConnectDeviceView(),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message),
    action: SnackBarAction(
      label: "Connecté à ${device.name}",
      onPressed: null,
    ),);
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
