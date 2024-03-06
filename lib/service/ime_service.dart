import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

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
  if(service is AndroidServiceInstance){
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

  Timer.periodic(const Duration(seconds: 1), (timer) {
    if(service is AndroidServiceInstance){
      service.setForegroundNotificationInfo(
        title: "My App Service",
        content: "Running in background ${DateTime.now().hour} : ${DateTime.now().minute} : ${DateTime.now().second}",
      );

    }

    print("Running in background");
    service.invoke("update");
  });
}


@pragma('vm:entry-point')
FutureOr<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}
