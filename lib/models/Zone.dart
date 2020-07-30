import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:TrackerApp/models/User.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:TrackerApp/utils/commons.dart';
import 'package:shared_preferences/shared_preferences.dart';

/**
 * Defined areas by points in a map.
 * Have a Unique name and a not unique color.
 */
class Zone {
  String id;
  String owner;
  String ownerName;
  String name;
  var points = [];
  int color = 0xFF2196F3;
  int insideCount = 0;
  int insideLimit;
  User ownerUser;

  Zone(
      {this.id,
      this.owner,
      this.ownerUser,
      this.ownerName,
      this.name,
      this.points,
      this.color,
      this.insideCount,
      this.insideLimit});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'points': points,
      'owner': owner,
      'ownerUser': ownerUser,
      'insideCount': insideCount,
      'insideLimit': insideLimit,
      'color': color
    };
  }

  /// Creates a zone from json
  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['_id'] ?? null,
      owner: json['owner']['_id'] ?? null,
      ownerUser: User.fromJson(json['owner']) ?? null,
      name: json['name'] ?? null,
      points: json['points'] ?? [],
      color: json['color'] ?? 0xFF2196F3,
      insideCount: json['insideCount'] ?? 0,
      insideLimit: json['insideLimit'] ?? null,
    );
  }

  /// returns a zone object in Json like format
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    data['owner'] = this.owner;
    data['name'] = this.name;
    data['points'] = this.points;
    data['insideCount'] = this.insideCount;
    data['insideLimit'] = this.insideLimit;
    data['color'] = this.color ?? 0xFF2196F3;
    return data;
  }

  void setName(String name) {
    this.name = name.trim();
    Commons.log(this.name);
  }

  void setPoints(List<dynamic> points) {
    this.points = points;
  }

  void setColor(int color) {
    this.color = color;
  }

  void setInsideLimit(int insideLimit) {
    this.insideLimit = insideLimit;
    Commons.log(this.insideLimit);
  }

  String getId() {
    return this.id;
  }

  int getColor() {
    return this.color ?? 0xFF2196F3;
  }

  String getName() {
    return this.name;
  }

  void setPointsFromMarkers(Map<MarkerId, Marker> markers) {
    Commons.log("setZonePoints############");
    var points = [];
    markers.forEach((key, value) {
      // Commons.log(value.position.latitude);
      // Commons.log(value.position.longitude);
      points.add({
        "latitude": value.position.latitude,
        "longitude": value.position.longitude
      });
    });
    this.setPoints(points);
  }

  LatLng getCenterOfPolygon() {
    List<LatLng> polygonLatLongs = List<LatLng>();
    this.points.forEach((point) {
      // Commons.log(point);
      polygonLatLongs.add(new LatLng(point['latitude'], point['longitude']));
    });
    var centroid = {0: 0.0, 1: 0.0};
    for (int i = 0; i < polygonLatLongs.length; i++) {
      centroid[0] += polygonLatLongs.elementAt(i).latitude;
      centroid[1] += polygonLatLongs.elementAt(i).longitude;
    }
    int totalPoints = polygonLatLongs.length;
    return new LatLng(centroid[0] / totalPoints, centroid[1] / totalPoints);
  }

  String check() {
    //check the name
    if (this.name == null || this.name.trim() == '') {
      Commons.log('Name is empty.');
      return 'Name is empty.';
    }
    //checks the if point make a polygon
    else if (this.points == null || this.points.length < 3) {
      Commons.log('Need at least 3 points.');
      return 'Need at least 3 points.';
    } else if (this.insideLimit == null || !(this.insideLimit is int)) {
      Commons.log('Limit inside is not int');
      return 'Limit inside must be integer';
    }
    return null;
  }

/**
 * Makes a HTTP POST resquest to the RESTAPI to create Zone object
 */
  Future<String> create() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    print("****************addZone ");
    var url;
    var body;
    var check;
    check = this.check();
    if (check != null) {
      return check;
    }
    // Sends the request
    else {
      this.owner = sharedPreferences.getString('id');
      body = json.encode(this.toJson());
      url = new Uri.http(Commons.baseURL, "/zone");
      print(url);
      try {
        final response = await http.post(url,
            headers: {
              "Content-Type": "application/json",
              HttpHeaders.authorizationHeader:
                  'Token ' + sharedPreferences.get('token')
            },
            body: body);
        //request ok
        if (response.statusCode == 200) {
          Commons.log('code:200***********');
          return null;
          //request server error
        } else {
          Commons.log('code:*********** ');
          Commons.log(response.statusCode);
          Commons.log(response.body);
          return 'Server Error';
        }
      } on SocketException {
        Commons.log('*********** ');
        print("SocketException");
        return 'SocketException';
      }
    }
  }

/**
 * Makes a HTTP PUT resquest to the RESTAPI to update Zone object
 */
  Future<String> update() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    print("****************addZone ");
    var url;
    var body;
    var check;
    check = this.check();
    if (check != null) {
      return check;
    } else {
      body = json.encode(this.toJson());
      url = new Uri.http(Commons.baseURL, "/zone");
      print(url);
      try {
        final response = await http.put(url,
            headers: {
              "Content-Type": "application/json",
              HttpHeaders.authorizationHeader:
                  'Token ' + sharedPreferences.get('token')
            },
            body: body);
        if (response.statusCode == 200) {
          Commons.log('code:200***********');
          return null;
        } else {
          Commons.log('code:*********** ');
          Commons.log(response.statusCode);
          Commons.log(response.body);
          return 'Server Error';
        }
      } on SocketException {
        Commons.log('*********** ');
        print("SocketException");
        return 'SocketException';
      }
    }
  }

/**
 * Makes a HTTP DELETE resquest to the RESTAPI to DELETE Zone object
 */
  Future<String> delete() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    print("****************delete Zone ");
    var url;

    url = new Uri.http(Commons.baseURL, "/zone/" + this.id);

    print(url);
    try {
      final response = await http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          HttpHeaders.authorizationHeader:
              'Token ' + sharedPreferences.get('token'),
        },
      );
      if (response.statusCode == 200) {
        Commons.log('code:200***********');
        return null;
      } else {
        Commons.log('code:*********** ');
        Commons.log(response.statusCode);
        Commons.log(response.body);
        return 'Server Error';
      }
    } on SocketException {
      Commons.log('*********** ');
      print("SocketException");
      return 'SocketException';
    }
  }

  bool checkPoints() {
    print("checkPoints");
    int length = this.points.length;
    if (this.points == null || length < 3) return false;
    // Commons.log(this.points.getRange(0, 0+2));
    // for (var i = 0; i < length-1; i++) {
    //   for (var j = 2; j < length-1; j++) {
    //     if((i-j).abs()>1 && isIntersect([points[i], points[i+1], points[j], points[j+1]])) {
    //         Commons.log("intersect##############");
    //         return false;
    //       }
    //   }
    //   if(isIntersect([points[i], points[i+1], points[length], points[length-1]])) {
    //         Commons.log("intersect##############");
    //         return false;
    //       }
    // }
    return true;
  }

  bool onLine(var points) {
    if (points[2]['latitude'] <=
            max(points[0]['latitude'] as num, points[1]['latitude'] as num) &&
        points[2]['latitude'] <=
            min(points[0]['latitude'] as num, points[1]['latitude'] as num) &&
        (points[2]['longitude'] <=
                max(points[0]['longitude'] as num,
                    points[1]['longitude'] as num) &&
            points[2]['longitude'] <=
                min(points[0]['longitude'] as num,
                    points[1]['longitude'] as num))) return true;

    return false;
  }

  double direction(var points) {
    double val = (points[1]['longitude'] - points[0]['longitude']) *
            (points[2]['latitude'] - points[1]['latitude']) -
        (points[2]['latitude'] - points[0]['latitude']) *
            (points[2]['longitude'] - points[1]['longitude']);
    print(val);
    if (val == 0)
      return 0; //colinear
    else if (val < 0) return 2; //anti-clockwise direction
    return 1; //clockwise direction
  }

  bool isIntersect(var points) {
    Commons.log(points);
    //four direction for two lines and points of other line
    double dir1 = direction([points[0], points[1], points[2]]);
    double dir2 = direction([points[0], points[1], points[3]]);
    double dir3 = direction([points[0], points[1], points[2]]);
    double dir4 = direction([points[0], points[1], points[3]]);

    if (dir1 != dir2 && dir3 != dir4) return true; //they are intersecting

    // if (dir1 == 0 && onLine([points[0], points[1], points[2]])) //when p2 of line2 are on the line1
    //   return true;

    // if (dir2 == 0 && onLine([points[0], points[1], points[3]])) //when p1 of line2 are on the line1
    //   return true;

    // if (dir3 == 0 && onLine([points[0], points[1], points[2]])) //when p2 of line1 are on the line2
    //   return true;

    // if (dir4 == 0 && onLine([points[0], points[1], points[3]])) //when p1 of line1 are on the line2
    //   return true;

    return false;
  }
}
