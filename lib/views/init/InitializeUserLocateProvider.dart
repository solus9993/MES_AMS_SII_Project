import 'package:TrackerApp/models/User.dart';
import 'package:TrackerApp/models/Zone.dart';
import 'package:TrackerApp/providers/UserLocateProvider.dart';
import 'package:TrackerApp/providers/ZoneProvider.dart';
import 'package:TrackerApp/utils/commons.dart';
import 'package:TrackerApp/views/user/UserLocate.dart';
import 'package:TrackerApp/utils/error.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InitializeUserLocateProvider extends StatefulWidget {
  InitializeUserProvidersState createState() => InitializeUserProvidersState();
}

class InitializeUserProvidersState extends State<InitializeUserLocateProvider> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _load());
  }

  Widget _load() {
    return FutureBuilder<List<User>>(
      future: Provider.of<UserLocateProvider>(context).fetch(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text(
              'Fetch opportunity data',
              textAlign: TextAlign.center,
            );
          case ConnectionState.active:
            return Text('');
          case ConnectionState.waiting:
            return Commons.loading("Fetching...");
          case ConnectionState.done:
            print(snapshot);
            if (snapshot.hasError || snapshot.data == null) {
              return Error(
                errorMessage: "Error retrieving data.",
              );
            } else {
              return FutureBuilder<List<Zone>>(
                future: Provider.of<ZoneProvider>(context).fetch(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return Text(
                        'Fetch opportunity data',
                        textAlign: TextAlign.center,
                      );
                    case ConnectionState.active:
                      return Text('');
                    case ConnectionState.waiting:
                      return Commons.loading("Fetching...");
                    case ConnectionState.done:
                      print(snapshot);
                      if (snapshot.hasError || snapshot.data == null) {
                        return Error(
                          errorMessage: "Error retrieving data.",
                        );
                      } else {
                        return UserLocate();
                      }
                  }
                  return Commons.loading("Fetching...");
                },
              );
            }
        }
        return Commons.loading("Fetching...");
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
