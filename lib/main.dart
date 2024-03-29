import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

import 'change_notification.dart';
import 'change_settings.dart';
import 'enable_in_background.dart';
import 'event_model.dart';
import 'get_location.dart';
import 'ime_service.dart';
import 'listen_location.dart';
import 'permission_status.dart';
import 'service_enabled.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  IMEService();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Location',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: const MyHomePage(title: 'Flutter Location Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<LocationData> positionItems = [];
  StreamSubscription? subscription;

  @override
  void dispose() {
    subscription?.cancel();
    // stopLocationService();
    super.dispose();
  }

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      subscription = eventBus.on<EventModel>().listen((event) {
        if (event.event == eventLocationList) {
          setState(() {
            positionItems.add(event.data);
          });
        }
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView.builder(
          itemCount: positionItems.length,
          itemBuilder: (_, index) {
            return ListTile(
              title: Text("lat:${positionItems[index].latitude} long:${positionItems[index].latitude}"),
              leading: Text(index.toString()),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          positionItems.clear();
          setState(() {

          });
        },
        child: Icon(Icons.clear),
      ), // his trailing comma makes auto-formatting nicer for build methods.
    );
  }
}