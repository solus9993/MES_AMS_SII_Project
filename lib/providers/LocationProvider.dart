import 'dart:async';

import 'package:TrackerApp/utils/commons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationProvider extends ChangeNotifier {
  final Location location = Location();
  SharedPreferences sharedPreferences;

  PermissionStatus _permissionGranted;

/**
 * checks if the app has permissions
 */
  Future<void> checkPermissions() async {
    final PermissionStatus permissionGrantedResult =
        await location.hasPermission();
    _permissionGranted = permissionGrantedResult;
  }

/**
 * request permissions
 */
  Future<void> _requestPermission() async {
    if (_permissionGranted != PermissionStatus.granted) {
      final PermissionStatus permissionRequestedResult =
          await location.requestPermission();
      _permissionGranted = permissionRequestedResult;
      if (permissionRequestedResult != PermissionStatus.granted) {
        return;
      }
    }
  }

/**
 * checks if the app has permissions,
 * if not request permissions
 */
  Future<bool> checkAndRequestPermition() async {
    await checkPermissions();
    if (_permissionGranted == PermissionStatus.denied) {
      await _requestPermission();
    }
    return _permissionGranted == PermissionStatus.granted;
  }

  bool _serviceEnabled;
/**
 * checks if location service is On in the device
 */
  Future<void> checkService() async {
    final bool serviceEnabledResult = await location.serviceEnabled();
    _serviceEnabled = serviceEnabledResult;
  }

/**
 * requests the user to turn on the device location service
 */
  Future<void> _requestService() async {
    if (_serviceEnabled == null || !_serviceEnabled) {
      final bool serviceRequestedResult = await location.requestService();
      _serviceEnabled = serviceRequestedResult;
      if (!serviceRequestedResult) {
        return;
      }
    }
  }

/**
 * checks if location service is On in the device,
 * if not requests the user to turn on the device location service
 */
  Future<bool> checkAndRequestService() async {
    await checkService();
    if (_serviceEnabled) {
      await _requestService();
    }
    return _serviceEnabled;
  }

  LocationData _location;
  StreamSubscription<LocationData> _locationSubscription;
  String _error;

/**
 * listener for the location service,
 * checks and resquests permissions and service,
 * if the user profile has sharelocation off it will cancel the listener
 */
  Future<void> listenLocation() async {
    checkAndRequestService()
        .then((granted) => granted ? checkAndRequestService() : false);
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getBool('shareLocation')) {
      _locationSubscription =
          location.onLocationChanged.handleError((dynamic err) {
        _error = err.code;
        _locationSubscription.cancel();
      }).listen((LocationData currentLocation) {
        if (!sharedPreferences.containsKey('shareLocation') ||
            !sharedPreferences.getBool('shareLocation') &&
                _locationSubscription != null) {
          Commons.log('stopListen shareLocation');
          stopListen();
        } else {
          _error = null;
          if (_location != currentLocation) {
            _location = currentLocation;
            notifyListeners();
          }
        }
      });
    } else {
      stopListen();
    }
  }

  Future<void> stopListen() async {
    if (_locationSubscription != null) _locationSubscription.cancel();
  }

/**
 * requests the location to the location service
 */
  Future<LocationData> getLocation() async {
    _error = null;
    try {
      final LocationData _locationResult = await location.getLocation();
      _location = _locationResult;
    } on PlatformException catch (err) {
      _error = err.code;
    }
    return _location;
  }

/**
 * gets the last saved location
 */
  LocationData getLastLocation() {
    return _location;
  }

  StreamController<LocationData> _locationController =
      StreamController<LocationData>();

  Stream<LocationData> get locationStream => _locationController.stream;

/**
 * checks and resquests the permissions and location service 
 */
  LocationProvider() {
    checkAndRequestService()
        .then((granted) => granted ? checkAndRequestService() : false);
  }
}
