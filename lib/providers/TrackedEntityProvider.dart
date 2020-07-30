import 'package:TrackerApp/models/TrackedEntity.dart';
import 'package:TrackerApp/utils/commons.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';

class TrackedEntityProvider extends ChangeNotifier {
  List<TrackedEntity> trackedEntityList;
  TrackedEntity trackedEntity;
  var _jsonParams = {"_id": "5eeb9f41ba91884878ebaaa4"};
  // ignore: missing_return
  Future<List<TrackedEntity>> fetch([jsonParams]) async {
    print("****************fetchTrackedEntity " +
        (new DateTime.now()).toString());
    // jsonParams = jsonParams ?? {};
    var url;
    if (jsonParams != null) {
      url = new Uri.http(Commons.baseURL, "/trackedentity/filter", jsonParams);
    } else {
      url = new Uri.http(Commons.baseURL, "/trackedentity/filter");
    }
    print(url);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        var responseJson = Commons.returnResponse(response);
        // print({'responseJson': responseJson});
        trackedEntityList = (responseJson as List)
            .map((data) => TrackedEntity.fromJson(data))
            .toList();
        // trackedEntity = TrackedEntity.fromJson(responseJson);
        return trackedEntityList;
      } else {
        print(response.statusCode);
        return null;
      }
    } on SocketException {
      print("SocketException");
      return null;
    }
  }

  void notify(){
    notifyListeners();
  }
}
