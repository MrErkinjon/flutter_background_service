import 'dart:async';
import 'dart:developer';
import 'dart:ui';

// import 'package:geofence_foreground_service/constants/geofence_event_type.dart';
// import 'package:geofence_foreground_service/exports.dart';
// import 'package:geofence_foreground_service/geofence_foreground_service.dart';
// import 'package:geofence_foreground_service/models/notification_icon_data.dart';
// import 'package:geofence_foreground_service/models/zone.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

String? generalNumber;
bool hasConnection = false;

// class ImeService {
//   final List<LatLng> timesSquarePolygon = [
//     const LatLng(40.758078, -73.985640),
//     const LatLng(40.757983, -73.985417),
//     const LatLng(40.757881, -73.985493),
//     const LatLng(40.757956, -73.985688),
//   ];
//
//   // Platform messages are asynchronous, so we initialize in an async method.
//   Future<void> initPlatformState() async {
//     await Permission.location.request();
//     await Permission.locationAlways.request();
//     await Permission.notification.request();
//
//     bool hasServiceStarted = await GeofenceForegroundService().startGeofencingService(
//       contentTitle: 'Test app is running in the background',
//       contentText: 'Test app will be running to ensure seamless integration with ops team',
//       notificationChannelId: 'com.app.geofencing_notifications_channel',
//       serviceId: 525600,
//       isInDebugMode: true,
//       notificationIconData: const NotificationIconData(
//         resType: ResourceType.mipmap,
//         resPrefix: ResourcePrefix.ic,
//         name: 'launcher',
//       ),
//       callbackDispatcher: callbackDispatcher,
//     );
//
//     if (hasServiceStarted) {
//       await GeofenceForegroundService().addGeofenceZone(
//           zone: Zone(
//         id: 'zone#1_id',
//         radius: 10000,
//         coordinates: timesSquarePolygon,
//       ));
//
//     }
//
//     log(hasServiceStarted.toString(), name: 'hasServiceStarted');
//   }
//
//   Future<void> stopPlatformState() async {
//     await GeofenceForegroundService().stopGeofencingService();
//   }
// }
//
// // This method is a top level method
// @pragma('vm:entry-point')
// void callbackDispatcher() async {
//   GeofenceForegroundService().handleTrigger(
//     backgroundTriggerHandler: (zoneID, triggerType) {
//       print('$zoneID zoneID');
//
//       if (triggerType == GeofenceEventType.enter) {
//         print('enter triggerType');
//       } else if (triggerType == GeofenceEventType.exit) {
//         print('exit triggerType');
//       } else if (triggerType == GeofenceEventType.dwell) {
//         print('dwell triggerType');
//       } else {
//         print('unknown triggerType');
//       }
//
//       return Future.value(true);
//     },
//   );
// }
//

enum LocationItemType {
  log,
  position,
}

class LocationItem {
  LocationItem(this.type, this.displayValue);

  final LocationItemType type;
  final String displayValue;
}

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
