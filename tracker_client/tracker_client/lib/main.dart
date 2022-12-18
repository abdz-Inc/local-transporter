import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:tracker_client/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Set<Marker> _mark = {};
  late GoogleMapController mapController;
  late BitmapDescriptor pinLocationIcon;

  @override
  void initState() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.5), 'assets/buscustom.png')
        .then((onValue) {
      pinLocationIcon = onValue;
    });
  }

  @override
  State<StatefulWidget> createState() {
    throw UnimplementedError();
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  Future<void> _setMarkers(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    for (var udoc in docs) {
      print("name : ${udoc.data()!["busId"]}");
      var city = "", src = "", des = "";
      String id = udoc.data()!["busId"];

      // while (businfo.data() == null) {}

      _mark.add(Marker(
        markerId: MarkerId(udoc.data()!["busId"]),
        position: LatLng(
            udoc.data()!["busLoc"].latitude, udoc.data()!["busLoc"].longitude),
        icon: pinLocationIcon,
        onTap: () {
          void createDialog(BuildContext context) async {
            await firestore.collection("busInfo").get().then((querySnapshot) {
              //print(querySnapshot);
              querySnapshot.docs.forEach((value) {
                print("users: results: value");
                if (value.data()!["uname"] == id) {
                  city = value.data()!["city"];
                  src = value.data()!["source"];
                  des = value.data()!["dest"];

                  // _buildPopupDialog(context, id, city, src, des);
                }
              });
            });
            //return [city, src, des];
          }

          showDialog(
              context: context,
              builder: (BuildContext context) {
                createDialog(context);
                print("src : $src, city : $city, des : $des");
                return _buildPopupDialog(context, id, city, src, des);
              });
        },
      ));
    }
  }

  Set<Marker> _getMarkers(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    _mark = {};
    _setMarkers(docs);
    return _mark;
  }

  Widget _buildPopupDialog(
      BuildContext context, String uname, String city, String src, String des) {
    return new AlertDialog(
      title: Center(child: const Text('Bus Info')),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Bus Name : $uname"),
          Text("City : $city"),
          Text("Source : $src"),
          Text("Destination : $des")
        ],
      ),
      actions: <Widget>[
        new ElevatedButton(
          onPressed: () {
            setState(() {});
          },
          //textColor: Theme.of(context).primaryColor,
          child: const Text('Refresh'),
        ),
        new ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          //textColor: Theme.of(context).primaryColor,
          child: const Text('Close'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: StreamBuilder(
            stream: firestore.collection("buslocation").snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Text("Loading...");
              else {
                return GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(10, 78),
                    zoom: 4,
                  ),
                  onMapCreated: _onMapCreated,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: _getMarkers(snapshot.data!.docs),
                );
              }
            }));
  }
}
