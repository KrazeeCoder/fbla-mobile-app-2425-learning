import 'dart:convert';
import 'package:flutter/services.dart';

Future<Map<String, dynamic>> loadJsonData() async {
  // Load the JSON file as a string
  String jsonString = await rootBundle.loadString('assets/content.json');

  // Decode the JSON string into a Map
  Map<String, dynamic> jsonData = jsonDecode(jsonString);

  return jsonData;
}

