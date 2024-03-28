import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({Key? key}) : super(key: key);

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {

  late final LocalAuthentication auth;
  bool _supportState = false;

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Let OS determine authentication method',
        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: false),
      );
      if(authenticated) {
       print("Auth $authenticated");
      }
    } on PlatformException catch (e) {
      print(e);
      return;
    }
    if (!mounted) {
      return;
    }
  }

  Future<void> _getAvailableBiometric() async {
    List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();
    print("List of availableBiometrics : $availableBiometrics");
    if (!mounted) {
      return;
    }
  }

  @override
  void initState() {
    auth = LocalAuthentication();
    auth.isDeviceSupported().then((bool isSupported) => setState(() {
      _supportState = isSupported;
    }));
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    DateTime lastTimeBackbuttonWasClicked = DateTime.now();
    return WillPopScope(
      onWillPop: () async {
        if (DateTime.now().difference(lastTimeBackbuttonWasClicked) >= Duration(seconds: 2)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Press the back button again to go back"),
              duration: Duration(seconds: 2),
            ),
          );

          lastTimeBackbuttonWasClicked = DateTime.now();
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Content View'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children:  [
              Text(
                'This is the Content View',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(onPressed: (){
                _getAvailableBiometric();
                if(_supportState) {
                  _authenticate();
                }else{
                print("OK");
                }
              }, child: Text("Biometric"))
            ],
          ),
        ),
      ),
    );
  }
}
