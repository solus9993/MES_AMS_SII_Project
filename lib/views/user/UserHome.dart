import 'package:TrackerApp/models/User.dart';
import 'package:TrackerApp/providers/LocationProvider.dart';
import 'package:TrackerApp/providers/UserProvider.dart';
import 'package:TrackerApp/utils/commons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserHome extends StatefulWidget {
  @override
  _UserHomeState createState() => new _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  SharedPreferences sharedPreferences;
  LocationProvider locationProvider;
  User user;

  @override
  void initState() {
    super.initState();
  }

/**
 * Turns on/off the location listener and updates user preferences
 */
  _sharelocationButton() async {
    sharedPreferences = await SharedPreferences.getInstance();
    user.shareLocation = user.shareLocation ? false : true;
    user.save();
    sharedPreferences.setBool("shareLocation", user.shareLocation);
    user.shareLocation
        ? Provider.of<LocationProvider>(context, listen: false).listenLocation()
        : Provider.of<LocationProvider>(context, listen: false).stopListen();
    setState(() {});
  }

/**
 * updades user preference regarding map visibility
 */
  _mapVisibleButton() async {
    sharedPreferences = await SharedPreferences.getInstance();
    user.mapVisible = user.mapVisible ? false : true;
    user.save();
    sharedPreferences.setBool("mapVisible", user.mapVisible);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UserProvider>(builder: (context, data, child) {
        if (data != null) {
          // gets login user instance from UserPovider
          user = data.me;
          return Container(
              padding:
                  EdgeInsets.only(bottom: 20, top: 40, left: 40, right: 40),
              alignment: Alignment.center,
              child: ListView(children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    user.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  alignment: Alignment.center,
                ),
                Divider(
                  color: Commons.colorTheme,
                ),
                //shareLocation Button
                Commons.button(
                    'Share Location: ' + (user.shareLocation ? 'On' : 'Off'),
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor,
                    Commons.colorBodyBackgroud,
                    onPressed: _sharelocationButton,
                    icon: Icon(
                      user.shareLocation
                          ? Icons.location_on
                          : Icons.location_off,
                      color: Commons.colorBodyBackgroud,
                    )),
                Divider(
                  color: Commons.colorTheme,
                ),
                // Last saved location information
                Column(children: <Widget>[
                  Text(
                    'Last shared Location:',
                    style: Commons.textStylePrimary,
                  ),
                  (user.location != null)
                      ? Column(children: <Widget>[
                          Commons.row2Text(
                              'Time: ',
                              Commons.printDate(
                                  DateTime.tryParse(user.location['time']))),
                          Commons.row2Text('Latitude: ',
                              user.location['latitude'].toString()),
                          Commons.row2Text('Longitude: ',
                              user.location['longitude'].toString()),
                        ])
                      : Text('Unknown'),
                ]),
                Divider(
                  color: Commons.colorTheme,
                ),
                // map visibility button
                Commons.button(
                    'Visible on Map: ' + (user.mapVisible ? 'On' : 'Off'),
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor,
                    Commons.colorBodyBackgroud,
                    onPressed: _mapVisibleButton,
                    icon: Icon(
                      user.mapVisible ? Icons.visibility : Icons.visibility_off,
                      color: Commons.colorBodyBackgroud,
                    )),
                Divider(
                  color: Commons.colorTheme,
                ),
              ]));
        } else
          return Container();
      }),
    );
  }
}
