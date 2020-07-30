import 'dart:convert';

import 'package:TrackerApp/models/User.dart';
import 'package:TrackerApp/utils/commons.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class UserLocateProvider extends ChangeNotifier {
  List<User> list;
  User me;

/**
 * Returns a list with users
 */
  Future<List<User>> fetch([jsonParams]) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    print("****************fetch " + (new DateTime.now()).toString());
    String route = '/user';
    var url = new Uri.http(Commons.baseURL, route + "/filter", jsonParams);
    print(url);
    try {
      final response = await http.get(url,headers: {
                "Content-Type": "application/json",
                HttpHeaders.authorizationHeader:
                    'Token ' + sharedPreferences.get('token')
              });
      if (response.statusCode == 200) {
        var responseJson = Commons.returnResponse(response);
        list =
            (responseJson as List).map((data) => User.fromJson(data)).toList();
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

  Future<User> getUserDetails() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Commons.log("*******getUserDetails ");
    if (sharedPreferences.containsKey('name')) {
      var url;
      url = new Uri.http(Commons.baseURL, "/user/filter",
          {'name': sharedPreferences.get('name')});

      Commons.log(url);
      try {
        final response = await http.get(url, headers: {
          "Content-Type": "application/json",
          HttpHeaders.authorizationHeader:
              'Token ' + sharedPreferences.get('token')
        }).timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          Commons.log('code:200***********');
          var responseJson = Commons.returnResponse(response)[0];
          // print(responseJson);
          me = User.fromJson(responseJson);
          Commons.log(me);
          // notifyListeners();
          return User.fromJson(responseJson);
        } else {
          Commons.log('code:*********** ');
          Commons.log(response.statusCode);
          Commons.log(response.body);
          return null;
        }
      } on TimeoutException catch (_) {
        print('timeout');
      } on SocketException {
        Commons.log('*********** ');
        print("SocketException");
        return null;
      }
    }
    return null;
  }

  void notify() {
    notifyListeners();
  }
}
