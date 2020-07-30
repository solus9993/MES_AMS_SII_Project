import 'dart:async';

import 'package:TrackerApp/models/User.dart';
import 'package:TrackerApp/providers/LocationProvider.dart';
import 'package:TrackerApp/providers/UserLocateProvider.dart';
import 'package:TrackerApp/providers/UserProvider.dart';
import 'package:TrackerApp/utils/commons.dart';
import 'package:TrackerApp/providers/ZoneProvider.dart';
import 'package:TrackerApp/views/user/UserHome.dart';
import 'package:TrackerApp/views/user/UserLogin.dart';
import 'package:TrackerApp/views/init/InitializeTrackedEntityProviderData.dart';
import 'package:TrackerApp/views/init/InitializeUserLocateProvider.dart';
import 'package:TrackerApp/providers/TrackedEntityProvider.dart';
import 'package:TrackerApp/views/zone/ZonePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SharedPreferences sharedPreferences;
  bool _signin = true;
  LocationData location;
  LocationProvider locationProvider;
  User user;
  Timer autoSaveLocationTimer;

  /**
   * check if a user is logedd in,
   * if not redirects to the login page
   */
  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    _signin = true;
    if (sharedPreferences.getString("token") == null) {
      _signin = false;
      Provider.of<LocationProvider>(context, listen: false).stopListen();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => UserLogin()),
          (Route<dynamic> route) => false);
    }
  }

  int _selectedIndex = 0;
  bool _mainAppBarVisible = true;
  /**
   * changes the selected tab index
   */
  void _onItemTapped(int index) {
    _mainAppBarVisible = index == 0 ? true : false;
    setState(() {
      _selectedIndex = index;
    });
  }

/**
 * timer to auto save the user location,
 * when the user has shareLocation on
 */
  startAutoSaveLocation() async {
    sharedPreferences = await SharedPreferences.getInstance();
    //runs every 5sec
    autoSaveLocationTimer = Timer.periodic(new Duration(seconds: 5), (timer) {
      if (!sharedPreferences.containsKey("shareLocation")) {
        timer.cancel();
      } else if (sharedPreferences.getBool("shareLocation")) {
        Commons.log('save LocationData');
        if (context != null) {
          // gets the last location
          location = Provider.of<LocationProvider>(context, listen: false)
              .getLastLocation();
          // gets the logged user
          user = Provider.of<UserProvider>(context, listen: false).me;
          // save locationt to user instance
          user.setLocation(location);
          // saves user
          user.save();
        }
      }
    });
  }

  @override
  void initState() {
    checkLoginStatus();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Commons.log('didChangeDependencies');
    startAutoSaveLocation();
  }

  @override
  Widget build(BuildContext context) {
    print('_signin:' + _signin.toString());
    return Scaffold(
      backgroundColor: Commons.colorBodyBackgroud,
      appBar: _mainAppBarVisible
          ? AppBar(
              title: Row(children: [
                Icon(Icons.home),
                SizedBox(
                  width: 5,
                ),
                Text(widget.title ?? 'TrackerApp')
              ]),
              actions: !_signin
                  ? null
                  : <Widget>[
                      FlatButton(
                        onPressed: () {
                          sharedPreferences.clear();
                          setState(() {
                            checkLoginStatus();
                          });
                        },
                        child: Text("Log Out",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
            )
          : null,
      body: <Widget>[
        //1: user home tab page
        UserHome(),
        //2: Locate tab page
        Commons.userAsTrackedEntity
            ? MultiProvider(
                providers: [
                  ChangeNotifierProvider(
                    create: (context) => UserLocateProvider(),
                  ),
                  ChangeNotifierProvider(
                    create: (context) => ZoneProvider(),
                  )
                ],
                child: InitializeUserLocateProvider(),
              )
            : ChangeNotifierProvider(
                create: (context) => TrackedEntityProvider(),
                child: InitializeTrackedEntityProviderData()),
        //3: zone tab page
        ZonePage(),
      ].elementAt(_selectedIndex),
      bottomNavigationBar: _signin
          ? BottomNavigationBar(
              backgroundColor: Commons.colorTheme,
              unselectedItemColor: Commons.colorThemeFont,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  title: Text('Home'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  title: Text('Locate'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.map),
                  title: Text('Zones'),
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Commons.colorSelectedItemNavigation,
              onTap: _onItemTapped,
            )
          : null,
    );
  }

  @override
  void dispose() {
    super.dispose();
    autoSaveLocationTimer.cancel();
  }
}
