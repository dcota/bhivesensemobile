// ignore_for_file: unnecessary_const, avoid_print, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'package:bhivesensemobile/hives.dart';
import 'package:bhivesensemobile/apiaries.dart';
import 'package:bhivesensemobile/logout.dart';
import 'package:bhivesensemobile/plot.dart';
import 'package:bhivesensemobile/report.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool showProgress = false;
  final userdata = GetStorage();
  static const c = Color(0xffebc002);
  var render = false;
  var _nevents = 0;
  var _ninterventions = 0;
  var _nharvest = 0;
  var _nswarm = 0;
  var _production = 0;
  var hi;
  var to;
  var ho;
  var s;
  var w;
  var _date;
  var _time;
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

  Future getEvents() async {
    getNumEvents();
  }

  Future<int> getNumEvents() async {
    var nevents;
    try {
      Response response = await get(Uri.parse(
          'https://bhsapi.duartecota.com/event/num/${userdata.read('_id')}'));
      Map d = jsonDecode(response.body);
      nevents = d['body'];
    } catch (e) {
      print(e);
    }
    return nevents;
  }

  Future<int> getProduction() async {
    var production;
    try {
      Response response = await get(Uri.parse(
          'https://bhsapi.duartecota.com/harvest/total/${userdata.read('_id')}'));
      Map d = jsonDecode(response.body);
      production = d['body']['totalProduction'];
    } catch (e) {
      print(e);
    }
    return production;
  }

  Future<int> getHarvest() async {
    var nharvest;
    int cont = 0;
    try {
      Response response = await get(Uri.parse(
          'https://bhsapi.duartecota.com/event/${userdata.read('_id')}'));
      Map d = jsonDecode(response.body);
      for (var i = 0; i < d['body'].length; i++) {
        if (d['body'][i]['type'] == 'HARVEST') cont++;
      }
      nharvest = cont;
      print(cont);
    } catch (e) {
      print(e);
    }
    return nharvest;
  }

  Future<int> getSwarm() async {
    var nswarm;
    int cont = 0;
    try {
      Response response = await get(Uri.parse(
          'https://bhsapi.duartecota.com/event/${userdata.read('_id')}'));
      Map d = jsonDecode(response.body);
      for (var i = 0; i < d['body'].length; i++) {
        if (d['body'][i]['type'] == 'SWARM') cont++;
      }
      nswarm = cont;
      print(cont);
    } catch (e) {
      print(e);
    }
    return nswarm;
  }

  Future<int> getInterventions() async {
    var ninterventions;
    try {
      Response response = await get(Uri.parse(
          'https://bhsapi.duartecota.com/intervention/notify/${userdata.read('_id')}'));
      Map d = jsonDecode(response.body);
      ninterventions = d['body'].length;
    } catch (e) {
      print(e);
    }
    return ninterventions;
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
    getNumEvents().then(
      (value) {
        setState(() {
          _nevents = value;
        });
      },
    );
    getInterventions().then(
      (value) {
        setState(() {
          _ninterventions = value;
        });
      },
    );
    getHarvest().then(
      (value) {
        setState(() {
          _nharvest = value;
        });
      },
    );
    getSwarm().then(
      (value) {
        setState(() {
          _nswarm = value;
        });
      },
    );
    getProduction().then(
      (value) {
        setState(() {
          toggleSubmitState();
          _production = value;
          render = true;
        });
      },
    );
    super.initState();
  }

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
        body: Center(
            child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: showProgress
                    ? const CircularProgressIndicator()
                    : render
                        ? Column(
                            children: [
                              const Padding(padding: EdgeInsets.only(top: 20)),
                              const Text(
                                'My Dashboard',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Montserrat',
                                    fontSize: 30,
                                    color: Color.fromARGB(166, 66, 66, 66)),
                              ),
                              Expanded(
                                  child: GridView(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 20,
                                        crossAxisSpacing: 20),
                                padding: const EdgeInsets.all(30.0),
                                children: <Widget>[
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context)
                                          .pushReplacement(MaterialPageRoute(
                                        builder: (context) => const Plot(),
                                      ));
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: const Color.fromARGB(
                                            255, 226, 233, 226),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          _nevents > 0
                                              ? const Icon(
                                                  Icons.warning_rounded,
                                                  size: 60,
                                                  color: Colors.red,
                                                )
                                              : const Icon(Icons.check_circle,
                                                  size: 60,
                                                  color: Colors.green),
                                          _nevents > 0
                                              ? const Text(
                                                  'Active events',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      color: Colors.red),
                                                )
                                              : const Text(
                                                  'No active events',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      color: Colors.green),
                                                ),
                                          /*_nevents > 0
                                              ? Text(
                                                  '$_nevents',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 25,
                                                      color: Colors.red),
                                                )
                                              : Text(
                                                  '$_nevents',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 25,
                                                      color: Colors.green),
                                                )*/
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: const Color.fromARGB(
                                          255, 226, 233, 226),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: const Color.fromARGB(
                                                255, 226, 233, 226),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              _ninterventions > 0
                                                  ? const Icon(
                                                      Icons.settings_rounded,
                                                      size: 60,
                                                      color: c)
                                                  : const Icon(
                                                      Icons.check_circle,
                                                      size: 60,
                                                      color: Colors.green),
                                              _ninterventions > 0
                                                  ? const Text(
                                                      'Interventions',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                          color: c),
                                                    )
                                                  : const Text(
                                                      'No interventions',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                          color: Colors.green),
                                                    ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: const Color.fromARGB(
                                          255, 226, 233, 226),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        _nharvest > 0
                                            ? const Icon(Icons.settings,
                                                size: 60, color: c)
                                            : const Icon(Icons.check_circle,
                                                size: 60, color: Colors.green),
                                        _nharvest > 0
                                            ? const Text(
                                                'Harvest!',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: c),
                                              )
                                            : const Text(
                                                'No harvest',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: Colors.green),
                                              ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: const Color.fromARGB(
                                          255, 226, 233, 226),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        _nswarm > 0
                                            ? const Icon(Icons.settings,
                                                size: 60, color: c)
                                            : const Icon(Icons.check_circle,
                                                size: 60, color: Colors.green),
                                        _nswarm > 0
                                            ? const Text(
                                                'Possible swarming!',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: c),
                                              )
                                            : const Text(
                                                'No swarming',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: Colors.green),
                                              ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: const Color.fromARGB(
                                          255, 226, 233, 226),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        const Icon(
                                          Icons.scale_rounded,
                                          size: 40,
                                          color: Colors.blue,
                                        ),
                                        const Text(
                                          'Total production',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.blue),
                                        ),
                                        Text(
                                          '$_production kg',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 25,
                                              color: Color.fromARGB(
                                                  255, 8, 41, 230)),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: const Color.fromARGB(
                                          255, 226, 233, 226),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const <Widget>[
                                        const Icon(Icons.description_rounded,
                                            size: 40, color: Colors.blue),
                                        const Text(
                                          'System log',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.blue),
                                        ),
                                        /*Text(
                                          '$s',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25,
                                            color:
                                                Color.fromARGB(255, 8, 41, 230),
                                          ),
                                        )*/
                                      ],
                                    ),
                                  ),
                                ],
                              ))
                            ],
                          )
                        : null)),
      ));
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
