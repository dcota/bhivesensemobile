// ignore_for_file: unnecessary_const, avoid_print, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'home.dart';
import 'menu.dart';

class Report extends StatefulWidget {
  const Report({super.key});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  bool showProgress = false;
  final userdata = GetStorage();
  static const c = Color(0xffebc002);
  var _message;
  var _subject;

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

  Future submitMessage() async {
    var url = 'https://bhsapi.duartecota.com/report';
    final body = {
      'user': userdata.read('_id'),
      'name': userdata.read('name'),
      'email': userdata.read('email'),
      'subject': _subject,
      'message': _message,
    };
    print(body);
    dynamic response;
    try {
      response = await http
          .post(Uri.parse(url), body: body)
          .timeout(const Duration(seconds: 7));
      Map b = await jsonDecode(response.body);
      print(b);
      if (b['http'] == 201) {
        await showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Your message was submited successfuly!'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => Menu(),
                  ));
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        toggleSubmitState();
        await showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Server problem. Try again later.'),
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
    } catch (e) {
      print('erro');
      /*toggleSubmitState();
      await showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Error'),
          content: Text(response == null
              ? 'Error establishing connection!'
              : 'An error occurred!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                toggleSubmitState();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );*/
    }
  }

  @override
  void initState() {
    toggleSubmitState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () => _onWillPop(context),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: c,
          body: SingleChildScrollView(
              child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: <Widget>[
              const Padding(padding: EdgeInsets.only(bottom: 10)),
              const Text(
                'Report your problem',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(166, 66, 66, 66),
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 20)),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    //labelText: 'Name',
                    hintText: userdata.read('name'),
                    filled: true,
                    fillColor: Colors.white),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 20)),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    //labelText: 'Name',
                    hintText: userdata.read('email'),
                    filled: true,
                    fillColor: Colors.white),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 20)),
              TextFormField(
                decoration: const InputDecoration(
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    //labelText: 'Name',
                    hintText: 'Type your subject',
                    filled: true,
                    fillColor: Colors.white),
                onChanged: (value) => _subject = value,
              ),
              const Padding(padding: EdgeInsets.only(bottom: 20)),
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    //labelText: 'Name',
                    hintText: 'Type your message',
                    filled: true,
                    fillColor: Colors.white),
                onChanged: (value) => _message = value,
              ),
              const Padding(padding: EdgeInsets.only(bottom: 20)),
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.grey),
                  ),
                  child: !showProgress
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        )
                      : const Text(
                          'Submit',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                  onPressed: () async {
                    if (_message == null || _subject == null) {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          //title: const Text('Error'),
                          content: const Text('Please enter your message'),
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
                    } else {
                      toggleSubmitState();
                      submitMessage();
                    }
                  }),
            ]),
          )),
        ),
      );
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
