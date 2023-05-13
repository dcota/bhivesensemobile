// ignore_for_file: unnecessary_const, avoid_print, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'package:bhivesensemobile/hives.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

import 'hivedetails.dart';

class Plot extends StatefulWidget {
  const Plot({super.key});

  @override
  State<Plot> createState() => _PlotState();
}

class _PlotState extends State<Plot> {
  bool showProgress = true;
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
  var title = 'Temperature(inside)°C';

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

  void showNoHives() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('WARNING'),
        content: SingleChildScrollView(
          child: ListBody(children: const <Widget>[
            const Text('No Hives in this apiary!'),
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
    /*getHiveData().then(
      (value) {
        setState(() {
          toggleSubmitState();
          _data = value;
        });
      },
    );*/
    super.initState();
  }

  final List<FlSpot> dummyData1 = List.generate(8, (index) {
    return FlSpot(index.toDouble(), index * Random().nextDouble());
  });

  // This will be used to draw the orange line
  final List<FlSpot> dummyData2 = List.generate(8, (index) {
    return FlSpot(index.toDouble(), index * Random().nextDouble());
  });

  // This will be used to draw the blue line
  final List<FlSpot> dummyData3 = List.generate(8, (index) {
    return FlSpot(index.toDouble(), index * Random().nextDouble());
  });

  @override
  Widget build(BuildContext context) => WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: Container(),
            automaticallyImplyLeading: false,
            title: Text(
              title,
              style: const TextStyle(
                color: Color.fromARGB(166, 66, 66, 66),
                fontSize: 22,
              ),
            ),
            centerTitle: true,
          ),
          body: Center(
              child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: showProgress
                      ? const CircularProgressIndicator()
                      : Container(
                          padding: const EdgeInsets.all(20),
                          width: double.infinity,
                          height: 500,
                          child: Stack(
                            children: <Widget>[
                              LineChart(
                                LineChartData(
                                  borderData: FlBorderData(
                                    show: false,
                                  ),
                                  titlesData: FlTitlesData(
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                          showTitles: true, reservedSize: 30),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                          showTitles: true, reservedSize: 30),
                                    ),
                                  ),
                                  lineBarsData: [
                                    // The red line
                                    LineChartBarData(
                                      spots: dummyData1,
                                      isCurved: true,
                                      barWidth: 2,
                                      color: Colors.red,
                                    ),
                                    // The orange line
                                    LineChartBarData(
                                      spots: dummyData2,
                                      isCurved: true,
                                      barWidth: 2,
                                      color: Colors.orange,
                                    ),
                                    // The blue line
                                    LineChartBarData(
                                      spots: dummyData3,
                                      isCurved: false,
                                      barWidth: 2,
                                      color: Colors.blue,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          )))),
          floatingActionButton: buildAddOfferButton(context)));
}

Widget buildAddOfferButton(BuildContext context) => FloatingActionButton(
    backgroundColor: const Color.fromARGB(166, 66, 66, 66),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HiveDetails()),
      );
    },
    child: const Icon(Icons.arrow_back));
