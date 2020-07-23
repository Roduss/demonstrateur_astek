import 'package:flutter/material.dart';
import 'Accueil.dart';
import 'Help.dart';
import 'package:flutter/rendering.dart';
import 'package:demonstrateur_astek/size_config.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_blue/flutter_blue.dart';

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

///Deprecated

///Redirection vers la page d'appairage automatique
class Delimitor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        //Delimiteur entre chaque data.
        height: 20,
        child: Center(
            child: Container(
          margin: EdgeInsetsDirectional.only(start: 1.0, end: 1.0),
          height: 2,
          color: Colors.black,
        )));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final List<BluetoothDevice> devicesList = new List<BluetoothDevice>();
  final Map<Guid, List<int>> readValues = new Map<Guid, List<int>>();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ScanResult result;
  final _writeController = TextEditingController();
  BluetoothDevice _connectedDevice;
  List<BluetoothService> _services;
  //Fonction pour rediriger vers l'accueil
  _pushtoAccueil() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) => Accueil()));
  }

  _addDeviceTolist(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
      setState(() {
        widget.devicesList.add(device);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _addDeviceTolist(device);
      }
    });
    widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (result in results) {
        _addDeviceTolist(result.device);
      }
    });
    widget.flutterBlue.startScan(timeout: Duration(seconds: 4));
  }

  ListView _buildListViewOfDevices() {
    List<Container> containers = new List<Container>();
    for (BluetoothDevice device in widget.devicesList) {
      containers.add(
        Container(
          margin: EdgeInsets.only(bottom: 20),
          height: 50,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    AutoSizeText(
                      device.name == '' ? '(unknown device)' : device.name,
                      style: TextStyle(
                        fontSize: 30,
                      ),
                      maxLines: 1,
                    ),
                    Text(device.id.toString()),
                  ],
                ),
              ),
              FlatButton(
                color: Colors.blue,
///TODO : a recheck si ça tourne ou pas.
                child: //((() {
                 /* if (_connectedDevice.name == device) {
                    Text(
                      'Disconnect',
                      style: TextStyle(color: Colors.white),
                    );
                  } else {
                    Text(
                      'Connect',
                      style: TextStyle(color: Colors.white),
                    );
                  }
                }())),*/
                 Text(
                 'Connect',
                 style: TextStyle(color: Colors.white),
    ),
                onPressed: () async {
                  widget.flutterBlue.stopScan();
                  try {
                    await device.connect();
                  } catch (e) {
                    if (e.code != 'already_connected') {
                      throw e;
                    }
                  } finally {
                    _services = await device.discoverServices();
                  }
                  setState(() {
                    _connectedDevice = device;
                    print("Connecté : $_connectedDevice");
                  });
                },
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
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
      appBar: AppBar(
          centerTitle: true,
          title: Text(
            widget.title,
          ),
          actions: <Widget>[
            Image.asset('images/logo_astek.png'),
          ]),
      body: _buildListViewOfDevices(),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () => FlutterBlue.instance
                    .startScan(timeout: Duration(seconds: 4)));
          }
        },
      ),
    );
  }

  //Cette fonction permet d'afficher une SnackBar, elle peut etre utile dans une future version
  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }
}
