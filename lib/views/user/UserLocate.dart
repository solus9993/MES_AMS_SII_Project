import 'dart:async';
import 'dart:collection';

import 'package:TrackerApp/models/User.dart';
import 'package:TrackerApp/models/Zone.dart';
import 'package:TrackerApp/providers/UserLocateProvider.dart';
import 'package:TrackerApp/providers/ZoneProvider.dart';
import 'package:TrackerApp/utils/commons.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:provider/provider.dart';

class UserLocate extends StatefulWidget {
  UserLocate({Key key}) : super(key: key);

  @override
  _LocateState createState() => _LocateState();
}

class _LocateState extends State<UserLocate> {
  Completer<GoogleMapController> _controller = Completer();
  bool _showMapStyle = false;
  IconData themeMode = Icons.brightness_low;
  UserLocateProvider userLocateProvider;
  ZoneProvider zoneProvider;
  Set<Polygon> _polygons = HashSet<Polygon>();

  @override
  void initState() {
    _toggleMapStyle();
    super.initState();
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    Commons.log('didChangeDependencies');
    // await Provider.of<UserLocateProvider>(context, listen: false).fetch();
    // await Provider.of<ZoneProvider>(context, listen: false).fetch();
    // setState(() {});
    _setPolygons();
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

/**
 * refresh data
 */
  _refresh() {
    Provider.of<ZoneProvider>(context, listen: false).notify();
    Provider.of<UserLocateProvider>(context, listen: false).notify();
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
          Consumer<UserLocateProvider>(builder: (context, users, child) {
            return Consumer<ZoneProvider>(builder: (context, zones, child) {
              return GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: _kGoogleInitialCamera,
                markers: _getMarkers(users.list),
                polygons: _getPolygons(),
              );
            });
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

/**
 * relocates camera
 */
  Future<void> _goToIPS() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kIPS));
  }

  Set<Marker> _getMarkers(List<User> list) {
    Set<Marker> markers = HashSet<Marker>();
    // List<User> list = data.list;
    if (list != null && list.length != 0) {
      for (var item in list) {
        markers.add(
          Marker(
            markerId: MarkerId(item.id),
            position:
                LatLng(item.location['latitude'], item.location['longitude']),
            infoWindow: InfoWindow(
              title: item.name,
              snippet:
                  Commons.printDate(DateTime.tryParse(item.location['time'])),
            ),
          ),
        );
      }
    }
    return markers;
  }

  Set<Polygon> _getPolygons() {
    return this._polygons;
  }

/**
 * sets polygons from zone points
 */
  Set<Polygon> _setPolygons(
      {List<Zone> zonesList, List<String> filterList, String pullupName}) {
    Commons.log('########_setPolygons');
    List<Zone> list = zonesList ??
        Provider.of<ZoneProvider>(context, listen: false).getList();
    _polygons.clear();
    if (list != null) {
      list.forEach((zone) {
        List<LatLng> polygonLatLongs = List<LatLng>();
        zone.points.forEach((point) {
          polygonLatLongs
              .add(new LatLng(point['latitude'], point['longitude']));
        });

        _polygons.add(
          Polygon(
              polygonId: PolygonId(zone.getName()),
              consumeTapEvents: true,
              points: polygonLatLongs,
              fillColor: Color(zone.getColor()).withOpacity(
                  selected(pullupName, zone.getName()) ? 0.5 : 0.2),
              strokeColor: Color(zone.getColor()),
              strokeWidth: Commons.strokeWidthPolygonAddZone,
              zIndex: selected(pullupName, zone.getName()) ? 4 : 0,
              onTap: () {
                print(_polygons
                    .firstWhere((element) =>
                        element.polygonId == PolygonId(zone.getName()))
                    .zIndex);
                    // redraw polygons with the tapped zone zindex bigger
                _setPolygons(zonesList: list, pullupName: zone.getName());
                setState(() {});
              }),
        );
      });
    } else {
      // _refresh();
    }
  }

  bool selected(pullupName, name) {
    return (pullupName != null && name == pullupName);
  }
}
