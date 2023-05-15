// ignore_for_file: unnecessary_const, avoid_print

import 'dart:convert';
import 'package:bhivesensemobile/dashboard.dart';
import 'package:bhivesensemobile/logout.dart';
import 'package:bhivesensemobile/report.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';
import 'home.dart';
import 'hives.dart';
import 'package:bhivesensemobile/models/Apiary.dart';

class ApiaryList extends StatefulWidget {
  const ApiaryList({super.key});

  @override
  State<ApiaryList> createState() => _ApiaryListState();
}

class _ApiaryListState extends State<ApiaryList> {
  bool showProgress = false;
  final userdata = GetStorage();
  static const c = Color(0xffebc002);
  final List<Apiary> _apiaryList = [];
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

  /*Future<bool?> _showExitDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => _buildExitDialog(context),
    );
  }*/

  void showDetails(Apiary apiaryList) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Apiary details'),
        content: SingleChildScrollView(
          child: ListBody(children: <Widget>[
            Text('Location: ${apiaryList.location}'),
            Text('Address: ${apiaryList.address}'),
            Text('Observations: ${apiaryList.observations}'),
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

  Future<List<Apiary>> getApiaries() async {
    var apiaryList = <Apiary>[];
    try {
      Response response = await get(Uri.parse(
          'https://bhsapi.duartecota.com/apiary/${userdata.read('_id')}'));
      Map d = jsonDecode(response.body);
      for (var i = 0; i < d['body'].length; i++) {
        apiaryList.add(Apiary.fromJson(d['body'][i]));
      }
    } catch (e) {
      print("erro");
    }

    return apiaryList;
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
            Navigator.popUntil(context, ModalRoute.withName('/'));
          },
          child: const Text('Yes'),
        ),
      ],
    );
  }

  @override
  void initState() {
    toggleSubmitState();
    getApiaries().then(
      (value) {
        setState(() {
          toggleSubmitState();
          _apiaryList.addAll(value);
        });
      },
    );
    super.initState();
  }

  String bgImage = 'logo2.png';

  int currentIndex = 0;
  final screens = [
    const Dashboard(),
    const ApiaryList(),
    const Report(),
    const Logout()
  ];

  @override
  Widget build(BuildContext context) => WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        backgroundColor: c,
        /*appBar: AppBar(
            backgroundColor: Colors.white,
            leading: Container(),
            automaticallyImplyLeading: false,
            title: Text(
              'Hi, ${userdata.read('firstname')}!',
              style: const TextStyle(
                  color: Color.fromARGB(166, 66, 66, 66), fontSize: 25),
            ),
            centerTitle: true,
          ),*/
        body: Center(
            child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: showProgress
              ? const CircularProgressIndicator()
              : SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        const SizedBox(
                          height: 15.0,
                        ),
                        Expanded(
                            child: ListView.builder(
                                padding: const EdgeInsets.only(
                                    bottom: 80, left: 15, right: 15),
                                itemCount: _apiaryList.length,
                                itemBuilder: ((context, index) {
                                  return Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0)),
                                    color: const Color.fromARGB(
                                        255, 226, 233, 226),
                                    elevation: 10,
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: Image(
                                                image: AssetImage(
                                                    'assets/$bgImage'),
                                                fit: BoxFit.scaleDown,
                                                width: 100,
                                                alignment: Alignment.center),
                                            title: const Text(
                                              'Apiary',
                                              style: TextStyle(fontSize: 30),
                                            ),
                                            subtitle: Text(
                                              _apiaryList[index].id,
                                              style: const TextStyle(
                                                  fontSize: 14.0),
                                            ),
                                          ),
                                          Center(
                                            child: Container(
                                              margin: const EdgeInsets.all(5.0),
                                              color: const Color.fromARGB(
                                                  255, 226, 233, 226),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  50,
                                              height: 18,
                                              child: Text(
                                                "Location: ${_apiaryList[index].location}",
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              ),
                                            ),
                                          ),
                                          ButtonBar(
                                            alignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              ElevatedButton.icon(
                                                onPressed: () => {
                                                  showDetails(
                                                      _apiaryList[index])
                                                },
                                                icon: const Icon(Icons.zoom_in),
                                                label: const Text('Details'),
                                                style: ElevatedButton.styleFrom(
                                                    elevation: 5,
                                                    minimumSize:
                                                        const Size(100, 35),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0)),
                                                    onPrimary: Colors.white,
                                                    primary: Colors.green),
                                              ),
                                              ElevatedButton.icon(
                                                onPressed: () => {
                                                  userdata.write(
                                                      'apiaryIDtoget',
                                                      _apiaryList[index].id),
                                                  userdata.write(
                                                      'address',
                                                      _apiaryList[index]
                                                          .address),
                                                  userdata.write(
                                                      'location',
                                                      _apiaryList[index]
                                                          .location),
                                                  userdata.write(
                                                      'observations',
                                                      _apiaryList[index]
                                                          .observations),
                                                  Navigator.of(context)
                                                      .pushReplacement(
                                                          MaterialPageRoute(
                                                    builder: (context) =>
                                                        const HivesList(),
                                                  )),
                                                },
                                                icon: const Icon(Icons.zoom_in),
                                                label: const Text('Hives'),
                                                style: ElevatedButton.styleFrom(
                                                    elevation: 5,
                                                    minimumSize:
                                                        const Size(100, 35),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0)),
                                                    onPrimary: Colors.white,
                                                    primary:
                                                        const Color.fromARGB(
                                                            255, 9, 106, 197)),
                                              ),
                                            ],
                                          )
                                        ]),
                                  );
                                }))),
                      ]),
                ),
        )),
      ));
  //floatingActionButton: buildAddOfferButton(context)));
}

Widget buildAddOfferButton(BuildContext context) => FloatingActionButton(
    backgroundColor: const Color.fromARGB(166, 66, 66, 66),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyApp()),
      );
    },
    child: const Icon(Icons.exit_to_app));
