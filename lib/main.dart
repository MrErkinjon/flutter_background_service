import 'dart:async';
import 'package:backgroud_location_service/first_screen/first_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'constants.dart';
import 'service/event_model.dart';
import 'service/ime_service.dart';
import 'service/notification_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
    checkNotificationPermission(),
     // initBgService(),
  ]).then((value) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<LocationItem> positionItems = [];
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
            positionItems = event.data as List<LocationItem>;
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
              title: Text(positionItems[index].displayValue),
              leading: Text(index.toString()),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
         Navigator.push(context, MaterialPageRoute(builder: (_)=>FirstScreen()));
        },
        child: Icon(Icons.clear),
      ), // his trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
