import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../Controller/leads_controller.dart';
import '../helper/SharedPrefsHelper.dart';
import '../models/model_chat.dart';
import '../views/chat/chatDetailsScreen.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static initializeNotifications(
      userselectedApplicationName, String? appName) async {
    final LeadController leadController = LeadController();
    var initializationSettingsAndroid = AndroidInitializationSettings('logo');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    _notificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      // if (payload != null) {
      //   print("${userselectedApplicationName} , ${appName},${payload}");
      //   Get.to(() => ChatDetailsScreen(
      //       firstAppName: userselectedApplicationName ?? appName,
      //       isOther: false,
      //       isFromLeadsScreen: false,
      //       chatModel: ChatModel(customerNo: payload),
      //       leadController: leadController,
      //       isFromNotification: true));
      // }
    });
  }

  // static void initialize() {
  //   const InitializationSettings initializationSettings =
  //       InitializationSettings(
  //           android: AndroidInitializationSettings("@mipmap/ic_launcher"));
  //   _notificationsPlugin.initialize(
  //     initializationSettings,
  //     onSelectNotification: (payload) {
  //       print("Notification - onSelectNotification $payload");
  //       if (payload!.isNotEmpty) {
  //         // Get.to(() => ChatDetailsScreen(
  //         //       chatModel: ChatModel(customerNo: payload),
  //         //     ));
  //         print("Router $payload");
  //       }
  //     },
  //   );
  // }

  static void createAndDisplayNotification(RemoteMessage message) async {
    print("Notification - createAndDisplayNotification $message");
    try {
      // final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      int? id = message.notification?.title.hashCode;
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          "newsnappemerchant", "myFirebaseChannel",
          importance: Importance.max,
          priority: Priority.high,
          icon: 'logo',
          sound: RawResourceAndroidNotificationSound('notification'),
          playSound: true);

      var platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await _notificationsPlugin.show(
        id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
        message.notification?.title, //message.data['destination_id']
        message.notification?.body, //message.data['message']
        platformChannelSpecifics,
        payload: message.notification?.title,
        //payload:message.data['destination_id']
      );
    } on Exception catch (e) {
      print(e);
    }
  }
}





//  if (payload != null) {
//         List<ChatModel>? chatModels = ChatController.newRequestList;
//         final chatModel = chatModels.firstWhereOrNull(
//           (chat) => chat.customerNo == payload,
//         );
//         Get.to(() => ChatDetailsScreen(
//             firstAppName: userselectedApplicationName ?? appName,
//             isOther: false,
//             isFromLeadsScreen: false,
//             chatModel: chatModel,
//             leadController: leadController));
//       }