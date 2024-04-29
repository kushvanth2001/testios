// import 'dart:async';

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import '../main.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'chat_controller.dart';
// import 'switch_controller.dart';
// import '../constants/networkConstants.dart';
// import '../helper/socketHelper.dart';
// import '../utils/snapPeUI.dart';
// import '../views/chat/chatControllerr.dart';
// import '../views/chat/chatEntered.dart';
// import 'package:uuid/uuid.dart';
// import '../helper/SharedPrefsHelper.dart';
// import '../helper/mqttHelper.dart';
// import '../models/model_chat.dart';
// import 'dart:convert';
// import '../helper/networkHelper.dart';
// import '../services/localNotificationService.dart';
// import '../utils/snapPeNetworks.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart'
//     as localNotif;

// class ChatDetailsController extends GetxController {
//   static  MethodChannel _channel = MethodChannel('samples.flutter.dev/mqtt');
//   static RxString overRideStatusTitle = "TakeOver".obs;
//   static RxList<Message> messageList = <Message>[].obs;
//   static RxBool emojiShowing = false.obs;
   
//   late Timer _timer;
//   final localNotif.FlutterLocalNotificationsPlugin
//       flutterLocalNotificationsPlugin =
//       localNotif.FlutterLocalNotificationsPlugin();
//   final snapPeUI = SnapPeUI();
//   String chatSessionId="${DateTime.now().millisecondsSinceEpoch}";
//   final SwitchController switchController = Get.find<SwitchController>();
//    var uuid = Uuid();
//   // String? userselectedApplicationName =
//   //     SharedPrefsHelper().getUserSelectedChatbot();
//   ChatDetailsController(
//     BuildContext context,
//   ) {
//     // this.mobile = mobile;
//     snapPeUI.init(context);
//   }
//   // Add this method to update the value of presentChatNumber
// @override
// void onInit() {
//   super.onInit();
//   print("Controller initialized");
//   setdata();
  
//   _channel.setMethodCallHandler((call) async {
//     print("Method handler called1");
//     switch (call.method) {
//       case 'onDataReceived':
//         String receivedData = call.arguments;
//         print('Received data from Android1: $receivedData');
//         try {
//           Map<String, dynamic> data = jsonDecode(receivedData);
//           if (data["type"] == "customer-chat") {
//             onReceiveMessage(data);
//                          final state = WidgetsBinding.instance!.lifecycleState;
//               if (state == AppLifecycleState.paused) {
//              print("state is paused starting notification");
//              print("chatbotname${SharedPrefsHelper().getSelectedChatBot}");
//              if(data["destination_id"]!=null){
//                          LocalNotificationService.createAndDisplayNotification(RemoteMessage(notification: RemoteNotification(title: data["app_name"].toString(),body:data[ "message"].toString())));
//              }
    
//           }
//            //  LocalNotificationService.createAndDisplayNotification(RemoteMessage(notification: RemoteNotification(title: data["app_name"].toString(),body:data[ "message"].toString())));
//           } else if (data["type"] == "delivery_event") {
//             print("Delivery event was called");
//             for (Message message in messageList) {
//               if (message.messageid == data["divigo_message_id"]) {
//                 message.status = data["status"];
//                 print("Updated message status: ${message.status}");
//                  messageList.refresh();

//                 break; // Assuming divigo_message_id is unique, stop searching
//               }
//             }
//           } else {
//             print("Unknown data type received: ${data["type"]}");
//           }
//         } catch (e) {
//           print("Error decoding JSON: $e");
//         }
//         break;
//       // Add more cases as needed
//       // ...
//     }
//   });
// }
//     @override
//   void onClose() {
//     // Cancel the timer when the controller is closed
//     _timer.cancel();
//     super.onClose();
//   }
//     void setdata() async{
// chatSessionId=await SharedPrefsHelper().getChatSessionId()??"${DateTime.now().millisecondsSinceEpoch}";

// await twominapicall();
// await MqttManager.subscribeToTopic("$chatSessionId/#");
 
//  _timer=Timer.periodic(Duration(minutes: 2), (timer) async{ 
// await MqttManager.subscribeToTopic("$chatSessionId/#");
// });

//     }
//   loadData(isFromLeadsScreen, mobile) async {
//     //Reset value
//     String? response;
//     try {
//       // overRideStatusTitle.value = "TakeOver";
//       messageList.clear();
//       response =
//           await SnapPeNetworks().getSingleChatData(mobile, isFromLeadsScreen);
//           print("print response from d2+${response}");
//       if (response != null ) {
//         List<ChatModel> chatList = chatModelFromJson(response);
//           print("print response from d3+${chatList}");
//         if (chatList.length != 0) {
//           messageList.value = List.from(chatList[0].messages!);
//           // setOverRideStatus(switchController.getSwitchValue(mobile), mobile,
//           //     isFromLeadsScreen);
//             print("print response from d4+${chatList.map((e) => e.toJson())}");
//         }
//       }
//     } catch (ex) {
//       print("error from chat d5+$ex");
//       if (response != "status") SnapPeUI().toastError();
//     }
//   }



//   Future<void> onReceiveMessage(data) async {
    
//     print("onreccive msg is called");
//     var messge = data['message']??"";
//     var destinationId = data["destination_id"]??"";
//     var appname = data["app_name"]??"";
//     String numInChatscreen = await SharedPrefsHelper().getInChatDetailsscreen();
//     print("$numInChatscreen");
//     // Update SharedPreferences
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('lastMessage_$destinationId$appname', messge);
//     int count = prefs.getInt('newMessageCount_$destinationId$appname') ?? 0;
//     print("$count");
//     await prefs.setInt('newMessageCount_$destinationId$appname', count + 1);

//     print('updateChat called for $destinationId$appname');

//     // Use Get.find() to get the correct instance of ChatController
//     final String tag = '${destinationId}_$appname';
//     print('finding ChatControllerr into Get with tag: $tag');
//     final ChatControllerr chatControllerr = Get.find<ChatControllerr>(tag: tag);

//     // Update the ChatController
//     chatControllerr.updateChat(destinationId, appname);

//     print("Socket OnReceiveMessage $data");
//     print("${GlobalChatNumbers.presentAppname}");
//     if (GlobalChatNumbers.presentAppname.isEmpty == false) {
//       print(
//           "${GlobalChatNumbers.presentAppname}, ${data["app_name"]} is empty");
//       if (GlobalChatNumbers.presentAppname.last == data["app_name"] &&
//           numInChatscreen == destinationId.toString()) {
//         try {
//          // await playSoundFromAsset();
//           var ts = DateTime.now().millisecondsSinceEpoch / 1000;
//           var msg = data["message"]??"";
//           var u=data["file_url"]??"";
//           Message message;
         
        
//           if (u.contains('https://filemanager.gupshup.io') && msg=="") {
//             message = Message(
//                 agent: "",
//                 fileUrl: data["file_url"],
//                 message: null,
//                 direction:data.containsKey( "direction")?data[ "direction"]: "IN",
//                 timestamp: ts,
//                 type: "text");
//           } else {
//             message = Message(
              
//                 agent: "",
//                 fileUrl: "",
//                 message: msg,
//                 direction: data.containsKey( "direction")?data[ "direction"]:"IN",
//                 timestamp: ts,
//                 type: "text");
//           }
//  print(message.toJson());
//           messageList.insert(0, message);
//           print("inserted");
//         } catch (ex) {
//           print("inseted messgae error $ex");
//           SnapPeUI().toastError();
//         }
//       }
//     }
//     if (numInChatscreen != destinationId.toString()) {
//       Future.delayed(
//         //delay becz the message need one to two seconds to reach socket and get stored , my observation
//         Duration(seconds: 1),
//         () {
//           showNotification(messge,
//               destinationId); //dont show notification when the chat is opened
//         },
//       );
//     }
//   }

//   void showNotification(String message, destinationId) async {
//     // final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
//     try{
//       print("local notification is caalled from the chat details controller ");
//     int id = destinationId.hashCode;
//     var androidPlatformChannelSpecifics = localNotif.AndroidNotificationDetails(
//         "newsnappemerchant", "myFirebaseChannel",
//         importance: localNotif.Importance.max,
//         priority: localNotif.Priority.high,
//         icon: 'logo',
//         sound: localNotif.RawResourceAndroidNotificationSound('notification'),
//         playSound: true);
//     var platformChannelSpecifics = localNotif.NotificationDetails(
//         android: androidPlatformChannelSpecifics);
//     await flutterLocalNotificationsPlugin.show(
//       id,
//       '$destinationId',
//       message,
//       platformChannelSpecifics,
//       payload: destinationId,
//     );}catch(e){
//       print("local notiication error is called $e");
//     }
//   }




//   Future<bool> sendMessage(String msg, mobile, isFromLeadsScreen,
//       {String? fileType}) async {
//          var v1 = uuid.v1();
//     String? appName = await SharedPrefsHelper().getSelectedChatBot();
//     String liveAgentUserId = await SharedPrefsHelper().getMerchantUserId();
//     String? token = await SharedPrefsHelper().getToken();
//     String? clientGroup = await SharedPrefsHelper().getClientGroupName();
//     String? userselectedApplicationName =
//         await SharedPrefsHelper().getUserSelectedChatbot(clientGroup);
      
//       if (ChatDetailsController.overRideStatusTitle.value == "TakeOver") {
      
//         SnapPeUI().toastError(message: "👤 Please TakeOver the customer.");
//         return false;
//       }
//     final key = mobile;
//     Message message;
//     print("inside sendmesage");
//     print("$fileType is file type");
   
//     var ts = new DateTime.now().millisecondsSinceEpoch / 1000;
   
//     if (fileType != null) {
//       message = Message(
//         fileUrl: msg,
//         message: "",
//         direction: "OUT",
//         timestamp: ts,
//         type: fileType,
//         messageid:  v1
//       );
      
//     } else {
//       message = Message(
//         agent: "",
//         fileUrl: "",
//         message: msg,
//         direction: "OUT",
//         timestamp: ts,
//         type: "text",
//         messageid: v1
//       );
//     }
//     message.status="sent";
// print(message.toJson());
//     // if (SocketHelper.getInstance.sendMessage(
//     //   token,
//     //   liveAgentUserId,
//     //   msg,
//     //   key,
//     //   userselectedApplicationName ?? appName,
//     //   clientGroup,
//     //   fileType: fileType,
//     // ))    
//      if (true){
//      sendMessagebymqtt(
//       msg,
    
      
//       key,
//       userselectedApplicationName ?? appName,
//     v1,
//       fileType: fileType??'text',
//     );
//       // messageList.add(message);
//       messageList.insert(0, message);

//       print("succesful");
//       return true;
//     }
//     print("fail");
//     return false;
//   }
//   sendMessagebymqtt(String message, mobileNumber, appName,String v1, {String? fileType})async{
 
//  String chatSessionId=await SharedPrefsHelper().getChatSessionId()??"";
// Map<String,dynamic> messagebody=fileType!="text"? {"message": "","type":fileType,"destination_id":mobileNumber,"divigo_session_id":chatSessionId,"app_name":appName,"divigo_message_id":v1,"url":message}:{"message": message,"type":fileType,"destination_id":mobileNumber,"divigo_session_id":chatSessionId,"app_name":appName,"divigo_message_id":v1};
// MqttManager.publishMessage("$chatSessionId/customer-chat/agent", jsonEncode(messagebody));
// return true;
// }
//   void takeOver(mobile, bool? isFromLeadsScreen) async {
//     if (await SnapPeNetworks()
//         .takeOverOrReleaseRequest(mobile, isFromLeadsScreen)) {
//       overRideStatusTitle.value = "Release";
//       // SnapPeUI().toastSuccess(message: "Status Updated");
//        //testforcereload
//       ChatController().loadData(forcedReload: true);
//     }

//     // createSocketCon(fromSetOverRide: false); important thing
//     //first create socket connection for get sessionid ,
//     //we will do the takeOver process in onConnect method
//   }

//   void release(mobile, isFromLeadsScreen) async {
//     if (await SnapPeNetworks().takeOverOrReleaseRequest(
//         mobile, isFromLeadsScreen,
//         isReleaseReq: true)) {
//       //isOthers = false;
//       overRideStatusTitle.value = "TakeOver";
//       // SnapPeUI().toastSuccess(message: "Status Updated");
//       // disconnectSocketCon(mobile);// use this line when logguing out becoz we need to disconnect socket when user logs out
//       //testforcereload
//       ChatController().loadData(forcedReload: true);
//     }
//   }
// }
