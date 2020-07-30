import 'package:TrackerApp/models/TrackedEntity.dart';
import 'package:TrackerApp/providers/TrackedEntityProvider.dart';
import 'package:TrackerApp/utils/commons.dart';
import 'package:TrackerApp/utils/error.dart';
import 'package:TrackerApp/views/locate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InitializeTrackedEntityProviderData extends StatefulWidget {
  InitializeProvidersState createState() => InitializeProvidersState();
}

class InitializeProvidersState extends State<InitializeTrackedEntityProviderData> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _loadTrackedEntity());
  }

  Widget _loadTrackedEntity() {
    return FutureBuilder<List<TrackedEntity>>(
      future: Provider.of<TrackedEntityProvider>(context).fetch(),
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
            // return Commons.loading("Fetching...");
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Error(
                errorMessage: "Error retrieving data.",
              );
            } else {
              return Locate();
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
