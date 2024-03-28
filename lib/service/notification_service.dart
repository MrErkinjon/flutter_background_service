import 'package:permission_handler/permission_handler.dart';

Future<void> checkNotificationPermission() async {
  final permissionRequestedResult = Permission.notification.request();
  if (await permissionRequestedResult.isGranted) {
    print("permission granted");
  } else {
    openAppSettings();
    print("permission denied");
  }
}


