import 'dart:async';
import 'dart:collection';

import 'package:TrackerApp/providers/TrackedEntityProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:TrackerApp/models/TrackedEntity.dart';
import 'package:provider/provider.dart';

class Locate extends StatefulWidget {
  Locate({Key key}) : super(key: key);

  @override
  _LocateState createState() => _LocateState();
}

class _LocateState extends State<Locate> {
  Completer<GoogleMapController> _controller = Completer();
  bool _showMapStyle = false;
  IconData themeMode = Icons.brightness_low;
  TrackedEntity trackedEntity2;
  TrackedEntityProvider trackedEntityProvider;
  
  @override
  void initState() {
    _toggleMapStyle();
    super.initState();
  }

  void _toggleMapStyle() async {
    final GoogleMapController controller = await _controller.future;
    String style = await DefaultAssetBundle.of(context)
        .loadString('assets/map_style.json');
    _showMapStyle = !_showMapStyle;
    if (_showMapStyle) {
      controller.setMapStyle(style);
      setState(() {
        themeMode = Icons.brightness_low;
      });
    } else {
      controller.setMapStyle(null);
      setState(() {
        themeMode = Icons.brightness_high;
      });
    }
  }

_refresh(){
  Provider.of<TrackedEntityProvider>(context, listen: false).notify();
}
  static final CameraPosition _kGoogleSetubal = CameraPosition(
    target: LatLng(38.5284431, -8.8894514),
    zoom: 15,
  );

  static final CameraPosition _kIPS =
      CameraPosition(target: LatLng(38.5219167, -8.8383817), zoom: 17);

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  static final CameraPosition _kGoogleInitialCamera = _kIPS;

  @override
  Widget build(BuildContext context) {
    print("====== _GMapState-build ======");
    return Scaffold(
      appBar: AppBar(title: Text('Map'), actions: <Widget>[
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () => _refresh(),
        ),
        IconButton(
          icon: Icon(themeMode),
          onPressed: () => _toggleMapStyle(),
        ),
      ]),
      body: Stack(
        children: <Widget>[
          Consumer<TrackedEntityProvider>(builder: (context, data, child) {
            return GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: _kGoogleInitialCamera,
              markers: _getMarkers(data),
            );
          }),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToIPS,
        label: Text('To IPS'),
        icon: Icon(Icons.school),
      ),
    );
  }

  Future<void> _goToIPS() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kIPS));
  }

  Set<Marker> _getMarkers(data) {
    Set<Marker> markers = HashSet<Marker>();
    List<TrackedEntity> trackedEntityList = data.trackedEntityList;
    if (trackedEntityList != null) {
      for (var trackedEntity in trackedEntityList) {
        markers.add(
          Marker(
            markerId: MarkerId(trackedEntity.id),
            position: LatLng(trackedEntity.lat, trackedEntity.lon),
            infoWindow: InfoWindow(
              title: trackedEntity.name,
              snippet: trackedEntity.name,
            ),
          ),
        );
      }
    }
    return markers;
  }
}
