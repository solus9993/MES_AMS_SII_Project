import 'package:TrackerApp/models/User.dart';
import 'package:TrackerApp/providers/LocationProvider.dart';
import 'package:TrackerApp/providers/UserProvider.dart';
import 'package:TrackerApp/utils/commons.dart';
import 'package:TrackerApp/views/init/InitializeLocationProvider.dart';
import 'package:TrackerApp/views/user/UserLogin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InitializeUserProviderData extends StatefulWidget {
  InitializeUserProvidersState createState() => InitializeUserProvidersState();
}
/**
 * creates a provider for logged in user details
 */
class InitializeUserProvidersState extends State<InitializeUserProviderData> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _loadUser());
  }

  Widget _loadUser() {
    return FutureBuilder<User>(
      future: Provider.of<UserProvider>(context, listen: false).getUserDetails(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text(
              'Fetch data',
              textAlign: TextAlign.center,
            );
          case ConnectionState.active:
            return Text('');
          case ConnectionState.waiting:
            return Commons.loading("Fetching...");
          case ConnectionState.done:
          print(snapshot);
            // if getUserDetails fails, goes to login page
            if (snapshot.hasError || snapshot.data == null) {
              Commons.log(snapshot);
              return UserLogin();
            } 
            //else inicializes location provider
            else {
              return ChangeNotifierProvider(
            create: (context) => LocationProvider(),
            child: InitializeLocationProvider());
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
