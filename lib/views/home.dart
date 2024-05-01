import 'dart:async';

import 'package:call_log/call_log.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../Controller/chatDetails_controller.dart';
import '../helper/networkHelper.dart';
import '../marketing/marketing.dart';
import '../marketing/promotions.dart';
import '../models/model_lead.dart';
import 'leads/leadDetails/leadDetails.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:phone_state_background/phone_state_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Controller/leads_controller.dart';
import 'dart:convert';
import '../utils/snapPeNetworks.dart';
import '../Controller/chat_controller.dart';
import '../constants/colorsConstants.dart';
import '../helper/SharedPrefsHelper.dart';
import '../models/model_chat.dart';
import '../services/localNotificationService.dart';
import 'CustomDrawer.dart';
import 'chat/chatDetailsScreen.dart';
import 'chat/liveAgentScreen.dart';
import 'customers/customersScreen.dart';
import 'leads/leadsScreen.dart';
import 'profile/profileScreen.dart';
import '../utils/snapPeUI.dart';
import 'package:http/http.dart' as http;
import '../constants/networkConstants.dart';
import '../constants/styleConstants.dart';
import '../helper/callloghelper.dart';
import '../helper/mqttHelper.dart';
import 'catalogue/catalogueScreen.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'order/orderScreen.dart';
import '../models/model_application.dart';
Future<Map<String,dynamic>?> fetchLatestCallLog() async {
  Iterable<CallLogEntry> entries = await CallLog.get();
  if (entries.isNotEmpty) {
    // Get the most recent call log entry
    CallLogEntry latestEntry = entries.first;
       print('Latest Call Log - Name: ${latestEntry.name}, Number: ${latestEntry.number}');
    return latestEntry.toMap();
 
    // You can access other properties like duration, call type, etc.
  } else {
    print('No call logs found.');
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver  {
  int _screenIndex = 0;
  List<String>? phoneNumbers;
 Map<String, List<Map<String, dynamic>>> totalData={};
  SharedPrefsHelper sharedPrefsHelper = SharedPrefsHelper();
  String? SaveLeadFromCalls;
  String? clientGroupName;
  String? clientPhoneNo;
  String? clientName;
  String? response;
  String removenumber="";
    MethodChannel _channel = MethodChannel('samples.flutter.dev/mqtt');
    final channel = WebSocketChannel.connect(
  Uri.parse('wss://mqtt-dev.snap.pe'),
);
  // String? _selectedApplicationName;
  List<String?> _applicationNames = [];
  String? firstAppName;
  String? userId;
  static const platform = const MethodChannel('com.example.myapp/callLog');
  final phoneNumbersNotifier = ValueNotifier<List<String>?>(null);
  final LeadController leadController = LeadController();
  int pausedtime=0;
  // static const platform2 =
  //     MethodChannel('com.example.myapp/locationPermission');


    @override
  void didChangeAppLifecycleState(AppLifecycleState state) async{
    super.didChangeAppLifecycleState(state);
    // If the app is paused or inactive, cancel any active toast messages

if(state==AppLifecycleState.paused){
  print("paused........");
  setState(() {
      pausedtime=DateTime.now().millisecondsSinceEpoch;
  });

}
  if (state == AppLifecycleState.resumed) {
    print("stateresumed''''''''''''''''''''''''''");
    int pausedseconds=((DateTime.now().millisecondsSinceEpoch-pausedtime)/1000).toInt();
      print("pasuedseconds$pausedtime");
    print("pasuedseconds$pausedseconds");
    if(pausedtime==0 || pausedseconds>10)
  
     
     fetchData().then((_) {
      print('notifier is notnull');
      print(phoneNumbersNotifier.value);
      if (phoneNumbersNotifier.value != null &&
          phoneNumbersNotifier.value!.isNotEmpty) {
            print('notifier is notnull');
            
        _showPhoneNumbersDialog();
      }
    });
  
    }
  }
  Map<String, List<Map<String, dynamic>>> castToDesiredType(dynamic jsonData) {
  try {
    Map<String, List<Map<String, dynamic>>> result = {};
    if (jsonData is Map<String, dynamic>) {
      jsonData.forEach((key, value) {
        if (value is List) {
          List<Map<String, dynamic>> listValue = [];
          for (var item in value) {
            if (item is Map<String, dynamic>) {
              listValue.add(Map<String, dynamic>.from(item));
            }
          }
          result[key] = listValue;
        }
      });
    }
    return result;
  } catch (e) {
    print('Error casting to desired type: $e');
    // Return an empty map or handle the error as needed
    return {};
  }
}

  void sendClientGroupNameToCallLogReceiver() {
    try {
      print("$clientGroupName sent to background ");
      platform.invokeMethod('sendClientGroupName', {
        'clientGroupName': clientGroupName,
        "clientPhoneNo": clientPhoneNo,
        "clientName": clientName,
        "userId": userId
      });
      print(
          "$userId and $clientGroupName sent. to background \n\nn\nn\nn\nn\nnn\n\n\n\n\n\n\n\nnn\n\n\n\ ");
    } on PlatformException catch (e) {
      print("Failed to send clientGroupName: '${e.message}'.");
    }
  }


void _hidePhoneNumbersDialog() {
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  }
}




  // _getPhoneNumbers() async {
  //   try {
  //     final String? phoneNumbersJson =
  //         await platform.invokeMethod('getPhoneNumbers');
  //     if (phoneNumbersJson != null) {
  //       phoneNumbers = (json.decode(phoneNumbersJson) as List)
  //           .map((item) => item as String)
  //           .toList();
  //       if (phoneNumbers!.isNotEmpty) {
  //         print('Phone numbers in local storage: $phoneNumbers 2');
  //         _showPhoneNumbersDialog();
  //       }
  //       print('Phone numbers in local storage: $phoneNumbers');
  //     } else {
  //       print('Phone numbers list is null');
  //     }
  //   } on PlatformException catch (e) {
  //     print("Failed to get phone numbers: '${e.message}'.");
  //   }
  // }

  // _showPhoneNumbersDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text('ADD LEAD FOM CALLS'),
  //         content: ListView.builder(
  //           itemCount: phoneNumbers!.length,
  //           itemBuilder: (context, index) {
  //             return Card(
  //               child: ListTile(
  //                 title: Row(
  //                   children: <Widget>[
  //                     Expanded(
  //                       child: Text(phoneNumbers![index],
  //                           style: TextStyle(fontWeight: FontWeight.bold)),
  //                     ),
  //                     TextButton(
  //                       child: Text('Yes', style: TextStyle(fontSize: 10)),
  //                       style: TextButton.styleFrom(
  //                         backgroundColor: Colors.green,
  //                         minimumSize: Size(22, 10), // Set the minimum size
  //                       ),
  //                       onPressed: () async {
  //                         await deletePhoneNumber(phoneNumbers![index]);
  //                         print(
  //                             'Phone number ${phoneNumbers![index]} deleted.');
  //                         setState(() {
  //                           phoneNumbers!.removeAt(index);
  //                         });
  //                         _getPhoneNumbers();
  //                       },
  //                     ),
  //                     SizedBox(width: 10), // Add some spacing
  //                     TextButton(
  //                       child: Text('No', style: TextStyle(fontSize: 10)),
  //                       style: TextButton.styleFrom(
  //                         backgroundColor: Colors.red,
  //                         minimumSize: Size(22, 10), // Set the minimum size
  //                       ),
  //                       onPressed: () async {
  //                         await deletePhoneNumber(phoneNumbers![index]);
  //                         print(
  //                             'Phone number ${phoneNumbers![index]} deleted.');
  //                         setState(() {
  //                           phoneNumbers!.removeAt(index);
  //                         });
  //                         _getPhoneNumbers();
  //                       },
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             );
  //           },
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text('CLEAR'),
  //             onPressed: () async {
  //               await clearPhoneNumbers();
  //               print('Phone numbers cleared.');
  //               setState(() {
  //                 phoneNumbers!.clear();
  //               });
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: Text('CANCEL'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  //milgaya
  _showPhoneNumbersDialog() async{
    String propertyValue = await sharedPrefsHelper.getProperties() ?? '';
    if(propertyValue=="Yes"){
    showDialog(
      context: context,
      builder: (context) {
        return Container(
          child: AlertDialog(
            backgroundColor: Color.fromARGB(255, 232, 232, 232),
            title: Text('ADD LEAD FOM CALLS'),
            content: ValueListenableBuilder<List<String>?>(
              valueListenable: phoneNumbersNotifier,
              builder: (context, phoneNumbers, child) {
                return Container(
                  height: MediaQuery.of(context).size.height*0.4,
                  width: 60,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: phoneNumbers!.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: InkWell(
                          splashColor: Colors.blueAccent,
                          onTap: () {
                          
                          },
                          child: ListTile(
                            
                            title: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    phoneNumbers[index].contains('+')?   phoneNumbers[index].substring(1):   phoneNumbers[index],
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: 1),
                                InkWell(
                                  onTap: () async {
                                    try{
                                    print('postlead is called');
                                    print(totalData.toString());
                                    await _postLead(phoneNumbers[index],totalData["${phoneNumbers[index]}"]!);
                                    
                                    await deleteData(phoneNumbers[index]); //deletePhoneNumber(phoneNumbers[index]);
                                    print(
                                        'Phone number ${phoneNumbers[index]} deleted.');
                                       await  fetchData();
                                    //_getPhoneNumbers();
                                    }catch(e){
                                      print('postlead$e');
                                    }
                                  },
                                  child: CircleAvatar(
                                    radius: 11,
                                    backgroundColor: Colors.green,
                                    child: Icon(Icons.check,
                                        color: Colors.white, size: 18),
                                  ),
                                ),
                                SizedBox(width: 5), // Add some spacing
                                InkWell(
                                  onTap: () async {
                                 
                                 await  deleteData(phoneNumbers[index]);   //await deletePhoneNumber(phoneNumbers[index]);

                                    print(
                                        'Phone number ${phoneNumbers[index]} deleted.');
                                        await fetchData();
                                  //  _getPhoneNumbers();
                                  },
                                  child: CircleAvatar(
                                    radius: 11,
                                    backgroundColor: Colors.red,
                                    child: Icon(Icons.clear,
                                        color: Colors.white, size: 18),
                                  ),
                                ),
                                SizedBox(width: 4,),
                                   InkWell(
                                  onTap: () async {
                                    Navigator.push(
                              context,
                              MaterialPageRoute(
                                
                                builder: (context) => LeadDetails(
                                  openAssignTagsDialog: (empty) {
                                    print("empty");
                                  },
                                  frominitallist: true,
                                  leadController: leadController,
                                  isNewleadd: true,
                                   lead: Lead(mobileNumber: phoneNumbers[index]),
                                   frominitallistcallback:(String k)async{
deleteData(phoneNumbers[index]); 
    // await deletePhoneNumber(k);
        print(
                                        'Phone number ${phoneNumbers[index]} deleted.');
                                        await fetchData();
                                  //  _getPhoneNumbers();
                                   },
                                  //     .leads![0] //remove lead it is not necessary
                                ),
                              ),
                            );
                            

                                  },
                                  
                                  child: CircleAvatar(
                                    radius: 11,
                                    backgroundColor: Colors.blue,
                                    child: Icon(Icons.edit,
                                        color: Colors.white, size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            actions: <Widget>[
              TextButton(
                child: Text('SAVE ALL'),
                onPressed: () async {
                  for (var phoneNumber in phoneNumbersNotifier.value!) {
                    await _postLead(phoneNumber,totalData["$phoneNumber"]!);
                  }
                  print('All phone numbers saved.');
                  await clearData();
                  print('Phone numbers cleared.');
                 await fetchData();
                  Navigator.of(context).pop();
                  await leadController.loadData(forcedReload: true);
                },
              ),
              TextButton(
                child: Text('CLEAR'),
                onPressed: () async {
                  await clearData();
                  print('Phone numbers cleared.');
                  fetchData();
                  Navigator.of(context).pop();
                  await leadController.loadData(forcedReload: true);
                  print("loda data iscalled");
                },
              ),
              TextButton(
                child: Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }}
  @override
  void dispose() {
      WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }
setdata()async{
   // await PhoneStateBackground.initialize(phoneStateBackgroundCallbackHandler);
   
     
}

  @override
  void initState() {
    super.initState();
    setdata();
     WidgetsBinding.instance?.addObserver(this);
    print("from home");
    fetchData().then((_) {
      if (phoneNumbersNotifier.value != null &&
          phoneNumbersNotifier.value!.isNotEmpty) {
        _showPhoneNumbersDialog();
      }
    
    });

    final LeadController leadController = LeadController();
    platform.invokeMethod('checkCallLogPermission');
    // platform2.invokeMethod('checkLocationPermission');
    print("invoked checkCallLogPermission ");
    response = sharedPrefsHelper.getResponse();
    clientGroupName = sharedPrefsHelper.getClientGroupNameTest();
    final userselectedApplicationName =
        sharedPrefsHelper.getUserSelectedChatbot(clientGroupName);
    userId = sharedPrefsHelper.getMerchantUserId();
    clientPhoneNo = sharedPrefsHelper.getClientPhoneNoTest();
    clientName = sharedPrefsHelper.getClientNameTest();
    getLeadSaveProperty();
    sendClientGroupNameToCallLogReceiver();
    fetchApplications().then((applications) {
      if (mounted) {
        setState(() {
          _applicationNames =
              applications.map((app) => app.applicationName).toList();
          firstAppName = _applicationNames[0];
          LocalNotificationService.initializeNotifications(
              userselectedApplicationName, firstAppName);
        });
      }
    });

    Firebase.initializeApp().whenComplete(() {
      print("completed");
      setState(() {
        //1. This method call when your app in terminated state and you get a notification.
        FirebaseMessaging.instance.getInitialMessage().then(
          (message) {
            print("FirebaseMessaging.instance.getInitialMessage,$message");
            if (message != null) {
              print("New Notification");
              var mobile = message.data['title'];
              //var mobile = message.data['destination_id'];
              if (mobile != null) {
                // Get.to(() => ChatDetailsScreen(
                //     firstAppName: userselectedApplicationName ?? firstAppName,
                //     isOther: false,
                //     isFromLeadsScreen: false,
                //     chatModel:
                //         ChatModel(customerNo: message.notification?.title),
                //     leadController: leadController,
                //     isFromNotification: true));
              }
            }
          },
        );
        //2. This method only calls when app in foreground Open State
        FirebaseMessaging.onMessage.listen((message) {
          print(
              "Notification - 2. Foreground Method Called. ${message.data}${message.notification?.body},${message.notification?.title},jdsbh");
          // if (message.data['destination_id'] != null) {
          if (message.notification?.title != null) {
            print("Notification - Message Details - ${message.data['title']}");
            LocalNotificationService.createAndDisplayNotification(message);
            if (message.data['context'] == "user_accepted_request") {
              ChatController().loadData(forcedReload: true);
            }
          }
        });

        //3.  This method only calls when app in Background or Recent Stack
        FirebaseMessaging.onMessageOpenedApp.listen((message) {
          print("Notification - 3. Background Method Called.");
          // if (message.data['destination_id'] != null) {
          if (message.notification?.title != null) {
            print("Notification - Message Details - ${message.data['title']}");
            // LocalNotificationService.createAndDisplayNotification(message);

        //     Get.to(() => ChatDetailsScreen(
        //         firstAppName: userselectedApplicationName ?? firstAppName,
        //         isOther: false,
        //         isFromLeadsScreen: false,
        //         chatModel: ChatModel(customerNo: message.notification?.title),
        //         leadController: leadController,
        //         isFromNotification: true));
         }
       });
      });
    });
   // Get.put(ChatDetailsController(context));
    
    
  //  _channel.setMethodCallHandler((call) async {
  //       print("the method handler called");
  //     switch (call.method) {
      
  //       case 'onDataReceived':
  //         String receivedData = call.arguments;
  //         // Handle the received data in your Flutter code
  //         print('Received data from Android: $receivedData');
  //         Map<String,dynamic> data=jsonDecode(receivedData);
  //            // Find the ChatModel object with the matching customerNo
  //            print("local notic 1");
  //             final state = WidgetsBinding.instance!.lifecycleState;
  //            if (state == AppLifecycleState.paused) {
  //             print("state is paused starting notification");
  //                       LocalNotificationService.createAndDisplayNotification(RemoteMessage(notification: RemoteNotification(title: data["app_name"].toString(),body:data[ "message"].toString())));}}});

    
  }
//  Future<void> _defaultData(String? userselectedApplicationName) async {
//     try {
//       print("before defailtapp");
//       final defaultApp = await defaultData();
//       print("after defailtapp");
//       setState(() {
//         print("in setstate defailtapp");
//         _selectedApplicationName =
//             userselectedApplicationName ?? defaultApp!['applicationName'];
//         print("${defaultApp!['applicationName']}");
//       });
//     } catch (e) {
//       // Handle the error here
//       print(e);
//       // _selectedApplicationName = firstAppName;
//     }
//   }

  @override
  Widget build(BuildContext context) {
    var data = jsonDecode(response ?? "{}");

    Map<String, List<String>> clientGroupFeatures = {};
    print(" first time $data");
    for (var merchant in data['merchants']) {
      String clientGroupName = merchant['clientGroupName'];
      if (!clientGroupFeatures.containsKey(clientGroupName)) {
        clientGroupFeatures[clientGroupName] = [];
      }
      for (var feature in merchant['user']['role']['features']) {
        clientGroupFeatures[clientGroupName]?.add(feature['name']);
      }
    }
    Map<String, Widget> featureScreens = {
      'CustomerRolesManagement': LeadScreen(firstAppName: firstAppName),
      // 'Communications': LiveAgentScreen(
      //     applicationNames: _applicationNames, firstAppName: firstAppName),
      'Customers': CustomersScreen(),
      'SKUs': CatalogueScreen(),
      'Orders': OrderScreen(),
      //@marketing
      'Marketing': MarketingScreen(),
       'Profile': ProfileScreen(),
    };
    List<Widget> screens = [];

    for (var entry in featureScreens.entries) {
      if (
        entry.key == 'Profile' ||
          entry.key == 'Marketing' ||
          (clientGroupFeatures[clientGroupName]?.contains(entry.key) ??
              false)) {
        screens.add(entry.value);
      }
    }

    print("screens are are $SaveLeadFromCalls t");
    return Scaffold(
//      floatingActionButton: IconButton(icon: Icon(Icons.abc),onPressed: ()async{
    
//       try{
// await _channel.invokeMethod("test");}catch(e){
//   print(e);
// }
// },),
      appBar: SnapPeUI().appBarSmall(),
      endDrawer: CustomDrawer(context: context),
      body: screens[_screenIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white, currentIndex: _screenIndex,
          unselectedItemColor: Colors.grey,
          selectedItemColor: kPrimaryColor,
          selectedFontSize: kMediumFontSize,
          // iconSize: 28,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.shifting,

          selectedLabelStyle: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          // unselectedLabelStyle: TextStyle(
          //   fontFamily: 'OpenSans',
          //   fontSize: 12,
          //   fontWeight: FontWeight.normal,
          // ),
          onTap: (value) => {
            setState(() {
              _screenIndex = value;
            })
          },
          items: SnapPeUI()
              .customButtomNavigation2(clientGroupFeatures, clientGroupName),
        ),
      ),
    
    );

    // WillPopScope(
    //   child:
    //   onWillPop: () async {
    //     exit(0);
    //   },
    // );
  }

  // getClientGroupName() async {
  //   clientGroupName = await SharedPrefsHelper().getClientGroupName();
  //   print("from function $clientGroupName");
  //   setState(() {}); // rebuild widget after getting clientGroupName
  // }


Future<void> getLeadSaveProperty() async {
  SharedPrefsHelper sharedPrefsHelper = SharedPrefsHelper();
  String propertyValue = await sharedPrefsHelper.getProperties() ?? '';
  String clientName=await sharedPrefsHelper.getClientName()??"";
  String clientphno=await sharedPrefsHelper.getClientPhoneNo()??"";
  print("called and $propertyValue");
  if (propertyValue == "Yes") {
    SnapPeUI().sendSwitchValue(true);
  } else {
    SnapPeUI().sendSwitchValue(false);
  }
}

_postLead(String? phoneNumber,List<Map<String,dynamic>> data) async {
print('inpostlead');
int leadid=0;
  var clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
  var uri = Uri.parse(
      "https://retail.snap.pe/snappe-services/rest/v1/merchants/$clientGroupName/lead");
  var request = http.Request('POST', uri);
  request.headers['Content-Type'] = 'application/json';
  Map<String, dynamic> lead = {
    "mobileNumber": phoneNumber,
    "leadSource": {
      "status": "OK",
      "messages": [],
      "id": 26,
      "sourceName": "Phone Call"
    }
  };
  request.body = jsonEncode(lead);
  print("request ${phoneNumber} \n\\n\n\n\\nn\\n\n/n/n");
  var response = await NetworkHelper()
      .request(RequestType.post, uri, requestBody: request.body);
  if (response != null && response.statusCode == 200) {
    var responseJson = jsonDecode(response.body);
    leadid=responseJson["id"];

    // handle response
    print("this is reponseJson $responseJson");
    print(data);
    try{
    for(int i=0;i<data.length;i++){

      await postCallLog( data[i]["timestamp"].toInt(), data[i]["duration"].toInt(), leadid,data[i]["callType"]??"",data[i]["number"]??"", clientPhoneNo??"", clientName??"");
    }
    } catch (e) {
    print("Error in post calllog fromlead: $e");
  }
  } else {
    print("$request");
    throw Exception('Failed to post lead');
  }
}

Future<void> postCallLog(  int callTime, int callDuration, int leadId, String callStatus, String phoneNumber, String clientPhoneNo, String clientName) async {
  try {
   
    print("inpostcalllog////////");
    DateTime startTime = DateTime.fromMillisecondsSinceEpoch(callTime,isUtc: true);
    DateTime endTime = DateTime.fromMillisecondsSinceEpoch(callTime + Duration(seconds: callDuration).inMilliseconds,isUtc: true);

    final formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
    
    final formattedStartTime = formatter.format(startTime);
    final formattedEndTime = formatter.format(endTime);

    final mediaType = "application/json";
    final requestBodyMap = {
      "status": "OK",
      "isActive": true,
      "startTime": startTime.toIso8601String()??"",
      "endTime": endTime.toIso8601String(),
      "leadId": leadId,
      "callType": "call",
      "statusName": capitalize(callStatus),
      "fromNumber": clientPhoneNo,
     
      "toNumber":  phoneNumber,
      "remarks": "",
      "agentPhoneNumber": clientPhoneNo,
      "agentName": clientName,
    };

  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";

    final response = await NetworkHelper().request(
      RequestType.post,
      Uri.parse(
            
"https://retail.snap.pe/snappe-services/rest/v1/merchants/$clientGroupName/call-logs"  ),
      requestBody: jsonEncode( requestBodyMap),
    );

    if (response!.statusCode == 200) {
      print("Second API call succeeded");

    } else {
      print("Second API call failed with status code: ${response.statusCode}");
    }
  } catch (e) {
    print("Error in postCallLog: $e");
  }
}
Future<void> fetchData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
     Map<String, dynamic> l = {};
  // Check if 'storelocalnotlead' key exists in SharedPreferences
  if (prefs.containsKey('storelocalnotlead')) {
    // If the key exists, get the stored string and decode it as JSON
    String jsonString = prefs.getString('storelocalnotlead')??"";
    Map<String, dynamic> l = jsonDecode(jsonString);
    // Now 'l' contains the decoded JSON object
setState(() {
    phoneNumbersNotifier.value = l.keys.toList();
    totalData=castToDesiredType(jsonDecode(jsonString));
});
 print('total data'+totalData.toString());
  } else {
    // If return the key doesn't exist, set 'l' to an empty Map
 
    print('No data found.');

  }
}

// Future<void> postCallLog(  int callTime, int callDuration, int leadId, String callStatus, String phoneNumber, String clientPhoneNo, String clientName) async {
//   try {
   
//     print("inpostcalllog////////");
//     DateTime startTime = DateTime.fromMillisecondsSinceEpoch(callTime,isUtc: true);
//     DateTime endTime = DateTime.fromMillisecondsSinceEpoch(callTime + Duration(seconds: callDuration).inMilliseconds,isUtc: true);

//     final formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
    
//     final formattedStartTime = formatter.format(startTime);
//     final formattedEndTime = formatter.format(endTime);

//     final mediaType = "application/json";
//     final requestBodyMap = {
//       "status": "OK",
//       "isActive": true,
//       "startTime": formattedStartTime??"",
//       "endTime": formattedEndTime,
//       "leadId": leadId,
//       "callType": "call",
//       "statusName": callStatus.toUpperCase(),
//       "fromNumber": clientPhoneNo,
     
//       "toNumber":  phoneNumber,
//       "remarks": "",
//       "agentPhoneNumber": clientPhoneNo,
//       "agentName": clientName,
//     };

//   String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";

//     final response = await NetworkHelper().request(
//       RequestType.post,
//       Uri.parse(
            
// "https://retail.snap.pe/snappe-services/rest/v1/merchants/$clientGroupName/call-logs"  ),
//       requestBody: jsonEncode( requestBodyMap),
//     );

//     if (response!.statusCode == 200) {
//       print("Second API call succeeded");

//     } else {
//       print("Second API call failed with status code: ${response.statusCode}");
//     }
//   } catch (e) {
//     print("Error in postCallLog: $e");
//   }
// }
// Future<void> fetchData() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//      Map<String, dynamic> l = {};
//   // Check if 'storelocalnotlead' key exists in SharedPreferences
//   if (prefs.containsKey('storelocalnotlead')) {
//     // If the key exists, get the stored string and decode it as JSON
//     String jsonString = prefs.getString('storelocalnotlead')??"";
//     Map<String, dynamic> l = jsonDecode(jsonString);
//     // Now 'l' contains the decoded JSON object

//    phoneNumbersNotifier.value = l.keys.toList();
//   } else {
//     // If return the key doesn't exist, set 'l' to an empty Map
 
//     print('No data found.');

//   }
// }

Future<void> deleteData(String k) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Map<String, dynamic> l = {};
  // Check if 'storelocalnotlead' key exists in SharedPreferences
  if (prefs.containsKey('storelocalnotlead')) {
    // If the key exists, get the stored string and decode it as JSON
    String jsonString = prefs.getString('storelocalnotlead') ?? "";
    l = jsonDecode(jsonString);
    // Now 'l' contains the decoded JSON object
    l.containsKey(k)?l.remove(k):null;
     prefs.setString('storelocalnotlead',jsonEncode(l));
  } else {
    // If the key doesn't exist, set 'l' to an empty Map
    print('No data found.');
    
  }
}
Future<void> clearData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Map<String, dynamic> l = {};
  if (prefs.containsKey('storelocalnotlead')) {
  
    prefs.setString('storelocalnotlead',jsonEncode(l)) ;

  } else {
  
    print('No data found.');
    
  }
}
}






























// Future<Map<String,dynamic>?> fetchLatestCallLog() async {
//   Iterable<CallLogEntry> entries = await CallLog.get();
//   if (entries.isNotEmpty) {
//     // Get the most recent call log entry
//     CallLogEntry latestEntry = entries.first;
//        print('Latest Call Log - Name: ${latestEntry.name}, Number: ${latestEntry.number}');
//     return latestEntry.toMap();
 
//     // You can access other properties like duration, call type, etc.
//   } else {
//     print('No call logs found.');
//   }
// }
//   @pragma('vm:entry-point')
//   Future<void> phoneStateBackgroundCallbackHandler(
//     PhoneStateBackgroundEvent event,
//     String number,
//     int duration,
//   ) async {
//     switch (event) {
//       case PhoneStateBackgroundEvent.incomingstart:
//         print('!!!Incoming call start, number: $number, duration: $duration s');
//         break;
//       case PhoneStateBackgroundEvent.incomingmissed:
//         print('!!!Incoming call missed, number: $number, duration: $duration s');
//         break;
//       case PhoneStateBackgroundEvent.incomingreceived:
//         print('!!!Incoming call received, number: $number, duration: $duration s');
//         break;
//       case PhoneStateBackgroundEvent.incomingend:
//         print('!!!Incoming call ended, number: $number, duration $duration s');
//         var k= await fetchLatestCallLog();
//        if(k!=null){
//         CallLogHelper.postCallsToFirstApi(k);
//        }
//         break;
//       case PhoneStateBackgroundEvent.outgoingstart:
//         print('!!!Outgoing call start, number: $number, duration: $duration s');
        
//         break;
//       case PhoneStateBackgroundEvent.outgoingend:
//         print('Outgoing call ended, number: $number, duration: $duration s');
//        var k= await fetchLatestCallLog();
//        if(k!=null){
//         CallLogHelper.postCallsToFirstApi(k);
//        }
//         //Map<String,dynamic> k={"mobileNumber":number,"duration":duration};
    
//       //  CallLogHelper.postCallsToFirstApi(k);
//         break;
//     }
//   }
// class Home extends StatefulWidget {
//   @override
//   _HomeState createState() => _HomeState();
// }

// class _HomeState extends State<Home> with WidgetsBindingObserver  {
//   int _screenIndex = 0;
//   List<String>? phoneNumbers;
//  Map<String, List<Map<String, dynamic>>> totalData={};
//   SharedPrefsHelper sharedPrefsHelper = SharedPrefsHelper();
//   String? SaveLeadFromCalls;
//   String? clientGroupName;
//   String? clientPhoneNo;
//   String? clientName;
//   String? response;
//   String removenumber="";
//   // String? _selectedApplicationName;
//   List<String?> _applicationNames = [];
//   String? firstAppName;
//   String? userId;
//   static const platform = const MethodChannel('com.example.myapp/callLog');
//   final phoneNumbersNotifier = ValueNotifier<List<String>?>(null);
//   final LeadController leadController = LeadController();
//   int pausedtime=0;
//   // static const platform2 =
//   //     MethodChannel('com.example.myapp/locationPermission');


//     @override
//   void didChangeAppLifecycleState(AppLifecycleState state) async{
//     super.didChangeAppLifecycleState(state);
//     // If the app is paused or inactive, cancel any active toast messages

// if(state==AppLifecycleState.paused){
//   print("paused........");
//   setState(() {
//       pausedtime=DateTime.now().millisecondsSinceEpoch;
//   });

// }
//   if (state == AppLifecycleState.resumed) {
//     print("stateresumed''''''''''''''''''''''''''");
//     int pausedseconds=((DateTime.now().millisecondsSinceEpoch-pausedtime)/1000).toInt();
//       print("pasuedseconds$pausedtime");
//     print("pasuedseconds$pausedseconds");
//     if(pausedtime==0 || pausedseconds>10)
  
//      _getPhoneNumbers().then((_) {
//       if (phoneNumbersNotifier.value != null &&
//           phoneNumbersNotifier.value!.isNotEmpty) {
//         _showPhoneNumbersDialog();
//       }
//     });
  
//     }
//   }
//   Map<String, List<Map<String, dynamic>>> castToDesiredType(dynamic jsonData) {
//   try {
//     Map<String, List<Map<String, dynamic>>> result = {};
//     if (jsonData is Map<String, dynamic>) {
//       jsonData.forEach((key, value) {
//         if (value is List) {
//           List<Map<String, dynamic>> listValue = [];
//           for (var item in value) {
//             if (item is Map<String, dynamic>) {
//               listValue.add(Map<String, dynamic>.from(item));
//             }
//           }
//           result[key] = listValue;
//         }
//       });
//     }
//     return result;
//   } catch (e) {
//     print('Error casting to desired type: $e');
//     // Return an empty map or handle the error as needed
//     return {};
//   }
// }

//   void sendClientGroupNameToCallLogReceiver() {
//     try {
//       print("$clientGroupName sent to background ");
//       platform.invokeMethod('sendClientGroupName', {
//         'clientGroupName': clientGroupName,
//         "clientPhoneNo": clientPhoneNo,
//         "clientName": clientName,
//         "userId": userId
//       });
//       print(
//           "$userId and $clientGroupName sent. to background \n\nn\nn\nn\nn\nnn\n\n\n\n\n\n\n\nnn\n\n\n\ ");
//     } on PlatformException catch (e) {
//       print("Failed to send clientGroupName: '${e.message}'.");
//     }
//   }

//   clearPhoneNumbers() async {
//     const platform = MethodChannel('com.example.myapp/callLog');
//     try {
//       await platform.invokeMethod('clearPhoneNumbers');
//       print('Phone numbers cleared.');
//     } on PlatformException catch (e) {
//       print("Failed to clear phone numbers: '${e.message}'.");
//     }
//   }
// void _hidePhoneNumbersDialog() {
//   if (Navigator.of(context).canPop()) {
//     Navigator.of(context).pop();
//   }
// }
//   deletePhoneNumber(String phoneNumber) async {
//     const platform = MethodChannel('com.example.myapp/callLog');
//     try {
//       print("fromdeletephonenumber");
//       await platform
//           .invokeMethod('deletePhoneNumber', {'phoneNumber': phoneNumber});
//       print('Phone number $phoneNumber deleted.');
//       _getPhoneNumbers(); 
//       // if (phoneNumbersNotifier.value == null &&
//       //     phoneNumbersNotifier.value!.isEmpty) {
//       // _hidePhoneNumbersDialog();
//       // }

//     } on PlatformException catch (e) {
//       print("Failed to delete phone number: '${e.message}'.");
//     }
//   }

//   _getPhoneNumbers() async {
//     try {
//       final String? phoneNumbersJson =
//           await platform.invokeMethod('getPhoneNumbers');
//       if (phoneNumbersJson != null) {
//         print("before phnumber notifier");
//         print(jsonDecode(phoneNumbersJson).keys.runtimeType);
//         print(json.decode(phoneNumbersJson).keys.toList());
//         var v=json.decode(phoneNumbersJson).keys.toList();
//         List<String> k=[];
//         setState(() {
//             try{
//           totalData=castToDesiredType( json.decode(phoneNumbersJson));
//                  } catch (e) {
//     print('Error in _getPhoneNumbers: $e');
//   }
//         });
//         print(totalData.toString());
//         for(int i=0;i<v.length;i++){
// k.add("${v[i]}");
//         }
      
//         phoneNumbersNotifier.value = k;
      
//         print('Phone numbers in local storage: ${phoneNumbersNotifier.value}');
//           if (phoneNumbersNotifier.value?.isEmpty ?? false) {
//         _hidePhoneNumbersDialog();
//       } 
//       } else {
//         print('Phone numbers list is null');
//       }
//     } on PlatformException catch (e) {
//       print("Failed to get phone numbers: '${e.message}'.");
//     }
//   }

//   // _getPhoneNumbers() async {
//   //   try {
//   //     final String? phoneNumbersJson =
//   //         await platform.invokeMethod('getPhoneNumbers');
//   //     if (phoneNumbersJson != null) {
//   //       phoneNumbers = (json.decode(phoneNumbersJson) as List)
//   //           .map((item) => item as String)
//   //           .toList();
//   //       if (phoneNumbers!.isNotEmpty) {
//   //         print('Phone numbers in local storage: $phoneNumbers 2');
//   //         _showPhoneNumbersDialog();
//   //       }
//   //       print('Phone numbers in local storage: $phoneNumbers');
//   //     } else {
//   //       print('Phone numbers list is null');
//   //     }
//   //   } on PlatformException catch (e) {
//   //     print("Failed to get phone numbers: '${e.message}'.");
//   //   }
//   // }

//   // _showPhoneNumbersDialog() {
//   //   showDialog(
//   //     context: context,
//   //     builder: (context) {
//   //       return AlertDialog(
//   //         title: Text('ADD LEAD FOM CALLS'),
//   //         content: ListView.builder(
//   //           itemCount: phoneNumbers!.length,
//   //           itemBuilder: (context, index) {
//   //             return Card(
//   //               child: ListTile(
//   //                 title: Row(
//   //                   children: <Widget>[
//   //                     Expanded(
//   //                       child: Text(phoneNumbers![index],
//   //                           style: TextStyle(fontWeight: FontWeight.bold)),
//   //                     ),
//   //                     TextButton(
//   //                       child: Text('Yes', style: TextStyle(fontSize: 10)),
//   //                       style: TextButton.styleFrom(
//   //                         backgroundColor: Colors.green,
//   //                         minimumSize: Size(22, 10), // Set the minimum size
//   //                       ),
//   //                       onPressed: () async {
//   //                         await deletePhoneNumber(phoneNumbers![index]);
//   //                         print(
//   //                             'Phone number ${phoneNumbers![index]} deleted.');
//   //                         setState(() {
//   //                           phoneNumbers!.removeAt(index);
//   //                         });
//   //                         _getPhoneNumbers();
//   //                       },
//   //                     ),
//   //                     SizedBox(width: 10), // Add some spacing
//   //                     TextButton(
//   //                       child: Text('No', style: TextStyle(fontSize: 10)),
//   //                       style: TextButton.styleFrom(
//   //                         backgroundColor: Colors.red,
//   //                         minimumSize: Size(22, 10), // Set the minimum size
//   //                       ),
//   //                       onPressed: () async {
//   //                         await deletePhoneNumber(phoneNumbers![index]);
//   //                         print(
//   //                             'Phone number ${phoneNumbers![index]} deleted.');
//   //                         setState(() {
//   //                           phoneNumbers!.removeAt(index);
//   //                         });
//   //                         _getPhoneNumbers();
//   //                       },
//   //                     ),
//   //                   ],
//   //                 ),
//   //               ),
//   //             );
//   //           },
//   //         ),
//   //         actions: <Widget>[
//   //           TextButton(
//   //             child: Text('CLEAR'),
//   //             onPressed: () async {
//   //               await clearPhoneNumbers();
//   //               print('Phone numbers cleared.');
//   //               setState(() {
//   //                 phoneNumbers!.clear();
//   //               });
//   //               Navigator.of(context).pop();
//   //             },
//   //           ),
//   //           TextButton(
//   //             child: Text('CANCEL'),
//   //             onPressed: () {
//   //               Navigator.of(context).pop();
//   //             },
//   //           ),
//   //         ],
//   //       );
//   //     },
//   //   );
//   // }
//   //milgaya
//   _showPhoneNumbersDialog() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return Container(
//           child: AlertDialog(
//             backgroundColor: Color.fromARGB(255, 232, 232, 232),
//             title: Text('ADD LEAD FOM CALLS'),
//             content: ValueListenableBuilder<List<String>?>(
//               valueListenable: phoneNumbersNotifier,
//               builder: (context, phoneNumbers, child) {
//                 return Container(
//                   height: MediaQuery.of(context).size.height*0.4,
//                   width: 60,
//                   child: ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: phoneNumbers!.length,
//                     itemBuilder: (context, index) {
//                       return Card(
//                         child: InkWell(
//                           splashColor: Colors.blueAccent,
//                           onTap: () {
                          
//                           },
//                           child: ListTile(
                            
//                             title: Row(
//                               children: <Widget>[
//                                 Expanded(
//                                   child: Text(
//                                     phoneNumbers[index],
//                                     style: TextStyle(fontWeight: FontWeight.bold),
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                                 SizedBox(width: 1),
//                                 InkWell(
//                                   onTap: () async {
//                                     await _postLead(phoneNumbers[index],totalData["${phoneNumbers[index]}"]!);
//                                     await deletePhoneNumber(phoneNumbers[index]);
//                                     print(
//                                         'Phone number ${phoneNumbers[index]} deleted.');
//                                     _getPhoneNumbers();
//                                   },
//                                   child: CircleAvatar(
//                                     radius: 11,
//                                     backgroundColor: Colors.green,
//                                     child: Icon(Icons.check,
//                                         color: Colors.white, size: 18),
//                                   ),
//                                 ),
//                                 SizedBox(width: 5), // Add some spacing
//                                 InkWell(
//                                   onTap: () async {
//                                     await deletePhoneNumber(phoneNumbers[index]);
//                                     print(
//                                         'Phone number ${phoneNumbers[index]} deleted.');
//                                     _getPhoneNumbers();
//                                   },
//                                   child: CircleAvatar(
//                                     radius: 11,
//                                     backgroundColor: Colors.red,
//                                     child: Icon(Icons.clear,
//                                         color: Colors.white, size: 18),
//                                   ),
//                                 ),
//                                 SizedBox(width: 4,),
//                                    InkWell(
//                                   onTap: () async {
//                                     Navigator.push(
//                               context,
//                               MaterialPageRoute(
                                
//                                 builder: (context) => LeadDetails(
//                                   openAssignTagsDialog: (empty) {
//                                     print("empty");
//                                   },
//                                   frominitallist: true,
//                                   leadController: leadController,
//                                   isNewleadd: true,
//                                    lead: Lead(mobileNumber: phoneNumbers[index]),
//                                    frominitallistcallback:(String k)async{

//      await deletePhoneNumber(k);
//         print(
//                                         'Phone number ${phoneNumbers[index]} deleted.');
//                                     _getPhoneNumbers();
//                                    },
//                                   //     .leads![0] //remove lead it is not necessary
//                                 ),
//                               ),
//                             );
                            

//                                   },
                                  
//                                   child: CircleAvatar(
//                                     radius: 11,
//                                     backgroundColor: Colors.blue,
//                                     child: Icon(Icons.edit,
//                                         color: Colors.white, size: 18),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               },
//             ),
//             actions: <Widget>[
//               TextButton(
//                 child: Text('SAVE ALL'),
//                 onPressed: () async {
//                   for (var phoneNumber in phoneNumbersNotifier.value!) {
//                     await _postLead(phoneNumber,totalData["$phoneNumber"]!);
//                   }
//                   print('All phone numbers saved.');
//                   await clearPhoneNumbers();
//                   print('Phone numbers cleared.');
//                   _getPhoneNumbers();
//                   Navigator.of(context).pop();
//                   await leadController.loadData(forcedReload: true);
//                 },
//               ),
//               TextButton(
//                 child: Text('CLEAR'),
//                 onPressed: () async {
//                   await clearPhoneNumbers();
//                   print('Phone numbers cleared.');
//                   _getPhoneNumbers();
//                   Navigator.of(context).pop();
//                   await leadController.loadData(forcedReload: true);
//                   print("loda data iscalled");
//                 },
//               ),
//               TextButton(
//                 child: Text('CANCEL'),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//   @override
//   void dispose() {
//       WidgetsBinding.instance?.removeObserver(this);
//     super.dispose();
//   }
// setdata()async{
//    // await PhoneStateBackground.initialize(phoneStateBackgroundCallbackHandler);
// }
//   @override
//   void initState() {
//     super.initState();
//     setdata();
//      WidgetsBinding.instance?.addObserver(this);
//     print("from home");
//     _getPhoneNumbers().then((_) {
//       if (phoneNumbersNotifier.value != null &&
//           phoneNumbersNotifier.value!.isNotEmpty) {
//         _showPhoneNumbersDialog();
//       }
    
//     });

//     final LeadController leadController = LeadController();
//     platform.invokeMethod('checkCallLogPermission');
//     // platform2.invokeMethod('checkLocationPermission');
//     print("invoked checkCallLogPermission ");
//     response = sharedPrefsHelper.getResponse();
//     clientGroupName = sharedPrefsHelper.getClientGroupNameTest();
//     final userselectedApplicationName =
//         sharedPrefsHelper.getUserSelectedChatbot(clientGroupName);
//     userId = sharedPrefsHelper.getMerchantUserId();
//     clientPhoneNo = sharedPrefsHelper.getClientPhoneNoTest();
//     clientName = sharedPrefsHelper.getClientNameTest();
//     getLeadSaveProperty();
//     sendClientGroupNameToCallLogReceiver();
//     fetchApplications().then((applications) {
//       if (mounted) {
//         setState(() {
//           _applicationNames =
//               applications.map((app) => app.applicationName).toList();
//           firstAppName = _applicationNames[0];
//           LocalNotificationService.initializeNotifications(
//               userselectedApplicationName, firstAppName);
//         });
//       }
//     });

//     Firebase.initializeApp().whenComplete(() {
//       print("completed");
//       setState(() {
//         //1. This method call when your app in terminated state and you get a notification.
//         FirebaseMessaging.instance.getInitialMessage().then(
//           (message) {
//             print("FirebaseMessaging.instance.getInitialMessage,$message");
//             if (message != null) {
//               print("New Notification");
//               var mobile = message.data['title'];
//               //var mobile = message.data['destination_id'];
//               if (mobile != null) {
//                 Get.to(() => ChatDetailsScreen(
//                     firstAppName: userselectedApplicationName ?? firstAppName,
//                     isOther: false,
//                     isFromLeadsScreen: false,
//                     chatModel:
//                         ChatModel(customerNo: message.notification?.title),
//                     leadController: leadController,
//                     isFromNotification: true));
//               }
//             }
//           },
//         );
//         //2. This method only calls when app in foreground Open State
//         FirebaseMessaging.onMessage.listen((message) {
//           print(
//               "Notification - 2. Foreground Method Called. ${message.data}${message.notification?.body},${message.notification?.title},jdsbh");
//           // if (message.data['destination_id'] != null) {
//           if (message.notification?.title != null) {
//             print("Notification - Message Details - ${message.data['title']}");
//             LocalNotificationService.createAndDisplayNotification(message);
//             if (message.data['context'] == "user_accepted_request") {
//               ChatController().loadData();
//             }
//           }
//         });

//         //3.  This method only calls when app in Background or Recent Stack
//         FirebaseMessaging.onMessageOpenedApp.listen((message) {
//           print("Notification - 3. Background Method Called.");
//           // if (message.data['destination_id'] != null) {
//           if (message.notification?.title != null) {
//             print("Notification - Message Details - ${message.data['title']}");
//             // LocalNotificationService.createAndDisplayNotification(message);

//             Get.to(() => ChatDetailsScreen(
//                 firstAppName: userselectedApplicationName ?? firstAppName,
//                 isOther: false,
//                 isFromLeadsScreen: false,
//                 chatModel: ChatModel(customerNo: message.notification?.title),
//                 leadController: leadController,
//                 isFromNotification: true));
//           }
//         });
//       });
//     });
//   }
// //  Future<void> _defaultData(String? userselectedApplicationName) async {
// //     try {
// //       print("before defailtapp");
// //       final defaultApp = await defaultData();
// //       print("after defailtapp");
// //       setState(() {
// //         print("in setstate defailtapp");
// //         _selectedApplicationName =
// //             userselectedApplicationName ?? defaultApp!['applicationName'];
// //         print("${defaultApp!['applicationName']}");
// //       });
// //     } catch (e) {
// //       // Handle the error here
// //       print(e);
// //       // _selectedApplicationName = firstAppName;
// //     }
// //   }

//   @override
//   Widget build(BuildContext context) {
//     var data = jsonDecode(response ?? "{}");

//     Map<String, List<String>> clientGroupFeatures = {};
//     print(" first time $data");
//     for (var merchant in data['merchants']) {
//       String clientGroupName = merchant['clientGroupName'];
//       if (!clientGroupFeatures.containsKey(clientGroupName)) {
//         clientGroupFeatures[clientGroupName] = [];
//       }
//       for (var feature in merchant['user']['role']['features']) {
//         clientGroupFeatures[clientGroupName]?.add(feature['name']);
//       }
//     }
//     Map<String, Widget> featureScreens = {
//       'CustomerRolesManagement': LeadScreen(firstAppName: firstAppName),
//       'Communications': LiveAgentScreen(
//           applicationNames: _applicationNames, firstAppName: firstAppName),
//       'Customers': CustomersScreen(),
//       'SKUs': CatalogueScreen(),
//       'Orders': OrderScreen(),
//       'Marketing': MarketingScreen(),
//        'Profile': ProfileScreen(),
//     };
//     List<Widget> screens = [];

//     for (var entry in featureScreens.entries) {
//       if (
//         entry.key == 'Profile' ||
//           entry.key == 'Marketing' ||
//           (clientGroupFeatures[clientGroupName]?.contains(entry.key) ??
//               false)) {
//         screens.add(entry.value);
//       }
//     }

//     print("screens are are $SaveLeadFromCalls t");
//     return Scaffold(
//      floatingActionButton: IconButton(icon: Icon(Icons.abc),onPressed: ()async{
//        Iterable<CallLogEntry> k=await CallLog.query(dateFrom: 1711120254674,dateTo: DateTime.now().millisecondsSinceEpoch);
//     var z=  k.map((e)=>e.toMap()).toList();
//       print(


//      z
     
//      );},),
//       appBar: SnapPeUI().appBarSmall(),
//       endDrawer: CustomDrawer(context: context),
//       body: screens[_screenIndex],
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.2),
//               blurRadius: 5,
//               offset: Offset(0, -3),
//             ),
//           ],
//         ),
//         child: BottomNavigationBar(
//           backgroundColor: Colors.white, currentIndex: _screenIndex,
//           unselectedItemColor: Colors.grey,
//           selectedItemColor: kPrimaryColor,
//           selectedFontSize: kMediumFontSize,
//           // iconSize: 28,
//           showUnselectedLabels: true,
//           type: BottomNavigationBarType.shifting,

//           selectedLabelStyle: TextStyle(
//             fontFamily: 'OpenSans',
//             fontSize: 14,
//             fontWeight: FontWeight.bold,
//           ),
//           // unselectedLabelStyle: TextStyle(
//           //   fontFamily: 'OpenSans',
//           //   fontSize: 12,
//           //   fontWeight: FontWeight.normal,
//           // ),
//           onTap: (value) => {
//             setState(() {
//               _screenIndex = value;
//             })
//           },
//           items: SnapPeUI()
//               .customButtomNavigation2(clientGroupFeatures, clientGroupName),
//         ),
//       ),
    
//     );

//     // WillPopScope(
//     //   child:
//     //   onWillPop: () async {
//     //     exit(0);
//     //   },
//     // );
//   }

//   // getClientGroupName() async {
//   //   clientGroupName = await SharedPrefsHelper().getClientGroupName();
//   //   print("from function $clientGroupName");
//   //   setState(() {}); // rebuild widget after getting clientGroupName
//   // }


// Future<void> getLeadSaveProperty() async {
//   SharedPrefsHelper sharedPrefsHelper = SharedPrefsHelper();
//   String propertyValue = await sharedPrefsHelper.getProperties() ?? '';
//   String clientName=await sharedPrefsHelper.getClientName()??"";
//   String clientphno=await sharedPrefsHelper.getClientPhoneNo()??"";
//   print("called and $propertyValue");
//   if (propertyValue == "Yes") {
//     SnapPeUI().sendSwitchValue(true);
//   } else {
//     SnapPeUI().sendSwitchValue(false);
//   }
// }

// _postLead(String? phoneNumber,List<Map<String,dynamic>> data) async {

// int leadid=0;
//   var clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
//   var uri = Uri.parse(
//       "https://retail.snap.pe/snappe-services/rest/v1/merchants/$clientGroupName/lead");
//   var request = http.Request('POST', uri);
//   request.headers['Content-Type'] = 'application/json';
//   Map<String, dynamic> lead = {
//     "mobileNumber": phoneNumber,
//     "leadSource": {
//       "status": "OK",
//       "messages": [],
//       "id": 26,
//       "sourceName": "Phone Call"
//     }
//   };
//   request.body = jsonEncode(lead);
//   print("request ${phoneNumber} \n\\n\n\n\\nn\\n\n/n/n");
//   var response = await NetworkHelper()
//       .request(RequestType.post, uri, requestBody: request.body);
//   if (response != null && response.statusCode == 200) {
//     var responseJson = jsonDecode(response.body);
//     leadid=responseJson["id"];

//     // handle response
//     print("this is reponseJson $responseJson");
//     print(data);
//     try{
//     for(int i=0;i<data.length;i++){
//       print("callData///////////////00");
//        print("clientGroupName: $clientGroupName");
//   print("callTime: ${data[i]["callTime"]}");
//   print("callDuration: ${data[i]["callDuration"]}");
//   print("leadid: $leadid");
//   print("callStatus: ${data[i]["callStatus"]}");
//   print("phoneNumber: ${data[i]["phoneNumber"]}");
//   print("clientPhoneNo: ${clientPhoneNo ?? ""}");
//   print("clientName: ${clientName ?? ""}");
//       await postCallLog( data[i]["callTime"].toInt(), data[i]["callDuration"].toInt(), leadid,data[i]["callStatus"]??"",data[i]["phoneNumber"]??"", clientPhoneNo??"", clientName??"");
//     }
//     } catch (e) {
//     print("Error in post calllog fromlead: $e");
//   }
//   } else {
//     print("$request");
//     throw Exception('Failed to post lead');
//   }
// }



// Future<void> postCallLog(  int callTime, int callDuration, int leadId, String callStatus, String phoneNumber, String clientPhoneNo, String clientName) async {
//   try {
   
//     print("inpostcalllog////////");
//     DateTime startTime = DateTime.fromMillisecondsSinceEpoch(callTime,isUtc: true);
//     DateTime endTime = DateTime.fromMillisecondsSinceEpoch(callTime + Duration(seconds: callDuration).inMilliseconds,isUtc: true);

//     final formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
    
//     final formattedStartTime = formatter.format(startTime);
//     final formattedEndTime = formatter.format(endTime);

//     final mediaType = "application/json";
//     final requestBodyMap = {
//       "status": "OK",
//       "isActive": true,
//       "startTime": formattedStartTime??"",
//       "endTime": formattedEndTime,
//       "leadId": leadId,
//       "callType": "call",
//       "statusName": callStatus.toUpperCase(),
//       "fromNumber": clientPhoneNo,
     
//       "toNumber":  phoneNumber,
//       "remarks": "",
//       "agentPhoneNumber": clientPhoneNo,
//       "agentName": clientName,
//     };

//   String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";

//     final response = await NetworkHelper().request(
//       RequestType.post,
//       Uri.parse(
            
// "https://retail.snap.pe/snappe-services/rest/v1/merchants/$clientGroupName/call-logs"  ),
//       requestBody: jsonEncode( requestBodyMap),
//     );

//     if (response!.statusCode == 200) {
//       print("Second API call succeeded");

//     } else {
//       print("Second API call failed with status code: ${response.statusCode}");
//     }
//   } catch (e) {
//     print("Error in postCallLog: $e");
//   }
// }
// }
Future<void> initalizeservice() async {
  final service = FlutterBackgroundService();
  await service.configure(
      iosConfiguration: IosConfiguration(),
      androidConfiguration: AndroidConfiguration(
          initialNotificationContent: "Capuring Call  Logs",
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
          String resfromstorage = prefs.getString('resultlocal') ?? "";
          List<Map<String, dynamic>> u =
              (jsonDecode(resfromstorage) as List).cast<Map<String, dynamic>>();
          for (int i = 0; i < u.length; i++) {
            await CallLogHelper.postCallsToFirstApi(u[i]);
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
