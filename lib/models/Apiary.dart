// ignore_for_file: file_names

import 'dart:convert';

Apiary apiaryFromJson(String str) => Apiary.fromJson(json.decode(str));

String apiaryToJson(Apiary data) => json.encode(data.toJson());

class Apiary {
  String id;
  String user;
  String address;
  String location;
  String observations;

  Apiary({
    required this.id,
    required this.user,
    required this.address,
    required this.location,
    required this.observations,
  });

  factory Apiary.fromJson(Map<String, dynamic> json) => Apiary(
        id: json['_id'],
        user: json['user'],
        address: json['address'],
        location: json['location'],
        observations: json['observations'],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user": user,
        "address": address,
        "location": location,
        "observations": observations
      };
}
