// ignore_for_file: file_names

import 'dart:convert';

Hive hiveFromJson(String str) => Hive.fromJson(json.decode(str));

String hiveToJson(Hive data) => json.encode(data.toJson());

class Hive {
  String id;
  double? lat;
  double? lon;
  bool state;

  Hive({
    required this.id,
    required this.lat,
    required this.lon,
    required this.state,
  });

  factory Hive.fromJson(Map<String, dynamic> json) => Hive(
        id: json['_id'],
        lat: json['lat'],
        lon: json['lon'],
        state: json['state'],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "lat": lat,
        "lon": lon,
        "state": state,
      };
}
