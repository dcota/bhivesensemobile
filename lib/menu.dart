// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_typing_uninitialized_variables, avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:bhivesensemobile/dashboard.dart';
import 'package:bhivesensemobile/logout.dart';
import 'package:bhivesensemobile/report.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:bhivesensemobile/apiaries.dart';
import 'package:badges/badges.dart';
import 'package:http/http.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  Future<bool> _onWillPop(BuildContext context) async {
    bool? exitResult = await showDialog(
      context: context,
      builder: (context) => _buildExitDialog(context),
    );
    return exitResult ?? false;
  }

  Future<bool?> _showExitDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => _buildExitDialog(context),
    );
  }

  AlertDialog _buildExitDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Please confirm'),
      content: const Text('Do you want to exit the app?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('No'),
        ),
        TextButton(
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName('/'));
            SystemNavigator.pop();
          },
          child: Text('Yes'),
        ),
      ],
    );
  }

  int currentIndex = 0;
  final screens = <Widget>[
    Dashboard(),
    ApiaryList(),
    Report(),
    Logout(),
  ];

  final userdata = GetStorage();
  var _nevents = 0;
  var old = 0;
  Timer? timer;
  bool render = false;

  getNumEvents() async {
    var nevents = 0;
    try {
      Response response = await get(Uri.parse(
          'https://bhsapi.duartecota.com/event/num/${userdata.read('_id')}'));
      Map d = jsonDecode(response.body);
      nevents = d['body'];
      if (nevents == 0) render = false;
    } catch (e) {
      print(e);
    }
    return nevents;
  }

  @override
  void initState() {
    super.initState();
    getNumEvents().then(
      (value) {
        setState(() {
          render = true;
          _nevents = value;
          if (old != _nevents) {
            old = _nevents;
          }
        });
      },
    );
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) {
      getNumEvents().then(
        (value) {
          if (mounted) {
            setState(() {
              _nevents = value;
              if (old != _nevents) {
                old = _nevents;
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => Menu()));
              }
            });
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () => _onWillPop(context),
        child: Scaffold(
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
          body: Container(
            child: screens.elementAt(currentIndex),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.green,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            iconSize: 40,
            currentIndex: currentIndex,
            onTap: (index) => setState(() => currentIndex = index),
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: render
                    ? Badge(
                        badgeContent: Text(
                          _nevents.toString(),
                          style: TextStyle(color: Colors.white),
                        ),
                        child: Icon(Icons.dashboard_rounded),
                      )
                    : Icon(Icons.settings),
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
        ),
      );
}
