import 'dart:convert';

import 'package:flutter/services.dart';
import '../models/home_object.dart';

class JsonParser{
  Future<List<HomeObject>> loadMovies() async {
    final jsonString = await rootBundle.loadString('assets/data.json');
    final List<dynamic> jsonList = json.decode(jsonString);

    return jsonList.map((e) => HomeObject.fromJson(e)).toList();
  }
}