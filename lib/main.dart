import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {

  Completer<GoogleMapController> _controller = Completer();

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: FutureBuilder<Position>(
        future: currentLocation(),
        builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {

          return GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: LatLng(0, 0),
              zoom: 1,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: Set<Marker>.of(markers.values),
          );
        },
      )
      ,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        label: Text('Find me'),
        icon: Icon(Icons.directions_boat),
      ),
    );
  }



  void _add() async{
    Map<String, dynamic> people = await fetchPerson();
    final MarkerId markerId = MarkerId("1");
    Position location = await currentLocation();

    // creating a new MARKER
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(
        location.latitude,
        location.longitude,
      ),
      infoWindow: InfoWindow(title: "Beef", snippet: 'test'),
      icon: BitmapDescriptor.fromBytes(await getBytesFromAsset(Random().nextBool() == true ? "images/lewis.png" : "images/ben.png", 150)),
      onTap: () {
        pay(markerId);
      },
    );

    final MarkerId markerId2 = MarkerId("2");
    // creating a new MARKER
    final Marker marker2 = Marker(
      markerId: markerId2,
      position: LatLng(
        51.8217,
        -0.9786,
      ),
      infoWindow: InfoWindow(title: "Beef2", snippet: 'test2'),
      icon: BitmapDescriptor.fromBytes(await getBytesFromAsset(Random().nextBool() == true ? "images/lewis.png" : "images/ben.png", 150)),
      onTap: () {
        pay(markerId);
      },
    );

    setState(() {
      // adding a new marker to map
      markers[markerId] = marker;
      markers[markerId2] = marker2;
    });
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
  }

  Future<Position> currentLocation() async {
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(position.latitude ?? 0, position.longitude ?? 0),
      zoom: 20,
    )));
    return new Future(() => position);
  }

  void pay(MarkerId markerId) {
    print('lul');
  }

  Future<Map<String, dynamic>> fetchPerson() async {
    final response = await http.get("http://192.168.86.248:5000/users");

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.

      dynamic jsonDecoded = json.decode(response.body);
      Map<String, Person> people = Map();
      jsonDecoded.forEach((k, v) => people[k] = Person.fromJson(v));
      return jsonDecoded;
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }

  void sendLocation(String name) async {
    // set up POST request arguments
    String url = 'http://192.168.86.248:5000/users';
    Position position = await currentLocation();
    Map<String, String> headers = {"Content-type": "application/json"};
    Person person = Person.fromDefault(position.latitude, position.longitude, "bruh", name);
    String body = json.encode(person);
    Response response = await post(url, headers: headers, body: body);
    // check the status code for the result
    int statusCode = response.statusCode;
    // this API passes back the id of the new item added to the body
  }

}

class Person {
  final double lat;
  final double long;
  final String image;
  final String name;

  Person({this.lat, this.long, this.image, this.name});

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      lat: json['lat'],
      long: json['long'],
      image: json['image'],
      name: json['name'],
    );
  }

  factory Person.fromDefault(double lat, double long, String image, String name) {
    return Person(
      lat: lat,
      long: long,
      image: image,
      name: name,
    );
  }

}