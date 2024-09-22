import 'dart:async';
import 'dart:convert';
import 'package:blr_intern/phone.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? installTime;
String? downloadTime;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getString('installTimestamp') == null) {
    String installTime =
        DateFormat('yyyy-MM-dd – kk:mm:ss').format(DateTime.now());
    await prefs.setString('installTimestamp', installTime);
  }
  if (prefs.getString('downloadTimestamp') == null) {
    String downloadTime =
        DateFormat('yyyy-MM-dd – kk:mm:ss').format(DateTime.now());
    await prefs.setString('downloadTimestamp', downloadTime);
  }

  runApp(Myapp());
}

String? dtype;
String? dname;
String? osVersion;
String? version;
String? deviceId;

Future<String?> getDeviceId() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    dtype = 'android';
    dname = androidInfo.model;
    osVersion = androidInfo.version.release;
    version = androidInfo.version.toString();
    return androidInfo.id;
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    dtype = 'ios';
    dname = iosInfo.name;
    osVersion = iosInfo.systemVersion;

    return iosInfo.identifierForVendor;
  }

  return null;
}

Future<String?> getIPAddress() async {
  try {
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4) {
          return addr.address;
        }
      }
    }
  } catch (e) {
    debugPrint("Failed to get IP address: $e");
    return null;
  }

  return null;
}

Future<String?> getDeviceIpAddress() async {
  try {
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4) {
          return addr.address;
        }
      }
    }
  } catch (e) {
    debugPrint("Failed to get IP address: $e");
    return null;
  }

  return null;
}

Future splashscreen() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  Position? position = await Geolocator.getCurrentPosition();

  Response request = await http.post(
      Uri.parse('http://devapiv4.dealsdray.com/api/v2/user/device/add'),
      body: jsonEncode({
        "deviceType": dtype,
        "deviceId": await getDeviceId(),
        "deviceName": dname,
        "deviceOSVersion": osVersion,
        "deviceIPAddress": await getDeviceIpAddress(),
        "lat": position.latitude,
        "long": position.longitude,
        "buyer_gcmid": "",
        "buyer_pemid": "",
        "app": {
          "version": version,
          "installTimeStamp": installTime.toString(),
          "uninstallTimeStamp": "2022-02-10T12:33:30.696Z",
          "downloadTimeStamp": downloadTime.toString(),
        }
      }));
  var r = jsonDecode(request.body);
  print(request.body);
  deviceId = r["data"]["deviceId"];
}

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    Timer(
        Duration(seconds: 3),
        () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => Phone(
                      deviceId: deviceId.toString(),
                    ))));
  }

  @override
  Widget build(BuildContext context) {
    splashscreen();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Image.asset(
            'asset/entryimg.png',
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
