// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:_flutterfire_internals/_flutterfire_internals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'package:tracker_app/firebase_options.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class UserLocation {
  late double lat, lon;
  UserLocation({required this.lat, required this.lon});
}

class LocationService {
  var loc = Location();
  late LocationData cur;
  StreamController<UserLocation> controller = StreamController<UserLocation>();
  Stream<UserLocation> get locStream => controller.stream;

  LocationService() {
    print("requesting permission");
    loc.requestPermission().then((granted) async {
      var stat = await loc.hasPermission();
      if (stat == PermissionStatus.granted ||
          stat == PermissionStatus.grantedLimited) {
        print("permission granted ....");
        loc.onLocationChanged.listen((locdata) {
          print("locdata : $locdata");
          if (locdata != null) {
            print("${locdata.latitude}, ${locdata.longitude}");
            controller.add(
                UserLocation(lat: locdata.latitude!, lon: locdata.longitude!));
          }
        });
      }
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BusId(),
    );
  }
}

class BusId extends StatelessWidget {
  final myController = TextEditingController();
  bool auth = true;
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              child: Container(
            height: 500,
            decoration: BoxDecoration(),
          )),
          Center(
            child: Text(" ENTER YOUR ID: "),
          ),
          Expanded(
            child: Container(
              width: 300,
              height: 100,
              child: TextField(
                controller: myController,
              ),
            ),
          ),
          ElevatedButton(
              onPressed: () async {
                try {
                  DocumentSnapshot ds = await firestore
                      .collection("buslocation")
                      .doc(myController.text)
                      .get();
                  auth = ds.exists;
                } finally {
                  if (auth) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: ((context) => MyHomePage(
                              title: "Bustrack - Driver",
                              uname: myController.text,
                            )),
                      ),
                    );
                    // Navigator.pop(context);
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => AlertDialog(
                                  title: const Text('Alert'),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: const <Widget>[
                                        Text('This ID does not exist'),
                                        Text('kindly check again'),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Approve'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ))));
                  }
                }
              },
              child: Text("ENTER")),
          Container(
            height: 200,
          )
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title, required this.uname})
      : super(key: key);

  final String title;
  final String uname;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late BitmapDescriptor pinLocationIcon;
  // late BitmapDescriptor pinLocationIcon1;
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(10, 50);

  final FirebaseFirestore db = FirebaseFirestore.instance;

  Set<Marker> _mark = {};

  @override
  void initState() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.5), 'assets/buscustom.png')
        .then((onValue) {
      pinLocationIcon = onValue;
    });
    // BitmapDescriptor.fromAssetImage(
    //         ImageConfiguration(devicePixelRatio: 2.5), 'assets/abimark.png')
    //     .then((onValue) {
    //   pinLocationIcon1 = onValue;
    // });
  }

  Future<LatLng> get _start async {
    var l = await Location().getLocation();
    return LatLng(l.latitude!, l.longitude!);
  }

  Future<void> _onBitMapGen() async {
    // BitmapDescriptor.fromAssetImage(
    //         ImageConfiguration(devicePixelRatio: 2.5), 'assets/abimark.png')
    //     .then((onValue) {
    //   pinLocationIcon2 = onValue;
    // });

    // BitmapDescriptor.fromAssetImage(
    //         ImageConfiguration(devicePixelRatio: 2.5), 'assets/abimark.png')
    //     .then((onValue) {
    //   pinLocationIcon = onValue;
    // });
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    setState(() {
      _mark;
    });
  }

  // Set<Marker> _getMark() {
  //   Stream snap = firestore.collection('usrlog').snapshots();
  //   var sub = snap.listen((snapshot) {
  //     int i = 0;
  //     for (var udoc in snapshot.data.docs) {
  //       print("name : ${udoc.data()!["uname"]}");
  //       _mark.add(
  //         Marker(
  //           markerId: MarkerId(udoc.data()!["uname"]),
  //           position: LatLng(
  //               udoc.data()!["uloc"].latitude, udoc.data()!["uloc"].longitude),
  //           icon: pinLocationIcon,
  //         ),
  //       );
  //       i++;
  //     }
  //   });
  // db.collection("usrlog").doc("abini").get().then((value) {
  //   _mark.add(
  //     Marker(
  //       markerId: MarkerId(doc.docs[0].data()["uname"]),
  //       position: LatLng(
  //           value.data()!["uloc"].latitude, value.data()!["uloc"].longitude),
  //       icon: pinLocationIcon,
  //     ),
  //   );
  // });
  // print("abdz cu values $lat1, $lon1");
  // final locstream = LocationService().locStream;
  // var sub = locstream.listen((usrLoc) {
  //   print("Subscrition started ${usrLoc.lat} , ${usrLoc.lon}");
  //   db
  //       .collection("usrlog")
  //       .doc("abdz")
  //       .update({"uloc": GeoPoint(usrLoc.lat, usrLoc.lon)});
  // db.collection("usrlog").doc("abdz").get().then((value) {
  //   print(
  //       "set abdz ${value.data()!["uname"]} ${value.data()!["uloc"].latitude}");
  // });
  // _mark.add(
  //   Marker(
  //     markerId: MarkerId(doc.docs[1].data()["uname"]),
  //     position: LatLng(usrLoc.lat, usrLoc.lon),
  //     icon: pinLocationIcon1,
  //   ),
  // );
  // });

  //   return _mark;
  // }

  @override
  Widget build(BuildContext context) {
    //CollectionReference loc = ;

    print("\n\n Build method \n\n");

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: StreamBuilder(
            stream: LocationService().locStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Text("Loading...");
              } else {
                print("updating location...");
                firestore.collection("buslocation").doc(widget.uname).update({
                  "busLoc": GeoPoint(snapshot.data!.lat, snapshot.data!.lon)
                });
                // print(firestore
                //     .collection("busLocation")
                //     .doc(widget.uname)
                //     .get());
                return GoogleMap(
                  onMapCreated: _onMapCreated,
                  myLocationEnabled: true,
                  //markers: _getMark(),
                  myLocationButtonEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 4,
                  ),
                );
              }
            }));
  }
}
