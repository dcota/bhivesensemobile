// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'package:get_storage/get_storage.dart';
import 'apiaries.dart';

String? token = '';
String? type = '';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final storage = const FlutterSecureStorage();
  final userdata = GetStorage();
  static const c = Color(0xffebc002);

  Future<http.Response> signIn(String username, String password) async {
    String? deviceID;
    await OneSignal.shared.getDeviceState().then((value) => {
          deviceID = value!.userId,
        });
    var url = 'https://bhsapi.duartecota.com/auth';
    final body = {
      'username': username,
      'password': password,
      'device': deviceID
    };
    dynamic response;
    try {
      response = await http
          .post(Uri.parse(url), body: body)
          .timeout(const Duration(seconds: 7));
      Map b = await jsonDecode(response.body);
      print(deviceID);
      if (b['http'] == 200) {
        userdata.write('token', b['body']['token']);
        userdata.write('type', b['body']['type']);
        userdata.write('firstname', b['body']['firstname']);
        userdata.write('_id', b['body']['_id']);
        userdata.write('username', b['body']['username']);
        type = userdata.read('type');
        toggleSubmitState();
        /*Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const ApiaryList(),
        ));*/
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => ApiaryList(),
        ));
      } else {
        toggleSubmitState();
        await showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Invalid username or password'),
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
      toggleSubmitState();
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
      );
    }
    return response;
  }

  bool showProgress = false;

  void toggleSubmitState() {
    setState(() {
      showProgress = !showProgress;
    });
  }

  @override
  void initState() {
    toggleSubmitState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: c,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            'Login',
            style:
                TextStyle(color: Color.fromARGB(166, 66, 66, 66), fontSize: 25),
          ),
          centerTitle: true,
          elevation: 0,
          leading: InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/');
            },
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
              child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Padding(padding: EdgeInsets.all(20.0)),
                        Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: Container(
                                height: 200,
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: TextField(
                                        controller: _usernameController,
                                        decoration: const InputDecoration(
                                            hintText: 'username'),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: TextField(
                                        obscureText: true,
                                        controller: _passwordController,
                                        decoration: const InputDecoration(
                                            hintText: 'password'),
                                      ),
                                    )
                                  ],
                                ))),
                        const Padding(padding: EdgeInsets.all(20.0)),
                        ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.grey),
                            ),
                            child: !showProgress
                                ? const CircularProgressIndicator(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  )
                                : const Text(
                                    'Sign in',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                            onPressed: () async {
                              if (_usernameController.text == '' ||
                                  _passwordController.text == '') {
                                showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                    title: const Text('Error'),
                                    content: const Text(
                                        'Please enter username and password'),
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
                                signIn(_usernameController.text,
                                    _passwordController.text);
                              }
                            }),
                        const Padding(padding: EdgeInsets.all(20.0)),
                      ]))),
        ));
  }
}
