import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:TrackerApp/utils/commons.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  String id;
  String name;
  String email;
  String password;
  var roles;
  bool shareLocation = false;
  bool mapVisible = false;
  Map<String, dynamic> location;
  User(
      {this.id,
      this.name,
      this.email,
      this.roles,
      this.mapVisible,
      this.shareLocation,
      this.location});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'roles': roles,
      'mapVisible': mapVisible,
      'shareLocation': shareLocation,
      'location': location
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> location;
    if (json.containsKey('location') &&
        json['location'].containsKey('time') &&
        json['location'].containsKey('latitude') &&
        json['location'].containsKey('longitude')) {
      location = {
        'time': json['location']['time'],
        'latitude': json['location']['latitude'],
        'longitude': json['location']['longitude'],
      };
    }
    return User(
      id: json['_id'] ?? null,
      name: json['name'] ?? null,
      email: json['email'] ?? null,
      roles: json['roles'] ?? null,
      mapVisible: json['mapVisible'] ?? false,
      shareLocation: json['shareLocation'] ?? false,
      location: location ?? null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.id != null) data['_id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['password'] = this.password;
    if (this.roles != null) data['roles'] = this.roles;
    if (this.mapVisible != null) data['mapVisible'] = this.mapVisible;
    if (this.shareLocation != null) data['shareLocation'] = this.shareLocation;
    if (this.location != null) data['location'] = this.location;
    return data;
  }

/**
 * set usre locations with time
 */
  void setLocation(LocationData location) {
    this.location = {
      'latitude': location.latitude,
      'longitude': location.longitude,
      'time': DateTime.fromMillisecondsSinceEpoch(location.time.truncate())
          .toString(),
    };
  }

/**
 * requests the creation of a new user in db
 */
  Future<String> register() async {
    print("****************register ");
    var url;
    var body;

    body = json.encode(this.toJson());
    url = new Uri.http(Commons.baseURL, "/user");

    print(url);
    try {
      final response = await http.post(url,
          headers: {"Content-Type": "application/json"}, body: body);
      if (response.statusCode == 200) {
        Commons.log('code:200***********');
        return null;
      } else {
        Commons.log('code:*********** ');
        Commons.log(response.statusCode);
        Commons.log(response.body);
        return response.body;
      }
    } on SocketException {
      Commons.log('*********** ');
      print("SocketException");
      return 'SocketException';
    }
  }

/**
 * requests authentication for the user 
 */
  login() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    print("****************login ");
    var url;
    var body;

    body = json.encode(this.toJson());
    url = new Uri.http(Commons.baseURL, "/user/signin");

    print(url);
    try {
      final response = await http
          .post(url, headers: {"Content-Type": "application/json"}, body: body)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        Commons.log('code:200***********');

        var responseJson = Commons.returnResponse(response);
        print(responseJson);
        sharedPreferences.setString("token", responseJson['token']);
        sharedPreferences.setString("id", responseJson['_id']);
        sharedPreferences.setString("name", responseJson['name']);
        sharedPreferences.setString("email", responseJson['email']);
        sharedPreferences.setBool("mapVisible", responseJson['mapVisible']);
        sharedPreferences.setBool(
            "shareLocation", responseJson['shareLocation']);
        return null;
      } else {
        Commons.log('code:*********** ');
        Commons.log(response.statusCode);
        Commons.log(response.body);
        return response.body;
      }
    } on TimeoutException catch (_) {
      print('timeout');
      return 'Server timeout.';
    } on SocketException {
      Commons.log('*********** ');
      print("SocketException");
      return 'SocketException';
    }
  }

/**
 * requests to update a user information in db
 */
  save() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    print("****************save ");
    var url;
    var body;

    body = json.encode(this.toJson());
    url = new Uri.http(Commons.baseURL, "/user");

    print(body);
    try {
      final response = await http
          .put(url,
              headers: {
                "Content-Type": "application/json",
                HttpHeaders.authorizationHeader:
                    'Token ' + sharedPreferences.get('token')
              },
              body: body)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        Commons.log('code:200*****saved');
        var responseJson = Commons.returnResponse(response);
        // Commons.log(responseJson);
        return null;
      } else {
        Commons.log('code:*********** ');
        Commons.log(response.statusCode);
        Commons.log(response.body);
        return response.body;
      }
    } on TimeoutException catch (_) {
      print('timeout');
      return 'Server timeout.';
    } on SocketException {
      Commons.log('*********** ');
      print("SocketException");
      return 'SocketException';
    }
  }
}
