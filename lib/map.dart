// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:async';
import 'package:bhivesensemobile/hives.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'package:bhivesensemobile/hivedetails.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool showProgress = false;
  static const c = Color(0xffebc002);
  final userdata = GetStorage();
  late final lat;
  late final lon;
  late final address;
  late final location;
  late final observations;
  final Completer<GoogleMapController> _controller = Completer();
  late final CameraPosition _kGooglePlex;
  final List<Marker> _markers = <Marker>[];
  final List<LatLng> __points = <LatLng>[];

  void toggleSubmitState() {
    setState(() {
      showProgress = !showProgress;
    });
  }

  Future<bool> _onWillPop(BuildContext context) async {
    bool? exitResult = await showDialog(
      context: context,
      builder: (context) => _buildExitDialog(context),
    );
    return exitResult ?? false;
  }

  showDetails() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('APIARY'),
        content: SingleChildScrollView(
          child: ListBody(children: <Widget>[
            Text('Address: $address'),
            Text('Location: $location'),
            Text('Observations: $observations'),
          ]),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  getCoordinates() async {
    lat = userdata.read('lat');
    lon = userdata.read('lon');
    address = userdata.read('address');
    location = userdata.read('location');
    observations = userdata.read('observations');
    _kGooglePlex = CameraPosition(
      target: LatLng(lat.toDouble(), lon.toDouble()),
      zoom: 16,
    );
    __points.add(LatLng(lat, lon));
    _markers.add(
      Marker(
          markerId: const MarkerId('SomeId'),
          position: LatLng(lat.toDouble(), lon.toDouble()),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          onTap: () {
            showDetails();
          }),
    );
  }

  AlertDialog _buildExitDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Please confirm'),
      content: const Text('Do you want to exit the app?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () {
            //Navigator.popUntil(context, ModalRoute.withName('/'));
          },
          child: const Text('Yes'),
        ),
      ],
    );
  }

  @override
  void initState() {
    toggleSubmitState();
    getCoordinates();
    toggleSubmitState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: c,
            leading: Container(),
            automaticallyImplyLeading: false,
            title: Text(
              'Hi, ${userdata.read('firstname')}!',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 25,
              ),
            ),
            centerTitle: true,
          ),
          body: Center(
              child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: showProgress
                ? const CircularProgressIndicator()
                : GoogleMap(
                    mapType: MapType.normal,
                    markers: Set<Marker>.of(_markers),
                    initialCameraPosition: _kGooglePlex,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                  ),
          )),
          floatingActionButton: buildAddOfferButton(context)));
}

Widget buildAddOfferButton(BuildContext context) => FloatingActionButton(
    backgroundColor: const Color.fromARGB(166, 66, 66, 66),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HivesList()),
      );
    },
    child: const Icon(Icons.arrow_back));
