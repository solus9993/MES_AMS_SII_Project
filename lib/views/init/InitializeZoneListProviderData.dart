import 'package:TrackerApp/models/Zone.dart';
import 'package:TrackerApp/providers/ZoneProvider.dart';
import 'package:TrackerApp/utils/commons.dart';
import 'package:TrackerApp/utils/error.dart';
import 'package:TrackerApp/views/zone/ZoneList.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InitializeZoneListProviderData extends StatefulWidget {
  final Map<String,String> filters;
  InitializeZoneListProviderData({this.filters});
  InitializeProvidersState createState() => InitializeProvidersState();
}

class InitializeProvidersState extends State<InitializeZoneListProviderData> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _load());
  }

  Widget _load() {
    return FutureBuilder<List<Zone>>(
      future: Provider.of<ZoneProvider>(context).fetch(widget.filters),
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
            if (snapshot.hasError) {
              Commons.log(snapshot);
              return Error(
                errorMessage: "Error retrieving data.",
              );
            } else {
              return ZoneList();
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
