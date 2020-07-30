import 'package:TrackerApp/models/Zone.dart';
import 'package:TrackerApp/providers/ZoneProvider.dart';
import 'package:TrackerApp/views/init/InitializeZoneListProviderData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomSearchBar extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.length < 3) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              "Search term must be longer than two letters.",
            ),
          )
        ],
      );
    }
    return 
        ChangeNotifierProvider(
          create: (context) => ZoneProvider(),
          child: InitializeZoneListProviderData(filters:{'name': query}));
      
    
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Column();
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = Theme.of(context);
    assert(theme != null);
    return theme.copyWith(
      primaryTextTheme: theme.textTheme,
    );
  }
}
