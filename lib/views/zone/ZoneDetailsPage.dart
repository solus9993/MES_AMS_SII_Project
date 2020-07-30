import 'dart:async';
import 'dart:collection';
import 'dart:ffi';
import 'dart:ui';
import 'package:TrackerApp/models/Zone.dart';
import 'package:TrackerApp/providers/ZoneProvider.dart';
import 'package:TrackerApp/views/zone/ZoneCreate.dart';
import 'package:TrackerApp/views/zone/zoneDialog.dart';
import 'package:TrackerApp/utils/commons.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class ZoneDetailsPage extends StatefulWidget {
  ZoneDetailsPage(this.zone, {Key key}) : super(key: key);
  final Zone zone;
  @override
  _ZoneDetailsPageState createState() => _ZoneDetailsPageState(this.zone);
}

class _ZoneDetailsPageState extends State<ZoneDetailsPage> {
  _ZoneDetailsPageState(this.zone);
  Zone zone;
  Completer<GoogleMapController> _controller = Completer();
  static GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  int lastMarkerID = 0;
  Set<Polygon> _polygons = HashSet<Polygon>();

  static CameraPosition _kGoogleInitialCamera;

  @override
  void initState() {
    super.initState();
    _setPolygons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Zone Details'),
          actions: <Widget>[
            FlatButton(
              onPressed: () => _edit(zone),
              child: Icon(
                Icons.edit,
                color: Commons.colorThemeFont,
              ),
            ),
          ],
        ),
        body: Container(
            padding: EdgeInsets.only(bottom: 20, top: 40, left: 20, right: 20),
            alignment: Alignment.center,
            child: ListView(children: <Widget>[
              Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.map,
                        color: Color(zone.getColor()),
                        size: 40,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        zone.getName(),
                        style: TextStyle(
                            color: Commons.colorTheme,
                            fontSize: 40,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Divider(),
                  Column(children: <Widget>[
                    Commons.row2Text('Onwer: ', zone.ownerUser.name),
                    Divider(),
                    Commons.row2Text(
                        'Count: ',
                        zone.insideCount.toString() +
                            '/' +
                            zone.insideLimit.toString()),
                  ]),
                  Divider(),
                  Text(
                    'Map',
                    style: Commons.textStylePrimary,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    // don't forget about height
                    height: 350,
                    child: GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: _kGoogleInitialCamera,
                      markers: Set<Marker>.of(markers.values),
                      polygons: _polygons,
                    ),
                  )
                ],
              ),
            ])));
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  LatLng getCenterOfPolygon(List<LatLng> latLngList) {
    var centroid = {0: 0.0, 1: 0.0};
    for (int i = 0; i < latLngList.length; i++) {
      centroid[0] += latLngList.elementAt(i).latitude;
      centroid[1] += latLngList.elementAt(i).longitude;
    }
    int totalPoints = latLngList.length;
    return new LatLng(centroid[0] / totalPoints, centroid[1] / totalPoints);
  }

  void _setPolygons() {
    Commons.log('########_setPolygons');
    _polygons.clear();

    List<LatLng> polygonLatLongs = List<LatLng>();
    zone.points.forEach((point) {
      // Commons.log(point);
      polygonLatLongs.add(new LatLng(point['latitude'], point['longitude']));
    });
    _kGoogleInitialCamera =
        CameraPosition(target: getCenterOfPolygon(polygonLatLongs), zoom: 17);
    _polygons.add(
      Polygon(
        polygonId: PolygonId("0"),
        points: polygonLatLongs,
        fillColor: Color(zone.getColor()).withOpacity(0.2),
        strokeColor: Color(zone.getColor()),
        strokeWidth: Commons.strokeWidthPolygonAddZone,
      ),
    );
  }

  Future<void> _edit(Zone item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ZoneCreate(zone: item),
      ),
    );
    _setPolygons();
    setState(() {});
  }

}
