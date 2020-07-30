import 'package:TrackerApp/models/Zone.dart';
import 'package:TrackerApp/utils/commons.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class ZoneProvider extends ChangeNotifier {
  List<Zone> list;
  Zone zone;

  /**
   * gets zones 
   */
  Future<List<Zone>> fetch([jsonParams]) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    print("****************fetch " + (new DateTime.now()).toString());
    String route = '/zone';
    var url;
    if (jsonParams != null) {
      url = new Uri.http(Commons.baseURL, route + "/filter", jsonParams);
    } else {
      url = new Uri.http(Commons.baseURL, route);
    }
    print(url);
    try {
      final response = await http.get(url, headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader:
            'Token ' + sharedPreferences.get('token')
      });
      if (response.statusCode == 200) {
        var responseJson = Commons.returnResponse(response);
        list =
            (responseJson as List).map((data) => Zone.fromJson(data)).toList();
        print({'list': list});
        return list;
      } else {
        print(response.statusCode);
        return null;
      }
    } on SocketException {
      print("SocketException");
      return null;
    }
  }

// deletes zone
  Future<void> deleteItem(Zone item) async {
    await item.delete();
    notifyListeners();
  }

// creates a zone
  Future<String> createItem(Zone item) async {
    String res;
    res = await item.create();
    if (res == null) notifyListeners();
    return res;
  }

  Future<void> notify() async {
    notifyListeners();
  }

  List<dynamic> getList() {
    return this.list;
  }
}
