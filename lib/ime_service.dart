import 'dart:async';

import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as notification;

import 'event_model.dart';

class IMEService {
  final Location _location = Location();
  PermissionStatus? _permissionGranted;
  bool? _serviceEnabled;
  LocationData? _locationData;

  IMEService() {
    initService();
  }

  initService() async {
    checkNotificationPermission();
    if (await _checkPermissions()) {
      if (!await _checkService()){
        _requestService();
      }else{
        _listenLocation();
        _checkBackgroundMode();
        if(_enabled==false){
          _toggleBackgroundMode();
          print("IME : _toggleBackgroundMode ");
        }else{
          print("IME : _toggleBackgroundMode  $_enabled");
        }
        _updateNotification();
      }
    } else {
      _requestPermission();
    }
  }


  Future<bool> _checkService() async {
    final serviceEnabledResult = await _location.serviceEnabled();
    _serviceEnabled = serviceEnabledResult;

    print("IME : Current serviceEnabledResult granted:  ${_serviceEnabled}");
    return _serviceEnabled ?? false;
  }

  Future<void> _requestService() async {
    if (_serviceEnabled ?? false) {
      return;
    }
    final serviceRequestedResult = await _location.requestService();
    _serviceEnabled = serviceRequestedResult;
  }


  Future<bool> _checkPermissions() async {
    final permissionGrantedResult = await _location.hasPermission();
    _permissionGranted = permissionGrantedResult;
    print("IME : Current permissionGrantedResult granted:  ${_permissionGranted == PermissionStatus.granted}");
    return _permissionGranted == PermissionStatus.granted;
  }

  Future<void> _requestPermission() async {
    if (_permissionGranted != PermissionStatus.granted) {
      final permissionRequestedResult = await _location.requestPermission();
      _permissionGranted = permissionRequestedResult;
      print("IME : Current request permissionGrantedResult granted:  ${_permissionGranted == PermissionStatus.granted}");
    }
  }

  StreamSubscription<LocationData>? _locationSubscription;
  String? _error;

  Future<void> _listenLocation() async {
    _locationSubscription = _location.onLocationChanged.handleError((dynamic err) {
          if (err is PlatformException) {
              _error = err.code;
              print("error onLocationChanged: $_error");

          }
          _locationSubscription?.cancel();
            _locationSubscription = null;
        }).listen((currentLocation) {
            _error = null;
            // _location = currentLocation;
            print("IME : Current location $currentLocation  time: ${DateTime.now().second} second");
            eventBus.fire(EventModel(event: eventLocationList, data: currentLocation));
            _locationData=currentLocation;
        });

  }
  Future<void> _getLocation() async {
      _error = null;
    try {
      final locationResult = await _location.getLocation();
        _locationData = locationResult;
    } on PlatformException catch (err) {
        _error = err.code;
        print("error getLocation: $_error");
    }
  }

  Future<void> _stopListen() async {
    await _locationSubscription?.cancel();
      _locationSubscription = null;
  }

  Future<void> _updateNotification() async {

    print("IME : Current _updateNotification");
    _location.changeNotificationOptions(
      channelName: "bg_ime_service",
      title: "BG Service",
      subtitle: "Current lat:${_locationData?.latitude}| long:${_locationData?.longitude}",
      iconName: "ic_launcher",
      onTapBringToFront: true
    );
  }




  bool? _enabled;
  Future<void> _checkBackgroundMode() async {
      _error = null;
    final result = await _location.isBackgroundModeEnabled();
      _enabled = result;

      print("IME : _checkBackgroundMode $result");
  }

  Future<void> _toggleBackgroundMode() async {
      _error = null;
    try {
      final result =
      await _location.enableBackgroundMode(enable: !(_enabled ?? false));
        _enabled = result;

    } on PlatformException catch (err) {
        _error = err.code;
    }
  }
  Future<void> checkNotificationPermission() async {
    final permissionRequestedResult = notification.Permission.notification.request();
    if (await permissionRequestedResult.isGranted) {
      print("permission granted");
    } else {
      notification.openAppSettings();
      print("permission denied");
    }
  }
}