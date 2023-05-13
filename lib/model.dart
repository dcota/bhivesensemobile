// ignore_for_file: unnecessary_const

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'home.dart';

class ApiaryList extends StatefulWidget {
  const ApiaryList({super.key});

  @override
  State<ApiaryList> createState() => _ApiaryListState();
}

class _ApiaryListState extends State<ApiaryList> {
  bool showProgress = false;
  final userdata = GetStorage();
  static const c = Color(0xffebc002);

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
    /*getOffers().then(
      (value) {
        setState(() {
          toggleSubmitState();
          _offerList.addAll(value);
        });
      },
    );*/
    super.initState();
    //getOffers();
  }

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
                  color: Color.fromARGB(166, 66, 66, 66), fontSize: 25),
            ),
            centerTitle: true,
          ),
          body: const Text('teste'),
          floatingActionButton: buildAddOfferButton(context)));
}

Widget buildAddOfferButton(BuildContext context) => FloatingActionButton(
    backgroundColor: const Color.fromARGB(166, 66, 66, 66),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyApp()),
      );
    },
    child: const Icon(Icons.arrow_back));
