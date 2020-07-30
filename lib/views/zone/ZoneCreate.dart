import 'dart:async';
import 'dart:collection';
import 'dart:ui';
import 'package:TrackerApp/models/Zone.dart';
import 'package:TrackerApp/views/zone/zoneDialog.dart';
import 'package:TrackerApp/utils/commons.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ZoneCreate extends StatefulWidget {
  ZoneCreate({Key key, this.zone}) : super(key: key);
  final Zone zone;
  @override
  _ZoneCreateState createState() => _ZoneCreateState(this.zone);
}

class _ZoneCreateState extends State<ZoneCreate> {
  _ZoneCreateState(this.zone);
  Zone zone;
  String addString = 'ADD';
  Icon addIcon = Icon(Icons.add);
  Completer<GoogleMapController> _controller = Completer();
  static GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  int lastMarkerID = 0;
  Set<Polygon> _polygons = HashSet<Polygon>();
  Set<Polyline> _polylines = HashSet<Polyline>();

  static final CameraPosition _kIPS =
      CameraPosition(target: LatLng(38.5219167, -8.8383817), zoom: 17);

  static CameraPosition _kGoogleInitialCamera = _kIPS;

  @override
  void initState() {
    super.initState();
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    //checks if edit or new zone
    if (zone != null && zone.id != null) {
      addString = 'EDIT';
      addIcon = Icon(Icons.edit);
      setExistingZoneMarkers();
      //centers the map camera to the zone location
      _kGoogleInitialCamera = CameraPosition(target: zone.getCenterOfPolygon(), zoom: 17);
    } else {
      zone = new Zone();
    }
  }

  /**
   * sets the markers of the existing zone
   */
  void setExistingZoneMarkers() {
    zone.points.forEach((e) {
      print(e);
       _addMarkerLongPressed(new LatLng(e['latitude'], e['longitude']));
    });
  }

  @override
  Widget build(BuildContext context) {
    Commons.log('ZoneCreate');
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text(addString + ' ZONE')),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: _kGoogleInitialCamera,
            onLongPress: (latlang) {
              _addMarkerLongPressed(latlang);
            },
            markers: Set<Marker>.of(markers.values),
            polygons: _polygons,
            polylines: _polylines,
          ),
          // onTapDown: (TapDownDetails details) => _storePosition(details),
          // )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Add your onPressed code here!
          // TODO check Polygons

          Commons.log(zone.points);
          ZoneDialog dialog = ZoneDialog(zone);
          bool addedZone = await showDialog(
              context: context, builder: (context) => dialog); // complete
          Commons.log("await END!!!!!!!!!!");
          if (markers.length != 0) _setPolygons();
          setState(() {});
          if (addedZone) {
            Commons.log('pop to list');
            Navigator.of(context).pop(true);
          }
        },
        child: addIcon,
        backgroundColor: Commons.colorTheme,
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _setPolygons() {
    Commons.log('########_setPolygons');
    _polygons.clear();
    List<LatLng> polygonLatLongs = List<LatLng>();
    markers.forEach((key, value) {
      Commons.log(value.position);
      polygonLatLongs.add(value.position);
    });
    if (polygonLatLongs.length >= 3) {
      _setPolylines(polygonLatLongs);
      polygonLatLongs.add(polygonLatLongs.first);
    }

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

  void _setPolylines(List<LatLng> polygonLatLongs) {
    Commons.log('########_setPolylines');
    _polylines.clear();
    List<LatLng> polylineLatLongs = List<LatLng>();
    polylineLatLongs.add(polygonLatLongs.first);
    polylineLatLongs.add(polygonLatLongs.last);
    _polylines.add(
      Polyline(
        polylineId: PolylineId("0"),
        points: polylineLatLongs,
        color: Color(zone.getColor())
            .withOpacity(0.5)
            .withRed(200)
            .withGreen(200)
            .withBlue(200),
        width: Commons.strokeWidthPolyLinesAddZone,
      ),
    );
  }

  Future _addMarkerLongPressed(LatLng latlong, [_lastMarkerID]) async {
    _lastMarkerID ?? lastMarkerID++;
    _lastMarkerID = _lastMarkerID ?? lastMarkerID;
    Commons.log("######_addMarkerLongPressed");
    Commons.log({'_lastMarkerID': _lastMarkerID});
    final MarkerId markerId = MarkerId(_lastMarkerID.toString());
    Marker marker = Marker(
      markerId: markerId,
      draggable: true,
      position: latlong,
      onDragEnd: ((value) {
        _addMarkerLongPressed(value, _lastMarkerID);
      }),
      infoWindow: InfoWindow(
        title: markerId.value,
        // snippet: 'This looks good',
      ),
      consumeTapEvents: true,
      onTap: _showDialog(
          context, <String>["Delete Marker"], _lastMarkerID, _deleteMarker),
      icon: await createCustomMarkerBitmap(markerId.value),
    );
    markers[markerId] = marker;
    zone.setPointsFromMarkers(markers);
    _setPolygons();
    setState(() {});
  }

  // var _tapPosition;
  // void _storePosition(TapDownDetails details) {
  //   _tapPosition = details.globalPosition;
  // }

  _deleteMarker(_lastMarkerID) {
    markers.remove(MarkerId(_lastMarkerID.toString()));
    _setPolygons();
  }

  _showDialog(BuildContext context, List<String> popupRoutes, _itemID, handle) {
    return () async {
      Offset positionCenter = Offset(MediaQuery.of(context).size.width / 2,
          MediaQuery.of(context).size.height / 2);
      MediaQuery.of(context).size.width;
      MediaQuery.of(context).size.height;
      String selected = await showMenu<String>(
        context: context,
        position: RelativeRect.fromRect(
            positionCenter & Size(40, 40), // smaller rect, the touch area
            Offset.zero & MediaQuery.of(context).size),
        items: popupRoutes.map((String popupRoute) {
          return new PopupMenuItem<String>(
            child: new Text(popupRoute),
            value: popupRoute,
          );
        }).toList(),
      );
      if (selected != null) {
        handle(_itemID);
        setState(() {});
      }
    };
  }

  Future<BitmapDescriptor> createCustomMarkerBitmap(String title) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = Commons.colorMarkersAddZone;
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    final double radius = 80 / 2;
    canvas.drawCircle(
      Offset(radius, radius),
      radius,
      paint,
    );
    textPainter.text = TextSpan(
      text: title.toString(),
      style: TextStyle(
        fontSize: radius - 5,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        radius - textPainter.width / 2,
        radius - textPainter.height / 2,
      ),
    );
    final image = await pictureRecorder.endRecording().toImage(
          radius.toInt() * 2,
          radius.toInt() * 2,
        );
    final data = await image.toByteData(format: ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }
}
