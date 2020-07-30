import 'dart:convert';

import 'package:TrackerApp/networking/AppException.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Commons {
  //global Flags
  static const port = 3000;
  static const baseURL = "tracker-app-api.herokuapp.com";
  // static const baseURL = "testcenas.ddns.net:$port";
  // static const baseURL = "10.0.2.2:$port";
  static const userAsTrackedEntity = true;
  static final logs = true;
  static final showAppBarUserLogin = false;

//colors
  static final colorBodyBackgroud = Colors.grey[200];
  static final colorThemeFont = colorBodyBackgroud;
  static final colorTheme = Colors.brown;
  static final colorSelectedItemNavigation = Colors.amber;
  static final colorPolygonAddZone = Colors.blue.withOpacity(0.2);
  static final colorPolygonStrokeAddZone = Colors.blue;
  static final strokeWidthPolygonAddZone = 3;
  static final colorPolyLinesAddZone = Colors.blue[200];
  static final strokeWidthPolyLinesAddZone = 3;
  static final colorMarkersAddZone = Colors.blue;
  static final colorErrorMsg = Colors.red;

  //textStyles
  static final textStylePrimary =
      TextStyle(color: colorTheme, fontSize: 20, fontWeight: FontWeight.bold);
  static final textStylePrimarySmall =
      TextStyle(color: colorTheme, fontSize: 16, fontWeight: FontWeight.bold);

  // formats
  static String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
  static final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  static String printDate(DateTime date) => formatter.format(date);

  static Widget loader() {
    return Center(child: SpinKitFoldingCube(
      itemBuilder: (BuildContext context, int index) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: index.isEven ? colorSelectedItemNavigation : colorTheme,
          ),
        );
      },
    ));
  }

  static Widget loading(String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.all(18),
            child: Text(
              message,
              style: TextStyle(
                  color: colorTheme, fontSize: 20, fontWeight: FontWeight.bold),
            )),
        loader(),
      ],
    );
  }

  static void confirmationDialog(
      BuildContext context, String title, Widget message, String buttonText,
      {action, params}) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text(title),
              titleTextStyle: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [Divider(), message, Divider()]),
              backgroundColor: colorBodyBackgroud,
              actions: <Widget>[
                Divider(),
                RaisedButton(
                  color: colorTheme,
                  child: Text(
                    buttonText,
                    style: TextStyle(
                        color: colorSelectedItemNavigation,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    await action(params);
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text("cancel"),
                ),
              ],
            ));
  }

  static void showError(BuildContext context, String title, json, color) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text(title),
              titleTextStyle: TextStyle(
                color: colorTheme,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              content: showMsgWidget(json, color),
              backgroundColor: colorBodyBackgroud,
              actions: <Widget>[
                FlatButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  static Widget showMsgWidget(json, color) {
    List<Widget> msgs = <Widget>[];

    if (json is String && !json.startsWith('{')) {
      msgs.add(Text(json, style: TextStyle(color: color)));
      msgs.add(SizedBox(height: 10));
    } else {
      var mapJson = (jsonDecode(json.toString()) as Map<String, dynamic>);
      print(mapJson.keys);
      String key = '';
      if (mapJson.length == 1 && mapJson.keys.contains("errors")) {
        key = 'errors';
        for (var item in mapJson[key]) {
          print(item);
          msgs.add(Text(item['msg'], style: TextStyle(color: color)));
          msgs.add(SizedBox(height: 10));
        }
      }
      if (mapJson.keys.contains("message")) {
        key = 'message';
        if (mapJson.length == 3 && mapJson.keys.contains("errors")) {
          key = 'errors';
          for (var item in mapJson[key].values) {
            print(item);
            msgs.add(Text((item['properties']['path'] + ':').toUpperCase(),
                style: TextStyle(color: color)));
            msgs.add(Text(item['properties']['message'],
                style: TextStyle(color: color)));
            msgs.add(SizedBox(height: 10));
          }
        } else {
          msgs.add(Text(mapJson[key], style: TextStyle(color: color)));
          msgs.add(SizedBox(height: 10));
        }
      }
    }

    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: msgs);
  }

  static dynamic returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = jsonDecode(response.body.toString());
        log({'returnResponse':responseJson});
        return responseJson;
      case 400:
      case 500:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());

      default:
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }

  static log(message) {
    if (logs) {
      print(message);
    }
  }

  static Widget input(
      Icon icon, String hint, TextEditingController controller, bool obsecure) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: TextField(
        controller: controller,
        obscureText: obsecure,
        style: TextStyle(
          fontSize: 20,
        ),
        decoration: InputDecoration(
            hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            hintText: hint,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: Commons.colorTheme,
                width: 2,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: Commons.colorTheme,
                width: 3,
              ),
            ),
            prefixIcon: Padding(
              child: IconTheme(
                data: IconThemeData(color: Commons.colorTheme),
                child: icon,
              ),
              padding: EdgeInsets.only(left: 30, right: 10),
            )),
      ),
    );
  }

  //button widget
  static Widget button(String text, Color splashColor, Color highlightColor,
      Color fillColor, Color textColor,
      {onPressed, fParams, icon}) {
    return RaisedButton(
      highlightElevation: 0.0,
      splashColor: splashColor,
      highlightColor: highlightColor,
      elevation: 0.0,
      color: fillColor,
      shape:
          RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        icon != null ? icon : SizedBox(),
        icon != null ? SizedBox(width: 5,) : SizedBox(),
        Text(
          text,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: textColor, fontSize: 20),
        )
      ]),
      onPressed: () async => onPressed != null
          ? fParams != null ? onPressed(fParams) : onPressed()
          : () => {},
    );
  }

  static Widget row2Text(text1Index, text2Value) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(
        text1Index,
        style: Commons.textStylePrimarySmall,
      ),
      Text(text2Value)
    ]);
  }
}
