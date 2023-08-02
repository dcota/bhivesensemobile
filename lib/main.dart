// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'app_widget.dart';
import 'package:flutter/services.dart';
//import 'services/notification_service.dart';

Future main() async {
  await GetStorage.init();
  //NotificationService().initNotification();
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(AppWidget());
}
