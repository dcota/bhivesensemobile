// ignore_for_file: unnecessary_const, avoid_print, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'package:bhivesensemobile/dashboard.dart';
import 'package:bhivesensemobile/hives.dart';
import 'package:bhivesensemobile/apiaries.dart';
import 'package:bhivesensemobile/plot.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';

import 'menu.dart';

class HiveDetails extends StatefulWidget {
  const HiveDetails({super.key});

  @override
  State<HiveDetails> createState() => _HiveDetailState();
}

class _HiveDetailState extends State<HiveDetails> {
  bool showProgress = false;
  final userdata = GetStorage();
  static const c = Color(0xffebc002);
  var _data = {};
  var render = true;
  var ti;
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

  void showNoData() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('WARNING'),
        content: SingleChildScrollView(
          child: ListBody(children: const <Widget>[
            const Text('No data for this hive!'),
          ]),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const HivesList(),
              ));
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<Map> getHiveData() async {
    var data = {};
    try {
      Response response = await get(Uri.parse(
          'https://bhsapi.duartecota.com/device/latest/${userdata.read('hiveIDtoget')}/${userdata.read('apiaryIDtoget')}'));
      Map d = jsonDecode(response.body);
      if (d['body'].length == 0) {
        render = false;
        showNoData();
      }
      ti = d['body']['data']['ti'];
      to = d['body']['data']['to'];
      hi = d['body']['data']['hi'];
      ho = d['body']['data']['ho'];
      s = d['body']['data']['s'];
      w = d['body']['data']['w'];
      var date = d['body']['data']['date'];
      var dateParsed = DateTime.parse(date);
      final localTime = dateParsed.toLocal();
      late final year;
      late final month;
      late final day;
      late final hours;
      late final minutes;
      year = localTime.year;
      localTime.month < 10
          ? month = '0' + localTime.month.toString()
          : month = localTime.month;
      localTime.day < 10
          ? day = '0' + localTime.day.toString()
          : day = localTime.day;
      _date = '$year-$month-$day';
      localTime.hour < 10
          ? hours = '0' + localTime.hour.toString()
          : hours = localTime.hour;
      localTime.hour < 10
          ? minutes = '0' + localTime.minute.toString()
          : minutes = localTime.minute;
      _time = '$hours:$minutes';
      data = d;
    } catch (e) {
      print(e);
    }
    return data;
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
    getHiveData().then(
      (value) {
        setState(() {
          toggleSubmitState();
          _data = value;
        });
      },
    );
    super.initState();
  }

  int currentIndex = 0;
  final screens = [
    const Dashboard(),
    const ApiaryList(),
  ];
  @override
  Widget build(BuildContext context) => WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
          backgroundColor: c,
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: Container(),
            automaticallyImplyLeading: false,
            title: Text(
              'Hi, ${userdata.read('firstname')}!',
              style: const TextStyle(
                color: Color.fromARGB(166, 66, 66, 66),
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
                      : render
                          ? Column(
                              children: [
                                const Padding(
                                    padding: EdgeInsets.only(top: 20)),
                                Text(
                                  'Last update: $_date at $_time',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Montserrat',
                                      fontSize: 20,
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
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: const Color.fromARGB(
                                              255, 226, 233, 226),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            const Icon(
                                              Icons.thermostat,
                                              size: 40,
                                            ),
                                            const Text(
                                              'Temperature(in)°C',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              '$ti',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 25,
                                              ),
                                            )
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
                                          const Icon(
                                            Icons.water_drop_rounded,
                                            size: 40,
                                          ),
                                          const Text(
                                            'Humidity(in)%',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            '$hi',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 25,
                                            ),
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
                                        children: <Widget>[
                                          const Icon(
                                            Icons.thermostat,
                                            size: 40,
                                          ),
                                          const Text(
                                            'Temperature(out)°C',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            '$to',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 25,
                                            ),
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
                                        children: <Widget>[
                                          const Icon(
                                            Icons.water_drop_rounded,
                                            size: 40,
                                          ),
                                          const Text(
                                            'Humidity(out)%',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            '$ho',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 25,
                                            ),
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
                                        children: <Widget>[
                                          const Icon(
                                            Icons.scale,
                                            size: 40,
                                          ),
                                          const Text(
                                            'Weight kg',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            '$w',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 25,
                                            ),
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
                                        children: <Widget>[
                                          const Icon(
                                            Icons.music_note,
                                            size: 40,
                                          ),
                                          const Text(
                                            'Sound level dB',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            '$s',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 25,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ))
                              ],
                            )
                          : null)),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.green,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            iconSize: 40,
            currentIndex: currentIndex,
            onTap: (index) => setState(() => currentIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.space_dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.house_siding_sharp),
                label: 'Apiaries',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.document_scanner_sharp),
                label: 'Report',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.logout_sharp),
                label: 'Logout',
              ),
            ],
          ),
          floatingActionButton: buildAddOfferButton(context)));
}

Widget buildAddOfferButton(BuildContext context) => FloatingActionButton(
    backgroundColor: const Color.fromARGB(166, 66, 66, 66),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Menu()),
      );
    },
    child: const Icon(Icons.arrow_back));
