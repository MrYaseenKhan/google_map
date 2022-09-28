import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Completer<GoogleMapController> completer = Completer();
  TextEditingController controller = TextEditingController();
  String address = '';
  var uuid = const Uuid();
  String sessionToken = '123';
  List<dynamic> listOfPlaces = [];

  static const initialCameraPosition = CameraPosition(
      target: LatLng(
        30.167528886137113,
        71.52683104664801,
      ),
      zoom: 10.0);
  List<Marker> marker = [];
  final Set<Marker> singleMarker = {};
  final Set<Polyline> polyLine = {};

  List<LatLng> listOdLatLng = [
    const LatLng(30.167528886137113, 71.52683104664801),
    const LatLng(29.356576047361035, 71.69309890915986),
    const LatLng(29.41610643299476, 71.74631393571896),
    const LatLng(29.35660370571456, 71.54117964454791),
    const LatLng(30.2547562048808, 71.62021483519047),
    const LatLng(30.076146184137563, 71.17552282810797),
  ];
  List<Marker> listOfMarker = [
    const Marker(
      markerId: MarkerId('1'),
      position: LatLng(
        30.167528886137113,
        71.52683104664801,
      ),
      infoWindow: InfoWindow(title: 'Welcome To Multan', snippet: '@@@@@'),
    ),
    const Marker(
      markerId: MarkerId('2'),
      position: LatLng(29.356576047361035, 71.69309890915986),
      infoWindow: InfoWindow(title: 'Welcome To Bahawalpur', snippet: '@@@@@'),
    ),
    const Marker(
      markerId: MarkerId('2'),
      position: LatLng(20.76625724610842, 73.03731601080378),
      infoWindow: InfoWindow(title: 'Welcome To Delhi', snippet: '@@@@@'),
    ),
  ];

  @override
  void initState() {
    //yass
    // TODO: implement initState
    for (int i = 0; i < listOdLatLng.length; i++) {
      singleMarker.add(
        Marker(
            markerId: MarkerId(i.toString()),
            infoWindow: const InfoWindow(
                title: 'Really Cool Place', snippet: '7 Stare Rating'),
            position: listOdLatLng[i],
            icon: BitmapDescriptor.defaultMarker),
      );
      setState(() {
        polyLine.add(
          Polyline(
            polylineId: const PolylineId('1'),
            points: listOdLatLng,
            color: Colors.blue,
            width: 5,
            endCap: Cap.roundCap,
            jointType: JointType.round,
            startCap: Cap.buttCap
          ),
        );
      });
    }
    // marker.addAll(listOfMarker);

/*    controller.addListener(() {
      onChange();
    });*/
  
    super.initState();
  }

  void onChange() {
    if (sessionToken.isEmpty) {
      setState(() {
        sessionToken = uuid.v4();
      });
    } else {
      getSuggestion(controller.text);
    }
  }

  void getSuggestion(String input) async {
    var baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String googleApiKey = 'AIzaSyANju_-7oQUT_F7RtnX7GFff7fzg8luGEk';
    String request =
        '$baseURL?input=$input&key=$googleApiKey&sessiontoken=$sessionToken';
    Response response = await http.get(Uri.parse(request));
    print('..............................Status.............${response.body}');
    if (response.statusCode == 200) {
      setState(() {
        listOfPlaces = jsonDecode(response.body.toString())['predictions'];
      });
    } else {
      throw const HttpException('Failed to load data');
    }
  }

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print('....................error................$error');
    });
    return await Geolocator.getCurrentPosition();
  }

  Future<void> moveSpecificPoint() async {
    GoogleMapController controller = await completer.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(
            zoom: 14, target: LatLng(20.76625724610842, 73.03731601080378)),
      ),
    );
  }

  Future<String> convertLatLngIntoAddress() async {
    List<Placemark> newPlaceMark =
        await placemarkFromCoordinates(29.35837144253963, 71.69344223191186);
    Placemark placeMark = newPlaceMark[0];
    String? name = placeMark.name;
    String? subLocality = placeMark.subLocality;
    String? locality = placeMark.locality;
    String? postalCode = placeMark.postalCode;
    String? country = placeMark.country;
    String? newAddress =
        '$name, $subLocality, $locality, $postalCode, $country';
    print(newAddress);
    return address = newAddress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Search...',
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialCameraPosition,
            mapType: MapType.normal,
            compassEnabled: true,
            markers: singleMarker,
            polylines: Set<Polyline>.of(polyLine),
            myLocationButtonEnabled: true,
            onMapCreated: (controller) {
              completer.complete(controller);
            },
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        moveSpecificPoint();
                      });
                    },
                    child: const Icon(Icons.pin_drop),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  FloatingActionButton.extended(
                    onPressed: () {
                      setState(() {
                        convertLatLngIntoAddress();
                      });
                    },
                    label: const Center(child: Text('Convert')),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  FloatingActionButton.extended(
                    onPressed: () {
                      getUserCurrentLocation().then((value) {
                        print(
                            '................User ...................${value.latitude}   and ${value.longitude}');
                      });
                    },
                    label: const Center(child: Text('Current Location')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
