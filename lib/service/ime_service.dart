import 'dart:async';
import 'package:backgroud_location_service/constants.dart';
import 'package:background_location/background_location.dart';
import 'package:permission_handler/permission_handler.dart';

import 'event_model.dart';

String? generalNumber;
bool hasConnection = false;

enum LocationItemType {
  log,
  position,
}

class LocationItem {
  LocationItem(this.type, this.displayValue);

  final LocationItemType type;
  final String displayValue;
}

List<LocationItem> _positionItems = [];
/*TODO Flutter Baackground Location Service*/

Future<void> initBgService() async {
  BackgroundLocation.setAndroidConfiguration(5000);
  var run = await BackgroundLocation.isServiceRunning();
  print("isServiceRunning $run");
  if (!run) {
    BackgroundLocation.startLocationService(
      distanceFilter: 10,
      // forceAndroidLocationManager: true
    );
  }
  _locations();
}

Future<void> _locations() async {
  if (await _hasPermission() == true) {
    BackgroundLocation.isServiceRunning().then((value) {
      print("Is Running: $value");
    });
    BackgroundLocation.setAndroidNotification(
      title: "Notification title",
      message: "Notification message",
      icon: "@drawable/ic_launcher",
    );
    var _count=0;
    BackgroundLocation.getLocationUpdates((location) {
      _count++;
      print("location loggggger $_count  ${location.latitude} : ${location.longitude}");
      _positionItems.add(LocationItem(LocationItemType.position, "${location.latitude} : ${location.longitude}"));
      eventBus.fire(EventModel(event: eventLocationList, data: _positionItems));
    });
  } else {
    _requestPermission();
    print("permission denied");
  }
}

Future<void> stopLocationService()async {
  await BackgroundLocation.stopLocationService();
}

Future<bool> _hasPermission() async {
  final permissionRequestedResult = Permission.locationAlways.request();
  Permission.notification.request();
  return await permissionRequestedResult.isGranted;
}

Future<void> _requestPermission() async {
  if (!(await _hasPermission())) {
    final permissionRequestedResult = Permission.locationAlways.request();
    Permission.notification.request();
    if (await permissionRequestedResult.isGranted) {
      print("permission granted");
      _positionItems.add(LocationItem(LocationItemType.log, "permission ${permissionRequestedResult.toString()}"));
    } else {
      openAppSettings();
      print("permission denied");
      _positionItems.add(LocationItem(LocationItemType.log, "permission ${permissionRequestedResult.toString()}"));
    }
  }
}
