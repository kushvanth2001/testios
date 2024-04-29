import 'dart:async';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app_version_checker/flutter_app_version_checker.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'helper/callloghelper.dart';
import 'helper/mqttHelper.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state_background/phone_state_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Controller/chatDetails_controller.dart';
import 'Controller/chat_controller.dart';
import 'Controller/switch_controller.dart';
import 'constants/colorsConstants.dart';
import 'helper/socketHelper.dart';

import 'services/localNotificationService.dart';
import 'utils/snapPeUI.dart';
import 'views/chat/chatControllerr.dart';
import 'views/chat/chatEntered.dart';
import 'views/home.dart';
import 'utils/snapPeRoutes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'helper/SharedPrefsHelper.dart';
import 'helper/networkHelper.dart';
import 'views/catalogue/categoryScreen.dart';
import 'views/entry/Registration.dart';
import 'views/entry/login.dart';
import 'views/entry/loginWithPwd.dart';
import 'views/entry/splashScreen.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:call_log/call_log.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// const CHANNEL = MethodChannel('com.example.myapp/initializeApp');
// const MethodChannel _channel = MethodChannel('samples.flutter.dev/mqtt');
// Timer? timer;
  //const platform = const MethodChannel('com.example.myapp/callLog');
Future<void> main(List<String> args) async {
  runZonedGuarded(() async {
    
  WidgetsFlutterBinding.ensureInitialized();
  // debugPaintSizeEnabled = true; // to paint boxes around each widget
  // debugPaintBaselinesEnabled = true;
  // await Firebase.initializeApp();
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
     FirebaseMessaging.onBackgroundMessage(backgroudHandler);
     
    // Call the function to check for a new version
  //  checkForNewVersion();
  
   
  await platform.invokeMethod('checkCallLogPermission');
  
    await SharedPrefsHelper().init();

    // await SharedPrefsHelper()
    //     .setChatSessionId(DateTime.now().millisecondsSinceEpoch.toString());
 SharedPreferences prefs = await SharedPreferences.getInstance();
    // String chatSessionId = await SharedPrefsHelper().getChatSessionId() ?? "";
    prefs.setBool("leadload", true);
//await MqttManager.connectMqtt("wss://mqtt-dev.snap.pe", "$chatSessionId");
  
// await MqttManager.subscribeToTopic("$chatSessionId/#");
// await MqttManager.publishMessage("$chatSessionId/customer-chat/agent", "ignore");
 

    // Timer.periodic(Duration(minutes: 1), (timer) async {
    //   await twominapicall();
    // });

    // Get.put(SwitchController());
    // Get.put(ChatControllerr());

    
  //  _channel.setMethodCallHandler((call) async {
  //       print("the method handler called");
  //     switch (call.method) {
      
  //       case 'onDataReceived':
  //         String receivedData = call.arguments;
  //         // Handle the received data in your Flutter code
  //         print('Received data from Android: $receivedData');
  //         Map<String,dynamic> data=jsonDecode(receivedData);
  //            // Find the ChatModel object with the matching customerNo
  //            print("local notic");
  //                       LocalNotificationService.createAndDisplayNotification(RemoteMessage(notification: RemoteNotification(title: "app_name".toString(),body: "message".toString())));}});

    runApp(MyApp());
  
  }, (error, stackTrace) {
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

Future<void> backgroudHandler(RemoteMessage message) async {
  print("Notification - Backgroung Handler");
  // if (message.data['title'] != null) {
  if (message.notification?.title != null) {
    print("Notification - ${message.data.toString()}");
    // LocalNotificationService.createAndDisplayNotification(message);
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    //checkForUpdate();

   // GlobalChatNumbers.clearAppName();
    //for loading indiactor
    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 50.0
      ..radius = 10.0
      ..progressColor = kPrimaryColor
      ..backgroundColor = Colors.transparent
      ..boxShadow = <BoxShadow>[] //to make the background transparent
      ..indicatorColor = kPrimaryColor
      ..textColor = Colors.white
      ..maskColor = Colors.transparent
      ..userInteractions = true
      ..dismissOnTap = true;

    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    // Remove the WidgetsBindingObserver
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) async{
//     super.didChangeAppLifecycleState(state);
//    // If the app is paused or inactive, cancel any active toast messages
   
//     if (state == AppLifecycleState.paused ||
//         state == AppLifecycleState.inactive) {
//       SnapPeUI().removeAllQueuedToasts();
//       print("TOAST CANCEL");
//     } else if (state == AppLifecycleState.resumed) {
//     //  If the app is resumed, check for an active socket connection
      
//     }else if(state== AppLifecycleState.detached){
// print("APP IS DETACHED");
// await MqttManager.disconnect();
//     }else{

//     }
//   }

  
  void checkForUpdate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int previousVersion = prefs.getInt('appVersion') ?? 0;
    int currentVersion = 12; // Set this to your current app version

    print(
        "current version : $currentVersion and previous version : $previousVersion");
    if (currentVersion > previousVersion) {
      bool _isLogin = await SharedPrefsHelper().getLoginStatus();
      print("$_isLogin from checkupd");
      String? token = await SharedPrefsHelper().getToken();
      print("Token before clearing: $token");

      // Clear cache
      await DefaultCacheManager().emptyCache();

      // Clear app data
      final appDir = await getApplicationSupportDirectory();
      if (appDir.existsSync()) {
        appDir.deleteSync(recursive: true);
      }

      // Update stored app version
      prefs.setInt('appVersion', currentVersion);
      // Restore login status
      if (_isLogin) {
        prefs.setBool('isLogin', _isLogin);
      }

      print("Login status after restoring: ${prefs.getBool('isLogin')}");
      print("Token after restoring: ${prefs.getString('token')}");
      print("cache and data cleared");
    } else {
      print("old version cache and data not cleared");
    }
  }

// static const platform = MethodChannel('com.example.myapp/callLog');

// void startCallLogService() {
//   platform.invokeMethod('startCallLogService');
// }

  @override
  Widget build(BuildContext context) {
    //Get.put(ChatDetailsController(context));
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: kStatusBarColor,
        systemNavigationBarColor: kNavigationBarColor,
      ),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        theme: ThemeData(
            primarySwatch: kPrimaryColor,
            textTheme: Theme.of(context)
                .textTheme
                .apply(bodyColor: kSecondayTextcolor),
            fontFamily: GoogleFonts.lato().fontFamily),
        darkTheme: ThemeData(brightness: Brightness.dark),
        initialRoute: SnapPeRoutes.splashRoute,
        builder: EasyLoading.init(),
        routes: {
          SnapPeRoutes.loginRoute: (context) => LogIn(),
          SnapPeRoutes.homeRoute: (context) => Home(),
          // SnapPeRoutes.otpRoute: (context) => Otp(mobileNumber: ""),
          SnapPeRoutes.registrationRoute: (context) => Registration(),
          SnapPeRoutes.loginWithPwdRoute: (context) => LogInWithPwd(),
          SnapPeRoutes.splashRoute: (context) => SplashScreen(),
          SnapPeRoutes.categoryRoute: (context) => CategoryScreen()
        },
      ),
    );
  }
}



bool areEntriesEqual(Map<String, dynamic> entry1, Map<String, dynamic> entry2) {
  return entry1['timestamp'] == entry2['timestamp'];
}

List<Map<String, dynamic>> getNewLogEntries(
    List<Map<String, dynamic>> latestLog,
    List<Map<String, dynamic>> storedLog) {
  Set<Map<String, dynamic>> storedLogSet =
      Set<Map<String, dynamic>>.from(storedLog);
  Set<Map<String, dynamic>> latestLogSet =
      Set<Map<String, dynamic>>.from(latestLog);
  Set<Map<String, dynamic>> newEntries = latestLogSet.difference(storedLogSet);
  List<Map<String, dynamic>> filteredNewEntries = newEntries
      .toList()
      .where((newEntry) => storedLog
          .every((storedEntry) => !areEntriesEqual(newEntry, storedEntry)))
      .toList();

  return filteredNewEntries;
}

Future<void> initalizeservice() async {
  final service = FlutterBackgroundService();
  await service.configure(
      iosConfiguration: IosConfiguration(),
      androidConfiguration: AndroidConfiguration(
          initialNotificationContent: "Capturing Call  Logs",
          onStart: servicelogic,
          isForegroundMode: true,
          autoStart: true,
          autoStartOnBoot: true));
}

@pragma('vm:entry-point')
servicelogic(ServiceInstance service) async {

  
  Timer.periodic(Duration(minutes: 1), (Timer timer) async {
    print('backgroundservice is working');
    getcalldata();
  });
}

getcalldatabytimestamp() async {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final SharedPreferences prefs = await _prefs;
  Iterable<CallLogEntry> k = await CallLog.query(dateFrom: 1711120254674);
  List<Map<String, dynamic>> logsaftertime = k.map((e) => e.toMap()).toList();
  if (logsaftertime.length != 0) {
    if (await CallLogHelper.checkInternetConnectivity()) {
      prefs.setString('logsaftertime', "${logsaftertime.first['date']}");

      if (prefs.containsKey('nonetworklogs')) {
        String v = prefs.getString('nonetworklogs') ?? "";
        List<Map<String, dynamic>> prev = jsonDecode(v);
        logsaftertime.addAll(prev);
        prefs.setString('nonetworklogs', jsonEncode([]));
      }

      for (int i = 0; i < logsaftertime.length; i++) {
        CallLogHelper.postCallsToFirstApi(logsaftertime[i]);
      }
      
    } else {
      if (!prefs.containsKey('nonetworklogs')) {
        prefs.setString('nonetworklogs', jsonEncode(logsaftertime));
      } else {
        String v = prefs.getString('nonetworklogs') ?? "";
        List<Map<String, dynamic>> prev = jsonDecode(v);
        prev.addAll(logsaftertime);
        prefs.setString('nonetworklogs', jsonEncode(prev));
      }
    }
  }
}

void getcalldata() async {
  Iterable<CallLogEntry> entries = await CallLog.get();

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  final SharedPreferences prefs = await _prefs;

  await Future.delayed(Duration(seconds: 4));

  String? k = prefs.getString('calllogstring') ?? null;
  try {
    Iterable<CallLogEntry> entries = await CallLog.get();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? k = prefs.getString('calllogstring') ?? null;

    if (k == null) {
      List<Map<String, dynamic>> l = entries.map((e) {
        return e.toMap();
      }).toList();

      prefs.setString('calllogstring', jsonEncode(l));
      print("knull///////////");
    } else {
      List<Map<String, dynamic>> l = entries.map((e) => e.toMap()).toList();
      List<Map<String, dynamic>> z =
          (jsonDecode(k) as List).cast<Map<String, dynamic>>();

      var res = getNewLogEntries(l, z);
      if (res.length != 0) {
        List<Map<String, dynamic>> l = entries.map((e) {
          return e.toMap();
        }).toList();
        prefs.setString('calllogstring', jsonEncode(l));

        String? resfromstorage = prefs.getString('resultlocal');
        if (resfromstorage == null) {
          prefs.setString('resultlocal', jsonEncode(res));
        } else {
          List<Map<String, dynamic>> u =
              (jsonDecode(resfromstorage) as List).cast<Map<String, dynamic>>();
          u.addAll(res);
          prefs.setString('resultlocal', jsonEncode(u));
        }

        if (await CallLogHelper.checkInternetConnectivity()) {
          String? resfromstorage = prefs.getString('resultlocal') ;
          if(resfromstorage!=null){
          List<Map<String, dynamic>> u =
              (jsonDecode(resfromstorage) as List).cast<Map<String, dynamic>>();
          for (int i = 0; i < u.length; i++) {
            await CallLogHelper.postCallsToFirstApi(u[i]);
          }
          }
          prefs.setString('resultlocal', jsonEncode([]));
        }

//
      }

      print(res.length);
    }
  } catch (e) {
    print("An error occurred: $e");
  }
}
class PermissionExample extends StatefulWidget {
  @override
  _PermissionExampleState createState() => _PermissionExampleState();
}

class _PermissionExampleState extends State<PermissionExample> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(content: Center(
        child: ElevatedButton(
          onPressed: _requestPermissions,
          child: Text('Request Permissions'),
        ),
      ),);
  }

  Future<void> _requestPermissions() async {
    var permissions = [
      
      Permission.phone,
      Permission.storage,
      Permission.microphone,
      Permission.notification,
      Permission.ignoreBatteryOptimizations,
    ];

    Map<Permission, PermissionStatus> statuses = await permissions.request();

    statuses.forEach((permission, status) {
      if (!status.isGranted) {
        // Handle denied permissions here
        print('Permission ${permission.toString()} was denied');
      }
    });
  }
}
Future<String> getReleaseVersion() async {
  final contents = await rootBundle.loadString('pubspec.yaml');
  final lines = contents.split('\n');
  
  for (var line in lines) {
    if (line.startsWith('version:')) {
      final version = line.split(':')[1].trim();
      return version;
    }
  }
  return 'Error: Version not found';
}
 void checkForNewVersion() async {
  print('chek for new version');
  try{
   final _snapChatChecker = AppVersionChecker(appId: 'com.leads.manager');
 AppCheckerResult futurev=await _snapChatChecker.checkUpdate();
 

if (futurev.newVersion != null &&
    (int.tryParse(futurev.currentVersion.split('.').toList().first)! <
        int.tryParse(futurev.newVersion!.split('.').toList().first)!)) {
        
       Get.dialog(
        AlertDialog(
          title: Text('New Version Available'),
          content: Text('if the App does not updating directly from playstore Then Uninstall this app and install again, it from playstore'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                
                Get.back(); // Close the dialog
                _launchInstagramPlayStore();
              },
              child: Text('Update'),
            ),
          ],
        ),
      );
    }}catch(e){
      print("version error $e");
    }}
  void _launchInstagramPlayStore() async {
    const url = 'https://play.google.com/store/apps/details?id=com.leads.manager';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
