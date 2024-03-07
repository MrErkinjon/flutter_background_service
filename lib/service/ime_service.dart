import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:backgroud_location_service/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geolocator/geolocator.dart';

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
  final service = FlutterBackgroundService();

  await service.configure(
      androidConfiguration: AndroidConfiguration(onStart: onStart, isForegroundMode: true, autoStart: true),
      iosConfiguration: IosConfiguration(autoStart: true, onForeground: onStart, onBackground: onIosBackground));
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "My App Service",
        content: "Running in background ${DateTime.now().hour} : ${DateTime.now().minute} : ${DateTime.now().second}",
      );
    }
    await _locations();
    print("Running in background");
    service.invoke("update");
  });
}

Future<void> _locations() async {
  if (await _hasPermission()) {
    final item = await Geolocator.getCurrentPosition();
    _positionItems.add(LocationItem(LocationItemType.position, "${item.latitude} : ${item.longitude}"));
    eventBus.fire(EventModel(event: eventLocationList, data: _positionItems));
  } else {
    print("permission denied");
  }
}

Future<bool> _hasPermission() async {
  LocationPermission permission = await Geolocator.requestPermission();
  switch (permission) {
    case LocationPermission.whileInUse:
      print("permission whileInUse");
      _positionItems.add(LocationItem(LocationItemType.log, "permission whileInUse"));
      return true;
    case LocationPermission.always:
      _positionItems.add(LocationItem(LocationItemType.log, "permission always"));
      print("permission always");
      return true;
    case LocationPermission.denied:
      print("permission denied");
      _positionItems.add(LocationItem(LocationItemType.log, "permission denied"));
      return Geolocator.openLocationSettings();
    case LocationPermission.deniedForever:
      _positionItems.add(LocationItem(LocationItemType.log, "permission deniedForever"));
      return Geolocator.openAppSettings();
    case LocationPermission.unableToDetermine:
      _positionItems.add(LocationItem(LocationItemType.log, "permission unableToDetermine"));
      return Geolocator.openAppSettings();
  }
}

@pragma('vm:entry-point')
FutureOr<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}
