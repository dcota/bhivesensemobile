// ignore_for_file: unnecessary_const, avoid_print

import 'dart:convert';
import 'package:bhivesensemobile/apiaries.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';
import 'package:bhivesensemobile/models/Hive.dart';
import 'package:bhivesensemobile/hivedetails.dart';
import 'package:bhivesensemobile/map.dart';
import 'package:bhivesensemobile/menu.dart';

class HivesList extends StatefulWidget {
  const HivesList({super.key});

  @override
  State<HivesList> createState() => _HivesListState();
}

class _HivesListState extends State<HivesList> {
  bool showProgress = false;
  final userdata = GetStorage();
  static const c = Color(0xffebc002);
  final List<Hive> _hiveList = [];
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

  void showNoData() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('WARNING'),
        content: const SingleChildScrollView(
          child: ListBody(children: const <Widget>[
            const Text('No data for this hive!'),
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

  void showNoHives() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('WARNING'),
        content: const SingleChildScrollView(
          child: ListBody(children: const <Widget>[
            const Text('No hives in this apiary!'),
          ]),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const ApiaryList(),
              ));
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<List<Hive>> getHives() async {
    var hiveList = <Hive>[];
    try {
      Response response = await get(Uri.parse(
          'https://bhsapi.duartecota.com/device/forapiary/${userdata.read('apiaryIDtoget')}'));
      Map d = jsonDecode(response.body);
      if (d['body'].length == 0) {
        showNoHives();
      }
      for (var i = 0; i < d['body'].length; i++) {
        hiveList.add(Hive.fromJson(d['body'][i]));
      }
    } catch (e) {
      print(e);
    }

    return hiveList;
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
    getHives().then(
      (value) {
        setState(() {
          toggleSubmitState();
          _hiveList.addAll(value);
        });
      },
    );
    super.initState();
  }

  int currentIndex = 0;
  final screens = [
    const ApiaryList(),
  ];

  @override
  Widget build(BuildContext context) => WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
          backgroundColor: c,
          appBar: AppBar(
            backgroundColor: Colors.green,
            leading: Container(),
            automaticallyImplyLeading: false,
            title: Text(
              'Hi, ${userdata.read('firstname')}!',
              style: const TextStyle(color: Colors.white70, fontSize: 30),
            ),
            centerTitle: true,
          ),
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
                          Expanded(
                              child: ListView.builder(
                                  padding: const EdgeInsets.only(
                                      bottom: 80, top: 15, left: 40, right: 40),
                                  itemCount: _hiveList.length,
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
                                              title: const Text('Hive',
                                                  style:
                                                      TextStyle(fontSize: 30),
                                                  textAlign: TextAlign.center),
                                              subtitle: Text(
                                                  'ID${_hiveList[index].id}',
                                                  style: const TextStyle(
                                                      fontSize: 14.0),
                                                  textAlign: TextAlign.center),
                                            ),
                                            !_hiveList[index].state
                                                ? Center(
                                                    child: Container(
                                                        margin:
                                                            const EdgeInsets
                                                                .all(5.0),
                                                        color: const Color
                                                                .fromARGB(
                                                            255, 226, 233, 226),
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width -
                                                            50,
                                                        height: 30,
                                                        child: const Row(
                                                          children: const <Widget>[
                                                            const Expanded(
                                                                child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: const Text(
                                                                "Offline",
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        20,
                                                                    color: Colors
                                                                        .red),
                                                              ),
                                                            )),
                                                          ],
                                                        )),
                                                  )
                                                : Center(
                                                    child: Container(
                                                        margin:
                                                            const EdgeInsets
                                                                .all(5.0),
                                                        color: const Color
                                                                .fromARGB(
                                                            255, 226, 233, 226),
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width -
                                                            50,
                                                        height: 30,
                                                        child: const Row(
                                                          children: const <Widget>[
                                                            const Expanded(
                                                                child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: const Text(
                                                                "Online",
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        20,
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            6,
                                                                            158,
                                                                            11)),
                                                              ),
                                                            )),
                                                          ],
                                                        )),
                                                  ),
                                            ButtonBar(
                                              alignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                ElevatedButton.icon(
                                                  onPressed: () => {
                                                    !_hiveList[index].state
                                                        ? showNoData()
                                                        : userdata.write(
                                                            'lat',
                                                            _hiveList[index]
                                                                .lat),
                                                    userdata.write('lon',
                                                        _hiveList[index].lon),
                                                    Navigator.of(context)
                                                        .pushReplacement(
                                                            MaterialPageRoute(
                                                      builder: (context) =>
                                                          const MapPage(),
                                                    )),
                                                  },
                                                  icon: const Icon(Icons.map),
                                                  label: const Text('Map'),
                                                  style: ElevatedButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.white,
                                                      backgroundColor:
                                                          const Color.fromARGB(
                                                              255, 9, 150, 27),
                                                      elevation: 5,
                                                      minimumSize:
                                                          const Size(100, 35),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0))),
                                                ),
                                                ElevatedButton.icon(
                                                  onPressed: () => {
                                                    userdata.write(
                                                        'hiveIDtoget',
                                                        _hiveList[index].id),
                                                    Navigator.of(context)
                                                        .pushReplacement(
                                                            MaterialPageRoute(
                                                      builder: (context) =>
                                                          const HiveDetails(),
                                                    )),
                                                  },
                                                  icon: const Icon(
                                                      Icons.line_axis),
                                                  label: const Text('Data'),
                                                  style: ElevatedButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.white,
                                                      backgroundColor:
                                                          const Color.fromARGB(
                                                              255, 9, 106, 197),
                                                      elevation: 5,
                                                      minimumSize:
                                                          const Size(100, 35),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0))),
                                                ),
                                              ],
                                            )
                                          ]),
                                    );
                                  }))),
                        ]),
                  ),
          )),
          floatingActionButton: buildAddOfferButton(context)));
}

Widget buildAddOfferButton(BuildContext context) => FloatingActionButton(
    backgroundColor: const Color.fromARGB(166, 66, 66, 66),
    onPressed: () {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Menu(),
          ));
    },
    child: const Icon(Icons.arrow_back));
