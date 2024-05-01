import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../services/localNotificationService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/networkConstants.dart';
import '../helper/SharedPrefsHelper.dart';
import '../helper/networkHelper.dart';
import 'package:http/http.dart' as http;
import '../helper/socketHelper.dart';
import '../models/model_chat.dart';
import '../utils/snapPeNetworks.dart';

class Global {
  static RxInt currentPage = RxInt(0);
  static RxInt previoustime=RxInt(DateTime.now().millisecondsSinceEpoch ~/ 100);
  static RxInt currenttime=RxInt(DateTime.now().millisecondsSinceEpoch ~/ 1000);
}

class ChatController extends GetxController {
  static RxList<ChatModel> myChatList = <ChatModel>[].obs;
  static Rx<bool> isloading = false.obs;
  static RxList<ChatModel> newRequestList = <ChatModel>[].obs;
  static RxList<ChatModel> otherList = <ChatModel>[].obs;
  // static final currentTimeVar = <int>[].obs;
  // static final previousTimeVar = <int>[].obs;
  final StreamController<String> previewMessageController =
      StreamController<String>.broadcast();
        static const MethodChannel _channel = MethodChannel('samples.flutter.dev/mqtt');
// Add a scrollController property
  ScrollController scrollController = ScrollController();
  int currentPage = 0;
  late int currentTime;
  late int previousTime;
  //    void onInit() {
  //   super.onInit();
  //  _channel.setMethodCallHandler((call) async {
  //       print("the method handler called");
  //     switch (call.method) {
      
  //       case 'onDataReceived':
  //         String receivedData = call.arguments;
  //         // Handle the received data in your Flutter code
  //         print('Received data from Android: $receivedData');
  //         Map<String,dynamic> data=jsonDecode(receivedData);
  //            // Find the ChatModel object with the matching customerNo
  //                       LocalNotificationService.createAndDisplayNotification(RemoteMessage(notification: RemoteNotification(title: "app_name".toString(),body: "message".toString())));
  //                      if(data["type"]== "customer-chat"){
  //          LocalNotificationService.createAndDisplayNotification(RemoteMessage(notification: RemoteNotification(title: data["app_name"].toString(),body: data["message"].toString())));}
  //     ChatModel? chat = myChatList.firstWhereOrNull(
  //         (chat) => chat.customerNo == data['destination_id']);
  //         print("create and display");

  //     if (chat != null) {
  //       // Update the preview_message property of the ChatModel object
  //       print("create and display");
  //     //  LocalNotificationService.createAndDisplayNotification(RemoteMessage(notification: RemoteNotification(title: "receivedData",body: "done")));
  //       chat.preview_message = data['message'];
  //       // Notify listeners that the myChatList property has changed
  //       myChatList.refresh();
  //     }
  //         // You can call a method or update a state with the received data
  //         break;
  //       // Add more cases as needed
  //       // ...
  //     }
  //   });
   
  //}

  ChatController() {
    currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    previousTime = currentTime - 2629746;
    // Defer these operations
    // currentTimeVar.add(currentTime);
    // previousTimeVar.add(previousTime);

    // print("$previousTimeVar, $currentTimeVar");
    // Call the scrollListener method in the constructor
    print("$currentTime,$previousTime");
    scrollListener();
    // listenToSocketEvent();
   // listenForNewMessages();
  }
  static Future<RxInt> getUnreadMessageCount(String customerNo) async {
    final prefs = await SharedPreferences.getInstance();
    return RxInt(prefs.getInt('unread_$customerNo') ?? 0);
  }

  // void onPreviewMessageChanged(String newMessage) {
  //   previewMessageController.add(newMessage);
  // }

  // Listen to the socket event
  // void listenToSocketEvent() {
  //   SocketHelper.getInstance.getSocket
  //       ?.on(NetworkConstants.EVENT_MESSAGE_RECEIVED, (data) async {
  //     // Extract the new message from the data object
  //     String newMessage = data['message'];
  //     // Update the preview message
  //     onPreviewMessageChanged(newMessage);
  //   });
  // }

  void listenForNewMessages() {
      _channel.setMethodCallHandler((call) async {
        print("the method handler called");
      switch (call.method) {
      
        case 'onDataReceived':
          String receivedData = call.arguments;
          // Handle the received data in your Flutter code
          print('Received data from Android: $receivedData');
          Map<String,dynamic> data=jsonDecode(receivedData);
             // Find the ChatModel object with the matching customerNo
      ChatModel? chat = myChatList.firstWhereOrNull(
          (chat) => chat.customerNo == data['destination_id']);
          print("create and display");
           LocalNotificationService.createAndDisplayNotification(RemoteMessage(notification: RemoteNotification(title: "receivedData",body: "done")));
      if (chat != null) {
        // Update the preview_message property of the ChatModel object
        print("create and display");
        LocalNotificationService.createAndDisplayNotification(RemoteMessage(notification: RemoteNotification(title: "receivedData",body: "done")));
        chat.preview_message = data['message'];
        // Notify listeners that the myChatList property has changed
        myChatList.refresh();
      }
          // You can call a method or update a state with the received data
          break;
        // Add more cases as needed
        // ...
      }
    });
   
  }

  @override
  void onClose() {
    previewMessageController.close();
    super.onClose();
  }

  void sortChatsByLastMessageTime() {
    myChatList.sort((a, b) {
      if (a.lastTs != null && b.lastTs != null) {
        return b.lastTs.compareTo(a.lastTs);
      } else if (a.lastTs != null) {
        return -1;
      } else if (b.lastTs != null) {
        return 1;
      } else {
        return 0;
      }
    });
    myChatList.sort((a, b) {
      if (a.lastTs != null && b.lastTs != null) {
        return a.lastTs.compareTo(b.lastTs);
      } else if (a.lastTs != null) {
        return 1;
      } else if (b.lastTs != null) {
        return -1;
      } else {
        return 0;
      }
    });
  }

  // Future<void> incrementUnreadMessageCount(String customerNo) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   int currentUnreadCount = prefs.getInt('unread_$customerNo') ?? 0;
  //   await prefs.setInt('unread_$customerNo', currentUnreadCount + 1);
  //   (await getUnreadMessageCount(customerNo)).value++;
  // }

  // Future<void> clearUnreadMessageCount(String customerNo) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('unread_$customerNo');
  //   (await getUnreadMessageCount(customerNo)).value = 0;
  // }

  void scrollListener() {
    // Add a listener to the scrollController
    scrollController.addListener(() async{
      if (scrollController.position.maxScrollExtent - scrollController.offset ==
          0.0) {
        Global.currentPage.value++;
         String? response = await SnapPeNetworks().getAllChatData(
        page: 0,
        previousTime:Global.previoustime.value,
        currentTime: Global.previoustime.value);
    print("this is from scroll controller $response ");

    if (response != null) {
      List<ChatModel> tempChatList = chatModelFromJson(response);
      
              if (tempChatList.isNotEmpty) {
                print("tempChatList.isNotEmpty");
                try{
                   print("previous time vlaue ${tempChatList.last.lastTs}");
  Global.previoustime.value = tempChatList.last.lastTs.toInt();
  
  print("previous time vlaue ${Global.previoustime.value}");
  }catch(e){
    print("chat erorr $e");
   }
  // Now you can use lastTimestamp in further operations
}
      }
        print("Global page number ${Global.currentPage.value}");
        loadData(page: 0,);
      

        
      }
      
    });
  }
// Future<void> loadData({int page = 0, bool forcedReload = false}) async {
//   // Set loading state to true
//   bool isLoading = true;
//  forcedReload==true?Global.previoustime.value= DateTime.now().millisecondsSinceEpoch ~/ 100:null;
//   // Show loading indicator
//   if (forcedReload) {
//     isloading.value=true;
//     EasyLoading.show(status: 'Loading...');
       
//         newRequestList.clear();
//   }

//   try {
//     // Perform API call
//     print("started api call${DateTime.now()}@///");
//     final response = await SnapPeNetworks().getAllChatData(
//       page: 0,
//       previousTime: forcedReload ? Global.previoustime.value : null,
//       currentTime: forcedReload ? Global.previoustime.value : null,
//     );

//     // Process response if not null
//     if (response != null) {
//       print("recived response ${DateTime.now()}@///");
//       List<ChatModel> chatList = chatModelFromJson(response);
//   print("parsed response response${DateTime.now()}@///");

//       // If chatList is empty, handle the case
//       // if (chatList.isEmpty) {
      
//       //   Global.currentPage.value = 0;
//       // }

//       // Process chatList
//         print("adding into newrequest list${DateTime.now()}@///");
//      // processChatList(chatList);
//       newRequestList.addAll(chatList);
//       print("adding completed${DateTime.now()}@///");
//       isloading.value=false;
//     }
//   } catch (e) {
//     // Handle errors
//     print('Error loading data: $e');
//       isloading.value=false;
//   } finally {
//     // Dismiss loading indicator
//     if (isLoading) {
//       EasyLoading.dismiss();
//     }
//   }
// }

 Future<void> loadData({int page = 0,bool forcedReload=false})async {
    print(" this is xyz $page");
   forcedReload==true?Global.previoustime.value= DateTime.now().millisecondsSinceEpoch ~/ 100:null;

    if (forcedReload) {
    
      
        newRequestList.clear();
    isloading.value=true;
      
    }
   // print("$previousTimeVar");
    String? response = await SnapPeNetworks().getAllChatData(page: 0,
        previousTime: Global.previoustime.value,
        currentTime: Global.previoustime.value);
    print("this is xyz ${DateTime.now()}$response ");
    if (response != null) {
      List<ChatModel> chatList = chatModelFromJson(response);
      print("$chatList");
      if (chatList.isEmpty) {
        print("HERE IN change api ");

        
        response = await SnapPeNetworks().getAllChatData(
            page: 0,
            previousTime: Global.previoustime.value,
            currentTime: Global.previoustime.value);
        if (response != null) {
          chatList = chatModelFromJson(response);
          if (chatList.isEmpty) {
           
            Global.currentPage.value = 0;
            response = await SnapPeNetworks().getAllChatData(
                page: 0,
                currentTime: Global.previoustime.value,
                previousTime: Global.previoustime.value);
            if (response != null) {
              chatList = chatModelFromJson(response);
            }
          }
        }
      }
      processChatList(chatList);
      newRequestList.addAll(chatList);
    }
   // loadOtherListData();
    //loadMyChatListData();
    isloading.value=false;
  }

  processChatList(List<ChatModel> chatList) async {
    // String currentLiveAgentUserId =
    //     await SharedPrefsHelper().getMerchantUserId();
    // for (int i = 0; i < chatList.length; i++) {
    //   var overrideStatus = chatList[i].overrideStatus;
    //   if (overrideStatus != null) {
    //     if (overrideStatus.agentOverride == null ||
    //         overrideStatus.agentOverride == 0 ||
    //         overrideStatus.liveAgentUserId == null) {
              
    //       newRequestList.add(chatList[i]);
    //     } else if (overrideStatus.agentOverride == 1) {
    //       if ("${overrideStatus.liveAgentUserId}" == currentLiveAgentUserId) {
    //         myChatList.add(chatList[i]);
    //       } else {
    //         // otherList.add(chatList[i]);
    //       }
    //     }
    //   } else {
    //     newRequestList.add(chatList[i]);
        
    //   }
    // }
  }

  void loadOtherListData() async {
    String? appName = await SharedPrefsHelper().getSelectedChatBot();
    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "";
    String? userselectedApplicationName =
        await SharedPrefsHelper().getUserSelectedChatbot(clientGroupName);

    // Construct the URL for the network request
    Uri url = Uri.parse(
        "https://retail.snap.pe/snappe-services/rest/v1/merchants/$clientGroupName/applications/${userselectedApplicationName ?? appName}/active-conversations?get_for_other_users=true");

    // Create an instance of the NetworkHelper class
    NetworkHelper networkHelper = NetworkHelper();

    // Make the network request using the NetworkHelper class
    http.Response? response = await networkHelper.request(RequestType.get, url);

    // Check if the response was successful
    if (response != null && response.statusCode == 200) {
      // Parse the response data
      Map<String, dynamic> responseData = json.decode(response.body);
      List<dynamic> activeSessions = responseData['active_sessions'];

      // Create a list of ChatModel objects from the activeSessions data
      List<ChatModel> chatList =
          activeSessions.map((session) => ChatModel.fromJson(session)).toList();

      // Add the data to the otherList
      otherList.addAll(chatList);
    } else {
      // Handle error
      print("Error: ${response?.statusCode}");
    }
  }

  void loadMyChatListData() async {
    String? appName = await SharedPrefsHelper().getSelectedChatBot();
    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "";
    String? userselectedApplicationName =
        await SharedPrefsHelper().getUserSelectedChatbot(clientGroupName);
    // Construct the URL for the network request
    Uri url = Uri.parse(
        "https://retail.snap.pe/snappe-services/rest/v1/merchants/$clientGroupName/applications/${userselectedApplicationName ?? appName}/active-conversations?get_for_other_users=false");

    // Create an instance of the NetworkHelper class
    NetworkHelper networkHelper = NetworkHelper();

    // Make the network request using the NetworkHelper class
    http.Response? response = await networkHelper.request(RequestType.get, url);

    // Check if the response was successful
    if (response != null && response.statusCode == 200) {
      // Parse the response data
      Map<String, dynamic> responseData = json.decode(response.body);
      List<dynamic> activeSessions = responseData['active_sessions'];

      // Create a list of ChatModel objects from the activeSessions data
      List<ChatModel> chatList =
          activeSessions.map((session) => ChatModel.fromJson(session)).toList();

      // Add the data to myChatList, checking for duplicates
      for (ChatModel chat in chatList) {
        if (!myChatList.any((c) => c.customerNo == chat.customerNo)) {
          myChatList.add(chat);
        }
        newRequestList.removeWhere((c) => c.customerNo == chat.customerNo);
      }
    } else {
      // Handle error
      print("Error: ${response?.statusCode}");
    }
  }

  void clearTimes() {
    // previousTimeVar.clear();
    // currentTimeVar.clear();
    // Global.currentPage.value = 0;
   Global.previoustime=RxInt(DateTime.now().millisecondsSinceEpoch ~/ 100);
  }
}
