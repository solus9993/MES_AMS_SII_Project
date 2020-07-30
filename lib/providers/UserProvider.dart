import 'dart:convert';

import 'package:TrackerApp/models/User.dart';
import 'package:TrackerApp/utils/commons.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  List<User> list;
  User me;

/**
 * Returns a list with users
 */
  Future<List<User>> fetch([jsonParams]) async {
    print("****************fetch " + (new DateTime.now()).toString());
    // jsonParams = jsonParams ?? {};
    String route = '/user';
    var url;
    if (jsonParams != null) {
      url = new Uri.http(Commons.baseURL, route + "/filter", jsonParams);
    } else {
      url = new Uri.http(Commons.baseURL, route);
    }
    print(url);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        var responseJson = Commons.returnResponse(response);
        print({'responseJson': responseJson});
        list =
            (responseJson as List).map((data) => User.fromJson(data)).toList();
        // notifyListeners();
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

/**
 * details for the login user,
 * returns null if no user is logged in
 */
  Future<User> getUserDetails() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Commons.log("*******getUserDetails ");
    // checks if sharedPreferences is set and contains a user name
    if (sharedPreferences != null && sharedPreferences.containsKey('name')) {
      var url;
      // adds the filter for the user name
      url = new Uri.http(Commons.baseURL, "/user/filter",
          {'name': sharedPreferences.get('name')});

      Commons.log(url);
      try {
        // requests the user details
        final response = await http.get(url, headers: {
          "Content-Type": "application/json",
          HttpHeaders.authorizationHeader:
              'Token ' + sharedPreferences.get('token')
        }).timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          Commons.log('code:200***********');
          var responseJson = Commons.returnResponse(response)[0];
          me = User.fromJson(responseJson);
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
