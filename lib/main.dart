
import 'package:TrackerApp/providers/UserProvider.dart';
import 'package:TrackerApp/utils/commons.dart';
import 'package:TrackerApp/views/init/InitializeUserProviderData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrackerApp',
      theme: ThemeData(
        primarySwatch: Commons.colorTheme,
      ),
      home:   
      // call to InitializeUserProviderData
      ChangeNotifierProvider(
            create: (context) => UserProvider(),
            child: InitializeUserProviderData()),
    );
  }
}