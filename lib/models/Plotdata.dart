// ignore_for_file: file_names

import 'dart:convert';

//Point pointFromJson(String str) => Point.fromJson(json.decode(str));

//String pointToJson(Point data) => json.encode(data.toJson());

class Point {
  String x;
  double? y;

  Point({
    required this.x,
    required this.y,
  });

  /*factory Point.fromJson(Map<String, dynamic> json) => Point(
        x: json['x'],
        y: json['lat'],
        lon: json['lon'],
        state: json['state'],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "lat": lat,
        "lon": lon,
        "state": state,
      };*/
}
