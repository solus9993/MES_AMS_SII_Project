import 'package:TrackerApp/providers/ZoneProvider.dart';
import 'package:TrackerApp/utils/commons.dart';
import 'package:TrackerApp/utils/CustomSearchBar.dart';
import 'package:TrackerApp/views/init/InitializeZoneListProviderData.dart';
import 'package:TrackerApp/views/zone/ZoneCreate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/**
 * Displays Zone page.
 * search with db requests
 * Can also create, edit and delete zones
 */
class ZonePage extends StatefulWidget {
  ZonePage({Key key}) : super(key: key);

  @override
  _ZoneListState createState() => _ZoneListState();
}

class _ZoneListState extends State<ZonePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zone List'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchBar(),
              );
            },
          )
        ],
      ),
      body: ChangeNotifierProvider(
          create: (context) => ZoneProvider(),
          child: InitializeZoneListProviderData()),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ZoneCreate(),
            ),
          );
          if(created!=null && created)
          setState(() {
            
          });
        },
        child: Icon(Icons.add),
        backgroundColor: Commons.colorTheme,
      ),
    );
  }
}
