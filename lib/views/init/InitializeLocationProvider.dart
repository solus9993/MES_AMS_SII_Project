import 'package:TrackerApp/providers/LocationProvider.dart';
import 'package:TrackerApp/views/MyHomePage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/**
 * inicializes location provider checks and requests permissions and location service,
 * redirects to MyHomePage
 */
class InitializeLocationProvider extends StatefulWidget {
  InitializeProvidersState createState() => InitializeProvidersState();
}

class InitializeProvidersState extends State<InitializeLocationProvider> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _load());
  }

  Widget _load() {
    return FutureBuilder<void>(
      future: Provider.of<LocationProvider>(context, listen: false)
          .listenLocation(),
      builder: (context, snapshot) => MyHomePage(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
