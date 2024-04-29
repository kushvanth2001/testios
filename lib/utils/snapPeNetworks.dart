import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../Controller/chatDetails_controller.dart';
import '../Controller/login_controller.dart';
import '../helper/networkHelper.dart';
import '../helper/socketHelper.dart';
import '../models/model_Merchants.dart';
import '../models/model_Registration.dart';
import '../models/model_catalogue.dart';
import '../models/model_leadDetails.dart';
import '../models/model_consumer.dart';
import '../models/model_order_summary.dart';
import '../models/model_item.dart';
import '../models/model_orders.dart';
import 'snapPeRoutes.dart';
import 'snapPeUI.dart';
import '../helper/SharedPrefsHelper.dart';
import 'package:leads_manager/constants/networkConstants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart' as dio;
import '../models/model_CreateNote.dart';
import '../models/model_FollowUp.dart';
import '../models/model_PriceList.dart';
import '../models/model_Task.dart';
import '../models/model_callstatus.dart';
import '../models/model_lead.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SnapPeNetworks {
  SharedPrefsHelper sharedPrefsHelper = SharedPrefsHelper();
  // final storage = new FlutterSecureStorage();
  LoginController loginController = LoginController();
  //final socketHelper = SocketHelper.getInstance;
  Future requestOTP(String mobile, String appSignature) async {
    Uri url = NetworkConstants.getOTPUrl(mobile);
    http.Response? response =
        await NetworkHelper().request(RequestType.get, url);

    // http.Response response = await http.post(url,
    //     body: requestBody, headers: {"Content-Type": "application/json"});

    if (response == null) {
      // SnapPeUI().toastError();
      return false;
    }
    print(response.statusCode);
    if (response.statusCode == 200) {
      return true;
    } else {
      SnapPeUI().toastError(message: "❌ User Doesn't Exist.");
      return false;
    }
  }

  verifyOTP(BuildContext context, String mobileOrEmail, String otp) async {
    Uri url = NetworkConstants.getVerifyOtpURL;
    String reqBody =
        NetworkConstants.requestBodyVerifyOTP(mobileOrEmail, otp, "");

    http.Response? response = await NetworkHelper()
        .request(RequestType.post, url, requestBody: reqBody);

    if (response != null && response.statusCode == 200) {
      _saveUserInfo(response, context);
    } else {
      String msg = response != null && response.statusCode == 401
          ? "Incorrect OTP."
          : "🔄 Please Restart ";
      SnapPeUI().toastError(message: msg);
    }
  }

  Future registration(RegistrationModel model) async {
    Uri url = NetworkConstants.registration;
    String reqBody = registrationToJson(model);

    http.Response? response = await NetworkHelper()
        .request(RequestType.post, url, requestBody: reqBody);

    if (response == null) {
      return;
    }

    if (response.statusCode == 200) {
      return true;
    } else {
      SnapPeUI().toastError();
      return false;
    }
  }

  _saveUserInfo(http.Response response, BuildContext context,
      {email, password}) async {
    //save User Info
    final snapPeUI = SnapPeUI();
    snapPeUI.init(context);
    SharedPrefsHelper().setLoginStatus();
    sharedPrefsHelper.setResponse(response);
    print("response is set now");
    var token = response.headers[NetworkConstants.TOKEN]!;

    SharedPrefsHelper().setToken(token);

    SharedPrefsHelper().setLoginDetails(response.body);

    MerchantsModel merchantsModel = merchantsModelFromJson(response.body);
    List<Merchant>? merchantList = merchantsModel.merchants;
    // SnapPeUI().dialogSelectMerchant();
    if (merchantsModel.merchants!.length == 1) {
      if (await selectedMerchant(context, merchantList![0])) {
        Get.offAllNamed(SnapPeRoutes.homeRoute, arguments: response);
      }
    } else {
      snapPeUI.showSelectMerchantDialog(context);
    }
  }

  subcribeTopic(String merchantUserID) async {
    FirebaseMessaging.instance.subscribeToTopic(merchantUserID);
    String? token = await FirebaseMessaging.instance.getToken();
    print("send to server, FCM token  - $token");
    print("subcribeTopic - $merchantUserID");
    if (token != null) {
      await SnapPeNetworks().updateFcmInServer(token);
      //SnapPeUI().toastWarning(message: "updateFcmInServer $result");
    }
  }

  unSubcribeTopic(String merchantUserID) async {
    FirebaseMessaging.instance.unsubscribeFromTopic(merchantUserID);
    String? token = await FirebaseMessaging.instance.getToken();
    print("delete form server, FCM token  - $token");
    print("unSubcribeTopic - $merchantUserID");
    if (token != null) {
      await SnapPeNetworks().deleteFcmInServer(token);
      //SnapPeUI().toastWarning(message: "deleteFcmInServer $result");
    }
  }

  Future<bool> selectedMerchant(BuildContext context, Merchant merchant) async {
    try {
      String? clientName =
          "${merchant.user?.firstName}" + " " + "${merchant.user?.lastName}";
      //  SharedPrefsHelper().setClientGroupName(merchant.clientGroupName);
      // String? clientgrpnametest =
      //     await SharedPrefsHelper().getClientGroupName();
      // SharedPrefsHelper().setClientGroupNameTest(clientgrpnametest);
      SharedPrefsHelper().setClientGroupName(merchant.clientGroupName);
      String? clientgrpnametest =
          await SharedPrefsHelper().getClientGroupName();
      SharedPrefsHelper().setClientGroupNameTest(clientgrpnametest);

      SharedPrefsHelper()
          .setClientPhoneNo(merchant.user?.mobileNumber.toString());
      String? clientPhoneNoTest = await sharedPrefsHelper.getClientPhoneNo();
      SharedPrefsHelper().setClientPhoneNoTest(clientPhoneNoTest);

      SharedPrefsHelper().setClientName(clientName);
      String? clientNameTest = await sharedPrefsHelper.getClientName();
      SharedPrefsHelper().setClientNameTest(clientNameTest);

      // String sjkdn= sharedPrefsHelper.getClientGroupNameTest();
      //  print("clientGroupName is set  $clientgrpnametest and testclientname is $sjkdn\n\n\\n\\n\\n\n\/n/n//n/n/n//n/n/n//n//n/n/\n\\n\\n\\n\n/n/n/n/n//n/n//n/n");

      // SharedPrefsHelper().setClientPhoneNo(clientName);
      SharedPrefsHelper().setMerchantName(
          "${merchant.user?.firstName} ${merchant.user?.lastName}");
      SharedPrefsHelper().setMerchantUserId("${merchant.userId}");
      await refreshMerchantProfile();
      await refreshAppName();
      await leadSaveProperties();
      await pinnedTemplates();
      print(
          " $clientName,${merchant.user?.firstName} in selectedMerchant \n\n\n\\\\n\nn\n\\n\n\nn\n\\n\\n\n\\n\n\\n\n\n\\n\n\n\\n");
    //  final socketHelper = SocketHelper.getInstance;
      // Check if there is an active socket connection
      if (true){//socketHelper.getSocket != null && socketHelper.getSocket!.connected) {
        print('There is an active socket connection.');
        //socketHelper.disconnectPermanantly();
    
      //  await _chatDetailsController.createSocketCon();
      } else {
        print('There is no active socket connection.');
     
       // await _chatDetailsController.createSocketCon();
      }

      unSubcribeTopic("${merchant.userId}");
      subcribeTopic("${merchant.userId}");
      return true;
    } catch (ex) {
      SnapPeUI().toastError();
      return false;
    }
    // var merchant;
    // try {
    //   var merchantsList = responseData["merchants"];
    //   merchant = merchantsList[0];
    // } catch (ex) {
    //   merchant = responseData;
    // }

    // var clientName = merchant[NetworkConstants.CLIENT_NAME];
    // var phoneNo = merchant[NetworkConstants.PHONE_NO];
    // var role = merchant[NetworkConstants.ROLE];
    // var liveAgentUserId =
    //     merchant[NetworkConstants.LIVE_AGENT_USER_ID].toString();

    // SharedPreferences preferences = await SharedPreferences.getInstance();
    // preferences.setString(NetworkConstants.CLIENT_NAME, clientName);
    // preferences.setString(NetworkConstants.PHONE_NO, phoneNo);
    // preferences.setString(NetworkConstants.ROLE, role);
    // preferences.setString(NetworkConstants.LIVE_AGENT_USER_ID, liveAgentUserId);
  }

  Future<bool> selectedAppName(String appName) async {
    try {
      SharedPrefsHelper().setSelectedChatBot(appName);
      return true;
    } catch (ex) {
      SnapPeUI().toastError();
      return false;
    }
  }

  refreshMerchantProfile() async {
    String? merchantProfileData = await getProfile();
    if (merchantProfileData != null) {
      SharedPrefsHelper().setMerchantProfile(merchantProfileData);
    }
  }

  refreshAppName() async {
    String? appNameData = await getAllAppName();
    if (appNameData != null) {
      SharedPrefsHelper().setAppNames(appNameData);
    }
  }

  leadSaveProperties() async {
    List<dynamic>? properties = await Properties();
    if (properties != null) {
      Map<String, dynamic>? property = properties.lastWhere(
          (property) => property['propertyName'] == "create_lead_on_call",
          orElse: () => null);
      print("$property");
      String? leadPropertyValue = property?['propertyValue'];
      if (leadPropertyValue != null) {
        SharedPrefsHelper().setProperties(leadPropertyValue);
      }
    }
  }

  pinnedTemplates() async {
    List<dynamic>? properties = await Properties();
    if (properties != null) {
      Map<String, dynamic>? property = properties.lastWhere(
          (property) => property['propertyName'] == "pinned_templates",
          orElse: () => null);
      print("$property");
      String? pinnedTemplates = property?['propertyValue'];
      if (pinnedTemplates != null) {
        print("$pinnedTemplates");
        SharedPrefsHelper().setPinnedTemplates(pinnedTemplates);
      }
    }
  }

  logOut() async {
    try {
      String merchantUserID = await SharedPrefsHelper().getMerchantUserId();
      unSubcribeTopic(merchantUserID);
      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.clear();
      pref.remove('calllogstring');
pref.remove('resultlocal');

     // socketHelper.disconnectPermanantly();
      Get.offAllNamed(SnapPeRoutes.loginRoute);
    } catch (ex) {
      print(ex);
    }
  }

  // void storeLastLoggedInUser(String email) async {
  //   // Store the email address of the last logged-in user in shared preferences
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setString("lastLoggedInUser", email);
  // }

  // void storeCredentials(String email, String password) async {
  //   // Encrypt and store the email and password using flutter_secure_storage
  //   await storage.write(key: "email_$email", value: email);
  //   await storage.write(key: "password_$email", value: password);
  // }

  // Future<String?> loginWithStoredCredentials() async {
  //   // Retrieve the email address of the last logged-in user from shared preferences
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? email = prefs.getString("lastLoggedInUser");

  //   if (email != null) {
  //     // Retrieve the encrypted email and password from flutter_secure_storage
  //     String? storedEmail = await storage.read(key: "email_$email");
  //     String? password = await storage.read(key: "password_$email");

  //     if (storedEmail != null && password != null) {
  //       // Use the decrypted email and password to send a new login request
  //       // logOut();
  //       String? token = await loginForToken(email, password, loginController);
  //       return token;
  //     }
  //   }
  //   return null;
  // }

  login(BuildContext context, String email, String password,
      LoginController controller) async {
            SharedPreferences pref = await SharedPreferences.getInstance();
//         pref.remove('calllogstring');
// pref.remove('resultlocal');

    Uri url = NetworkConstants.loginURL;
    final snapPeUI = SnapPeUI();
    snapPeUI.init(context);
    var reqBody = NetworkConstants.requestBodyLogin(email, password);
    try {
      http.Response? response = await NetworkHelper()
          .request(RequestType.post, url, requestBody: reqBody);

      if (response != null && response.statusCode == 200) {
        // storeLastLoggedInUser(email);
        // storeCredentials(email, password);
        await _saveUserInfo(response, context,
            email: email, password: password);
      } else {
        String msg = response != null && response.statusCode == 401
            ? "Incorrect Password."
            : "Please Restart";
        SnapPeUI().toastError(message: msg);
      }
      controller.isLoading.value = false;
    } catch (ex) {
      controller.isLoading.value = false;
      SnapPeUI().toastError();
    }
  }

  // Future<String?> loginForToken(
  //     String email, String password, LoginController controller) async {
  //   Uri url = NetworkConstants.loginURL;
  //   var reqBody = NetworkConstants.requestBodyLogin(email, password);
  //   try {
  //     http.Response? response = await NetworkHelper()
  //         .request(RequestType.post, url, requestBody: reqBody);
  //     var token = response?.headers[NetworkConstants.TOKEN]!;
  //     controller.isLoading.value = false;
  //     return token;
  //   } catch (ex) {
  //     controller.isLoading.value = false;
  //     SnapPeUI().toastError(message: "SomeThing went Wrong.");
  //   }
  // }

  Future<List<PricelistMaster>> getPriceList(int customerId) async {
    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "";
    Uri uri = NetworkConstants.getPriceListUrl(customerId, clientGroupName);

    http.Response? response =
        await NetworkHelper().request(RequestType.get, uri);
    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      PriceListModel priceListModel = priceListModelFromJson(response.body);
      if (priceListModel.pricelistMasters != null) {
        return priceListModel.pricelistMasters!;
      }
    }
    return [];
  }
 static Future<List<PricelistMaster>> getAllMasterPricelist() async {
    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "";
    
    Uri uri = Uri.parse(
        "https://retail.snap.pe/snappe-services/rest/v1/merchants/$clientGroupName/pricelist-masters");

    http.Response? response =
        await NetworkHelper().request(RequestType.get, uri);

    if (response != null && response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
List<PricelistMaster> pricelist=[];
      for(int i=0;i<jsonResponse["pricelistMasters"].length;i++){
pricelist.add(PricelistMaster.fromJson(jsonResponse["pricelistMasters"][i]));

      }
    return pricelist;
    } else {
      // If the request was not successful, you might want to handle errors here
      throw Exception('Failed to load master pricelists');
    }
  }

 static Future<List<String>> getItemNameCustomer() async {
  String clientGroupName =
      await SharedPrefsHelper().getClientGroupName() ?? "";
  Uri uri = Uri.parse(
      "https://retail.snap.pe/snappe-services/rest/v1/merchants/$clientGroupName/web/skus?mode=desktop&page=0&size=20");

  http.Response? response =
      await NetworkHelper().request(RequestType.get, uri);
  if (response != null && response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    
    // Make sure "skuList" is a list
    if (jsonResponse['skuList'] is List) {
      List<String> itemNames =[];
      
      for(int i=0;i<jsonResponse['skuList'].length;i++){
       itemNames.add(jsonResponse['skuList'][i]["displayName"]);
      }

      return itemNames ;
    }
  }
  
  // Return an empty list if there's an issue with the response
  return [];
}
  Future<String> getItemList(int page, int size,
      {String serachKeyword = ""}) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return "";
    }
    Uri url = NetworkConstants.getItems(clientGroupName, page, size,
        serachKeyword: serachKeyword);

    http.Response? response =
        await NetworkHelper().request(RequestType.get, url);
    if (response == null) {
      SnapPeUI().toastError();
      return "";
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return "";
    }
  }

  Future<String> getOrderList(int page, int size,
      {int? timeFrom,
      int? timeTo,
      String? searchKeyword,
      String? customerNumber}) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return "";
    }
    Uri url = NetworkConstants.getAllOrderList(clientGroupName, page, size,
        searchKeyword: searchKeyword,
        timeFrom: timeFrom,
        timeTo: timeTo,
        customerNumber: customerNumber);
    print("$url");
    http.Response? response =
        await NetworkHelper().request(RequestType.get, url);
    if (response == null) {
      SnapPeUI().toastError();
      return "";
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return "";
    }
  }

  Future<String?> getTransactionList(int page, int size,
      {String? customerNumber}) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return null;
    }
    Uri url = NetworkConstants.getTransactionUrl(clientGroupName, page, size,
        customerNumber: customerNumber);
    http.Response? response =
        await NetworkHelper().request(RequestType.get, url);
    if (response == null) {
      SnapPeUI().toastError();
      return null;
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  Future<String> getOrderDetail(int orderId, bool isPendingOrder) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return "";
    }

    Uri url = isPendingOrder == true
        ? NetworkConstants.getPendingOrderDetails(clientGroupName, orderId)
        : NetworkConstants.getOrderDetails(clientGroupName, orderId);

    http.Response? response =
        await NetworkHelper().request(RequestType.get, url);
    if (response == null) {
      SnapPeUI().toastError();
      return "";
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return "";
    }
  }

  Future<bool> saveItem(Sku item, bool isNewItem) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return false;
    }
    Uri url = NetworkConstants.updateItem(clientGroupName, item.id.toString());
    print('$url');
    var reqBody = jsonEncode(item);
    print('$reqBody');
    http.Response? response;
    if (isNewItem) {
      response = await NetworkHelper()
          .request(RequestType.post, url, requestBody: reqBody);
    } else {
      response = await NetworkHelper()
          .request(RequestType.put, url, requestBody: reqBody);
    }

    if (response == null) {
      SnapPeUI().toastError();
      return false;
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      SnapPeUI().toastSuccess(message: "your items edited successfully.");
      return true;
    } else {
      SnapPeUI().toastError();
      return false;
    }
  }

  Future<bool> saveLead(
      int? leadId, LeadDetailsModel lead, bool isNewLead) async {
    print('in savelead method');

    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();
    print('$clientGroupName');
    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return false;
    }
    Uri url = NetworkConstants.updateLead(clientGroupName, leadId.toString());
    print('$url');
    print("--leadbody");
    print(jsonEncode(lead));
    var reqBody = jsonEncode(lead);
    print('$reqBody from my print');

    //  print('${reqBody["priorityId"]} from my print');

    Map<String, dynamic> jsonMap = json.decode(reqBody);
    http.Response? response;
    if (isNewLead) {
      response = await NetworkHelper()
          .request(RequestType.post, url, requestBody: reqBody);
    } else {
      response = await NetworkHelper()
          .request(RequestType.put, url, requestBody: reqBody);
    }

    if (response == null) {
      SnapPeUI().toastError();
      return false;
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      SnapPeUI().toastSuccess(message: "your items edited successfully.");
      return true;
    } else {
      SnapPeUI().toastError();
      return false;
    }
  }

  Future<bool> createNewCustomer(ConsumerModel consumer) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return false;
    }
    Uri url = NetworkConstants.createNewCustomer(clientGroupName);
    var reqBody = json.encode(consumer);
    http.Response? response = await NetworkHelper()
        .request(RequestType.post, url, requestBody: reqBody);

    if (response == null) {
      SnapPeUI().toastError();
      return false;
    }
    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      SnapPeUI().toastSuccess(message: "Custumer Added successfully.");
      return true;
    } else {
      SnapPeUI().toastError();
      return false;
    }
  }

  Future? getCategory() async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return null;
    }
    Uri url = NetworkConstants.getCategory(clientGroupName);
    http.Response? response =
        await NetworkHelper().request(RequestType.get, url);
    if (response == null) {
      SnapPeUI().toastError();
      return null;
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  Future? getUnit() async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return null;
    }
    Uri url = NetworkConstants.getUnit(clientGroupName);
    http.Response? response =
        await NetworkHelper().request(RequestType.get, url);
    if (response == null) {
      SnapPeUI().toastError();
      return null;
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  Future<dynamic> uploadImage(int? skuId, File imageFile) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();
    String? token = await SharedPrefsHelper().getToken();

    Uri url = NetworkConstants.uploadImage(clientGroupName!, skuId);

    print('Request uploadImage URL: $url');

    var formData = dio.FormData.fromMap({
      'files': [
        dio.MultipartFile.fromFileSync(imageFile.path, filename: 'files'),
        dio.MultipartFile.fromFileSync(imageFile.path, filename: 'files'),
      ]
    });
    dio.Response<Map> response = await dio.Dio().post(url.toString(),
        data: formData,
        options: dio.Options(headers: {
          "cookie": "token=$token",
          "Content-Type": "multipart/form-data"
        }));

    print('Response status: ${response.statusCode}');
    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      print("uploadImage response :  ${response.data}");

      return response.data;
    } else {
      EasyLoading.dismiss();
      SnapPeUI().toastError();
      return "";
    }
  }

  Future<bool> checkIsExistCustomer(String phoneNo) async {
    Uri url = NetworkConstants.getConsumer(phoneNo);

    http.Response? response =
        await NetworkHelper().request(RequestType.get, url);
    if (response == null) {
      SnapPeUI().toastError();
      return false;
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<Sku>> itemsSuggestionsCallback(
      String pattern, String? priceListCode) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    Uri url = NetworkConstants.getItemsSuggestion(
        clientGroupName!, pattern, priceListCode);
    http.Response? response =
        await NetworkHelper().request(RequestType.get, url);
    if (response == null) {
      SnapPeUI().toastError();
      return [];
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      ItemModel itemModel = itemFromJson(response.body);

      return itemModel.skuList == null ? [] : itemModel.skuList!;
    } else {
      SnapPeUI().toastError();
      return [];
    }
  }

  Future<List<OrderSummaryModel>> customerSuggestionsCallback(
      String pattern) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    Uri url = NetworkConstants.getCustomerSuggestion(clientGroupName!, pattern);
    http.Response? response =
        await NetworkHelper().request(RequestType.get, url);
    if (response == null) {
      SnapPeUI().toastError();
      return [];
    }
    try {
      if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
        var data = json.decode(response.body);
        var orderSummaryArray = data["orders"];
        List<OrderSummaryModel> osList = List<OrderSummaryModel>.from(
            orderSummaryArray.map((x) => OrderSummaryModel.fromJson(x)));

        return osList.length == 0 ? [] : osList;
      } else {
        SnapPeUI().toastError();
        return [];
      }
    } catch (ex) {
      print(ex);
      SnapPeUI().toastError();
      return [];
    }
  }

  Future<OrderSummaryModel?> createNewOrder(OrderSummaryModel order) async {
    print("create new order");
    try{
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
        print("errror");
      return null;
    }
    order.merchantName = clientGroupName;
    Uri url = NetworkConstants.createNewOrder(clientGroupName);
    var reqBody = orderSummaryModelToJson(order);
    http.Response? response = await NetworkHelper()
        .request(RequestType.post, url, requestBody: reqBody);

    if (response == null) {
      SnapPeUI().toastError();
      print("errror");
      return null;
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      print("print order submited");
      SnapPeUI().toastSuccess(message: "your order placed successfully.");
      OrderSummaryModel orderModel = orderSummaryModelFromJson(response.body);
      return orderModel;
    } else {
        print("errror");
      SnapPeUI().toastError();
      return null;
    }}catch(e){
          print("$e");
      SnapPeUI().toastError();
      return null;
    }
  }

  getDeliveryTime(String communityName) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    Uri url =
        NetworkConstants.getDeliveryOption(clientGroupName!, communityName);

    http.Response? response =
        await NetworkHelper().request(RequestType.get, url);
    if (response == null) {
      SnapPeUI().toastError();
      return "";
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return "";
    }
  }

  Future<String> getCommunity() async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    Uri url = NetworkConstants.getCommunity(clientGroupName!);

    http.Response? response =
        await NetworkHelper().request(RequestType.get, url);
    if (response == null) {
      SnapPeUI().toastError();
      return "";
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return "";
    }
  }

  Future<String?> getProfile() async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    Uri url = NetworkConstants.getProfileUrl(clientGroupName!);

    http.Response? response =
        await NetworkHelper().request(RequestType.get, url);
    if (response == null) {
      SnapPeUI().toastError();
      return null;
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  isExistMobile() {}

  void sendBill(String merchantName, int userId, int orderId,
      double orderAmount, String communityName, String mobile) async {
    EasyLoading.show(indicator: CircularProgressIndicator(), status: "Sending");

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var clientGroupName =
        preferences.getString(NetworkConstants.CLIENT_GROUP_NAME);
    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return null;
    }

    String reqBody = NetworkConstants.requestBodySendBill(
      merchantName,
      userId,
      orderId,
      orderAmount,
    );
    Uri url = NetworkConstants.sendBill(clientGroupName, communityName, mobile);

    http.Response? response = await NetworkHelper()
        .request(RequestType.post, url, requestBody: reqBody);

    if (response == null) {
      SnapPeUI().toastError();
      return;
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      SnapPeUI().toastSuccess();
    } else {
      SnapPeUI().toastError();
    }
  }

  downloadPdf(int orderId) async {
    EasyLoading.show(status: "Downloading...");

    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();
    String? token = await SharedPrefsHelper().getToken();

    String url = NetworkConstants.downloadInvoice(clientGroupName!, orderId);

    print(url);
    dio.Response? response;
    try {
      // String dirloc = "";
      // if (Platform.isAndroid) {
      //   dirloc = "/sdcard/download/$orderId _invoice.pdf";
      // } else {
      //   dirloc = (await getApplicationDocumentsDirectory()).path;
      // }
      var tempDir = await getTemporaryDirectory();
      String dirloc = tempDir.path + "/$clientGroupName invoice $orderId.pdf";
      print('full path $dirloc');

      response = await dio.Dio().get(
        url,
        onReceiveProgress: showDownloadProgress,
        //Received data with List<int>
        options: dio.Options(
            headers: {"token": token},
            responseType: dio.ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );
      print(response.statusCode);
      if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
        File file = File(dirloc);
        var raf = file.openSync(mode: FileMode.write);
        // response.data is List<int> type
        raf.writeFromSync(response.data);
        await raf.close();
        print('Share path ${raf.path}');
        Share.shareFiles([raf.path],
            text:
                "Greetings,%0A%0ARegarding%20your%20order%20number%20$orderId,%20kindly%20note%0A%0A");
        EasyLoading.dismiss();
      }
    } catch (ex) {
      EasyLoading.dismiss();
      SnapPeUI().toastError();
      print(ex);
    }
  }

  void showDownloadProgress(received, total) {
    EasyLoading.show(status: "Downloading...");
    print("Received - $received , total - $total");
    if (total != -1) {
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }

  void downloadItemsImages(Sku order) async {
    int len = order.images!.length;
    List<ImageC> imagesList = order.images!;
    print("Image size - ${imagesList.length}");
    List<String> path = [];
    String? token = await SharedPrefsHelper().getToken();

    for (int i = 0; i < len; i++) {
      try {
        var tempDir = await getTemporaryDirectory();
        String dirloc = tempDir.path + "/SnapePe$i.jpg";
        print('full path $dirloc');

        dio.Response response = await dio.Dio().get(
          imagesList[i].imageUrl!,
          onReceiveProgress: showDownloadProgress,
          //Received data with List<int>
          options: dio.Options(
              headers: {"token": token},
              responseType: dio.ResponseType.bytes,
              followRedirects: false,
              validateStatus: (status) {
                return status! < 500;
              }),
        );
        print(response.statusCode);
        if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
          File file = File(dirloc);
          var raf = file.openSync(mode: FileMode.write);
          // response.data is List<int> type
          raf.writeFromSync(response.data);
          await raf.close();
          path.add(raf.path);
        }
      } catch (ex) {
        EasyLoading.dismiss();
        SnapPeUI().toastError();
        print(ex);
      }
    }

    print("Path size - ${path.length}");
    Share.shareFiles(
      path,
      text:
          "Product Name - ${order.displayName} \n \n Price - ₹${order.sellingPrice} per ${order.measurement} ${order.unit!.name}",
    );
    EasyLoading.dismiss();
  }

  void downloadCatalogue() async {
    EasyLoading.show(status: "Downloading...");

    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();
    String? token = await SharedPrefsHelper().getToken();
    String url = NetworkConstants.downloadCatalogue(clientGroupName!);

    print(url);
    dio.Response? response;
    try {
      var tempDir = await getTemporaryDirectory();
      String dirloc = tempDir.path + "/$clientGroupName Catalogue.pdf";
      print('full path $dirloc');

      dio.Response response = await dio.Dio().get(
        url,
        onReceiveProgress: showDownloadProgress,
        options: dio.Options(
            headers: {"token": token},
            responseType: dio.ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );
      print(response.statusCode);
      if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
        File file = File(dirloc);
        var raf = file.openSync(mode: FileMode.write);
        // response.data is List<int> type
        raf.writeFromSync(response.data);
        await raf.close();
        print('Share path ${raf.path}');
        Share.shareFiles(
          [raf.path],
          text: "",
        );
        EasyLoading.dismiss();
      }
    } catch (ex) {
      EasyLoading.dismiss();
      SnapPeUI().toastError();
      print(ex);
    }
  }

  Future<String> getPendingOrders(int timeFrom, int timeTo, int page, int size,
      {String? searchKeyword}) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return "";
    }
    Uri url = NetworkConstants.getpendingOrder(
        clientGroupName, timeFrom, timeTo, page, size,
        searchKeyword: searchKeyword);
    http.Response? response =
        await NetworkHelper().request(RequestType.get, url);
    if (response == null) {
      SnapPeUI().toastError();
      return "";
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return "";
    }
  }
   Future<String> getQuotations(int timeFrom, int timeTo, int page, int size,
      {String? searchKeyword}) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return "";
    }
    Uri url = Uri.parse("https://retail.snap.pe/snappe-services/rest/v1/merchants/$clientGroupName/snappe-quotations?page=0&size=200&sortBy=createdOn&sortOrder=DESC"+  (searchKeyword != null ? "&customerName=$searchKeyword" : ""));
    http.Response? response =
        await NetworkHelper().request(RequestType.get, url);
    if (response == null) {
      SnapPeUI().toastError();
      return "";
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return "";
    }
  }
  

  acceptOrder(Order order) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return false;
    }
    Uri url = NetworkConstants.acceptOrder(clientGroupName, order.id!);
    order.orderStatus = "ACCEPTED";
    var reqBody = jsonEncode(order);

    http.Response? response;
    response = await NetworkHelper()
        .request(RequestType.put, url, requestBody: reqBody);

    if (response == null) {
      SnapPeUI().toastError();
      return false;
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      SnapPeUI().toastSuccess(message: "Order Accepted.");
      return true;
    } else {
      SnapPeUI().toastError();
      return false;
    }
  }

  confirmOrder(Order order) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return false;
    }
    Uri url = NetworkConstants.confirmOrder(clientGroupName, order.id!);
    var reqBody = jsonEncode(order);

    http.Response? response;
    response = await NetworkHelper()
        .request(RequestType.put, url, requestBody: reqBody);

    if (response == null) {
      SnapPeUI().toastError();
      return false;
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      SnapPeUI().toastSuccess(message: "Order Confirmed.");
      return true;
    } else {
      SnapPeUI().toastError();
      return false;
    }
  }

  updateOrder(String? orderStatus, String? paymentStatus, Order order) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return false;
    }

    Uri url = NetworkConstants.updateOrder(
        orderStatus, paymentStatus, clientGroupName);
    http.Response? response;
    response = await NetworkHelper()
        .request(RequestType.put, url, requestBody: ordersToJson([order]));

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      SnapPeUI().toastSuccess(message: "Updated");
      // Get.back();
    } else {
      SnapPeUI().toastError();
    }
  }

  void getQRCode(Order order) async {
    Uri url = NetworkConstants.getQRCodeUrl(
        order.applicationNo!, order.userId!, order.id!);
    http.Response? response;
    response = await NetworkHelper().request(RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      Get.defaultDialog(
          title: "QR Code", content: Image.memory(response.bodyBytes));
    } else {
      SnapPeUI().toastError();
    }
  }

  Future<String?> getLeads(int page, int size) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return null;
    }

    Uri url = NetworkConstants.getLeadsUrl(clientGroupName, page, size);

    http.Response? response;
    response = await NetworkHelper().request(RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  Future<String?> getLeadTags() async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return null;
    }

    Uri url = NetworkConstants.getLeadTagsUrl(clientGroupName);

    http.Response? response;
    response = await NetworkHelper().request(RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  Future<String?> getAssignTags(int leadId) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return null;
    }

    Uri url = NetworkConstants.getAssignTagsUrl(clientGroupName, leadId);

    http.Response? response;
    response = await NetworkHelper().request(RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  Future<String?> updateAssignTags(int? leadId, TagsDto tagsModel) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null || leadId == null) {
      SnapPeUI().toastError();
      return null;
    }

    Uri url = NetworkConstants.createTaskUrl(clientGroupName, leadId);

    http.Response? response;
    response = await NetworkHelper()
        .request(RequestType.post, url, requestBody: tagsDtoToJson(tagsModel));

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      SnapPeUI().toastSuccess(message: "✅ Task Created.");
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  Future<String?> getLeadStatus() async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return null;
    }

    Uri url = NetworkConstants.getLeadStatusUrl(clientGroupName);

    http.Response? response;
    response = await NetworkHelper().request(RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  Future<String?> getUsers() async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return null;
    }

    Uri url = NetworkConstants.getUsersUrl(clientGroupName);

    http.Response? response;
    response = await NetworkHelper().request(RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  Future<String?> getLeadDetails(int? leadId) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null || leadId == null) {
      SnapPeUI().toastError();
      return null;
    }

    Uri url = NetworkConstants.getLeadDetailsUrl(clientGroupName, leadId);

    http.Response? response;
    response = await NetworkHelper().request(RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  Future<String?> getLeadNotes(int? leadId) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null || leadId == null) {
      SnapPeUI().toastError();
      return null;
    }

    Uri url = NetworkConstants.getLeadNotesUrl(clientGroupName, leadId);

    http.Response? response;
    response = await NetworkHelper().request(RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  Future<bool?> createLeadNotes(int? leadId, CreateNote note) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null || leadId == null) {
      SnapPeUI().toastError();
      return false;
    }

    Uri url = NetworkConstants.createNoteUrl(clientGroupName, leadId);

    http.Response? response;
    response = await NetworkHelper()
        .request(RequestType.post, url, requestBody: createNoteToJson(note));

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      SnapPeUI().toastSuccess(message: "Note Created.");
      return true;
    } else {
      SnapPeUI().toastError();
      return false;
    }
  }

  Future<bool?> createTaskNotes(int? taskId, CreateNote note) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null || taskId == null) {
      SnapPeUI().toastError();
      return false;
    }

    Uri url = NetworkConstants.createTaskNoteUrl(clientGroupName, taskId);

    http.Response? response;
    response = await NetworkHelper()
        .request(RequestType.post, url, requestBody: createNoteToJson(note));
    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      SnapPeUI().toastSuccess(message: "Note Created.");
      return true;
    } else {
      SnapPeUI().toastError();
      return false;
    }
  }

  Future<String?> createTask(int? leadId, TaskModel taskModel) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null || leadId == null) {
      SnapPeUI().toastError();
      return null;
    }

    Uri url = NetworkConstants.createTaskUrl(clientGroupName, leadId);

    http.Response? response;
    response = await NetworkHelper().request(RequestType.post, url,
        requestBody: taskModelToJson(taskModel));

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      print("1");
      SnapPeUI().toastForTask(message: "✅ Task Created.");
      return response.body;
    } else {
      print("2");
      SnapPeUI().toastError();
      return null;
    }
  }

  Future<bool?> addFollowUp(int? leadId, FollowUpModel followUpModel) async {
    print("infollw up model");
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null || leadId == null) {
      SnapPeUI().toastError();
      return false;
    }
print( "body"+followUpModelToJson(followUpModel).toString());
    Uri url = NetworkConstants.createFollowUpUrl(clientGroupName, leadId);

    http.Response? response;
    response = await NetworkHelper().request(RequestType.post, url,
        requestBody: followUpModelToJson(followUpModel));

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      SnapPeUI().toastSuccess(message: "FollowUp Added.");
      return true;
    } else {
      SnapPeUI().toastError();
      return false;
    }
  }

  filterLeads(int page, int size,
      {dynamic nameOrMobile,
      List? assignedTo,
      List? tags,
      List? leadStatus,
      List? assignedBy,
      List<String>? selectedSources,
      List<String>? selectedDatess}) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return null;
    }

    Uri url = NetworkConstants.filterLeadsUrl(clientGroupName, page, size,
        nameOrMobile: nameOrMobile,
        assignedTo: assignedTo,
        assignedBy: assignedBy,
        tags: tags,
        selectedSources: selectedSources,
        selectedDates: selectedDatess,
        leadStatus: leadStatus);

    http.Response? response;
    response = await NetworkHelper().request (RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  getCustomers() async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return null;
    }

    Uri url = NetworkConstants.getCustomersUrl(clientGroupName);

    http.Response? response;
    response = await NetworkHelper() .request(RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  getCustomerDetails(int? customerId) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null && customerId == null) {
      SnapPeUI().toastError();
      return null;
    }

    Uri url =
        NetworkConstants.getCustomerDetailsUrl(clientGroupName!, customerId!);

    http.Response? response;
    response = await NetworkHelper().request(RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  searchCustomer(searchValue) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return null;
    }

    Uri url = NetworkConstants.searchCustomerUrl(clientGroupName, searchValue);

    http.Response? response;
    response = await NetworkHelper().request(RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }
static Future<List<CallStatus>> getcallStatus() async {
  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
  try {
    final response = await NetworkHelper().requestwithouteasyloading (
      RequestType.get,
      Uri.parse(
          'https://retail.snap.pe/snappe-services/rest/v1/merchants/$clientGroupName/lead/call-status'),
      requestBody: "",
    );
    if (response != null && response.statusCode == 200) {
      // print('Response Status: ${response.statusCode}');
      // print('Response Body: ${response.body}');
      final parsed = json.decode(response.body);
      final List<dynamic> statusList = parsed['callStatus'];
      final List<CallStatus> status =
          statusList.map((json) => CallStatus.fromJson(json)).toList();
      return status;
    } else {
      print('Failed to load call status');
      throw Exception('Failed to load call status');
    }
  } catch (e) {
    print('Exception occurred: $e');
    throw e;
  }
}

  getAllAppName() async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return null;
    }

    Uri url = NetworkConstants.getAllAppNameURl(clientGroupName);

    http.Response? response;
    response = await NetworkHelper().request(RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  Properties() async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();
    String liveAgentUserId = await SharedPrefsHelper().getMerchantUserId();
    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return null;
    }

    Uri url =
        NetworkConstants.getPropertiesURl(clientGroupName, liveAgentUserId);
    print("url is $url");
    http.Response? response;
    response = await NetworkHelper().request(RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      // Parse the response body as a JSON object
      Map<String, dynamic> responseBody = jsonDecode(response.body);
      // Extract the properties array from the response body
      List<dynamic> properties = responseBody['userProperties'];
      return properties;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  Future<String?> getAllChatData(
      {int page = 0, int? previousTime, int? currentTime}) async {
EasyLoading.init();
//            currentTime =DateTime.now().millisecondsSinceEpoch ~/ 1000; //1712296150;
// previousTime=DateTime.now().millisecondsSinceEpoch ~/ 1000;
          //  previousTime =DateTime.now().millisecondsSinceEpoch~/ 100; //currentTime - 2629746;
            print('allchatdata');
            print(currentTime);
            print(previousTime);
    // if (currentTime == null) {
    //   currentTime ??= DateTime.now().millisecondsSinceEpoch ~/ 1000;
    // }
    Uri url;
    // if (previousTime == null) {
    //   previousTime ??= currentTime - 2629746;
    // }
    // 1 Month  //15780096; // 6 months  //604800; //  1 Week Before
    print("getAllChatData current Time - $currentTime previous Time - $previousTime");
    //String selectedChatBot = SnapBasketApplication.sharedPreferences.getString(AppConstant.SELECTED_CHATBOT, null);
    String? appName = await SharedPrefsHelper().getSelectedChatBot();
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();
String divigoid=await SharedPrefsHelper().getChatSessionId()??"";
    String? userselectedApplicationName =
        SharedPrefsHelper().getUserSelectedChatbot(clientGroupName);

    if (clientGroupName == null || appName == null) {
      SnapPeUI().toastError();
      return null;
    }
    if (userselectedApplicationName == null) {
      url = NetworkConstants.getAllChatDataUrl(clientGroupName, appName,
          previousTime.toString(), currentTime.toString(),divigoid,
          page: page);
    } else {
      url = NetworkConstants.getAllChatDataUrl(
          clientGroupName,
          userselectedApplicationName,
          previousTime.toString(),
          currentTime.toString(),divigoid,
          page: page);
    }
    print("chat url $url");
    http.Response? response;
    response = await NetworkHelper().request(RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
        
      return response.body;
    } else {
      SnapPeUI().toastError();
      EasyLoading.dismiss();
      return null;
    }
   
  }

  Future<void> changeProperty(List<Map<String, dynamic>> properties) async {
    String userId = await SharedPrefsHelper().getMerchantUserId();
    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "";
    final response = await NetworkHelper().request(
        RequestType.put,
        Uri.parse(
            'https://retail.snap.pe/snappe-services/rest/v1/merchants/$clientGroupName/user/$userId/properties'),
        requestBody: jsonEncode(properties));

    if (response != null && response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  getSingleChatData(dynamic customerPhone, bool isFromLeadsScreen) async {
    int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int previousTime =DateTime.now().millisecondsSinceEpoch ~/ 1000;
       // currentTime - 2592000; //  1 Week Before //2629743; // 1 months
    //previousTime = 1619277183;//test
    print(
        "getSingleChatData current Time - $currentTime previous Time - $previousTime");
    String? defaultAppName;
    if (isFromLeadsScreen == true) {
      defaultAppName = await getAppName(customerPhone);
    }
    String? appName = await SharedPrefsHelper().getSelectedChatBot();
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    String? userselectedApplicationName =
        SharedPrefsHelper().getUserSelectedChatbot(clientGroupName);
    if (clientGroupName == null || appName == null) {
      SnapPeUI().toastError();
      return null;
    }
    Uri url;
    if (defaultAppName != null) {
      url = NetworkConstants.getSingleChatData(customerPhone, clientGroupName,
          defaultAppName, previousTime.toString(), currentTime.toString());
      print("$defaultAppName");
    } else if (userselectedApplicationName != null &&
        userselectedApplicationName != "") {
      url = NetworkConstants.getSingleChatData(
          customerPhone,
          clientGroupName,
          userselectedApplicationName!,
          previousTime.toString(),
          currentTime.toString());
      print("$userselectedApplicationName");
    } else {
      url = NetworkConstants.getSingleChatData(customerPhone, clientGroupName,
          appName, previousTime.toString(), currentTime.toString());
          print(url.toString());
    }
    http.Response? response;
    response = await NetworkHelper().request(RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
          print("print response from d1+${response.body}");
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  checkOverrideStatus(dynamic customerPhone) async {
    String? appName = await SharedPrefsHelper().getSelectedChatBot();
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    String? userselectedApplicationName =
        SharedPrefsHelper().getUserSelectedChatbot(clientGroupName);
    if (clientGroupName == null || appName == null) {
      SnapPeUI().toastError();
      return null;
    }
    Uri url;
    if (userselectedApplicationName == null) {
      url = NetworkConstants.overrideStatusUrl(
          appName, customerPhone, clientGroupName,
          isCheckOverrideStatus: true);
    } else {
      url = NetworkConstants.overrideStatusUrl(
          userselectedApplicationName, customerPhone, clientGroupName,
          isCheckOverrideStatus: true);
    }
    http.Response? response;
    response = await NetworkHelper().request(RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      return response.body;
    } else {
      //SnapPeUI().toastError();
      return null;
    }
  }

  Future<bool> takeOverOrReleaseRequest(
   
      dynamic customerPhone, bool? isFromLeadsScreen,
      {bool isReleaseReq = false}) async {
    try {
       print("releasotake over request");
      String? appName = await SharedPrefsHelper().getSelectedChatBot();
      String? clientGroup = await SharedPrefsHelper().getClientGroupName();
      String? liveAgentUserId = await SharedPrefsHelper().getMerchantUserId();
      String? liveAgentUserName = await SharedPrefsHelper().getMerchantName();
      String? defaultAppName;
      String? userselectedApplicationName =
          SharedPrefsHelper().getUserSelectedChatbot(clientGroup);
      String? liveAgentSessionId =
          await SharedPrefsHelper().getChatSessionId();

      if (clientGroup == null ||
          appName == null ||
          liveAgentUserId == null ||
          liveAgentUserName == null ||
          liveAgentSessionId == null) {
        print(
            "$clientGroup ,$appName,$liveAgentUserId,$liveAgentUserName,$liveAgentSessionId");
      //  SnapPeUI().toastError();
        return false;
      }
print("1");
      String reqBody = NetworkConstants.requestBodyTakeOver(
          liveAgentUserId,
          liveAgentUserName,
          NetworkConstants.AGENT_CHANNEL_VALUE,
          liveAgentSessionId,
          clientGroup);
      Uri url;
      if (isFromLeadsScreen == true) {
        print("2");
        defaultAppName = await getAppName(customerPhone);
        if (defaultAppName != null) {
          url = NetworkConstants.overrideStatusUrl(
            defaultAppName,
            customerPhone,
            clientGroup,
          );
        } else {
          print("3");
          url = NetworkConstants.overrideStatusUrl(
            appName,
            customerPhone,
            clientGroup,
          );
        }
      } else {
        if (userselectedApplicationName != null &&
            userselectedApplicationName != "") {
              print("4");
          url = NetworkConstants.overrideStatusUrl(
            userselectedApplicationName,
            customerPhone,
            clientGroup,
          );
        } else {
          print("5");
          url = NetworkConstants.overrideStatusUrl(
            appName,
            customerPhone,
            clientGroup,
          );
        }
      }
print("release url$url");
print("postingrelease");
      RequestType reqType = RequestType.post;
      if (isReleaseReq) {
        reqType = RequestType.delete;
      }

      http.Response? response;
      response = await NetworkHelper()
          .request(reqType, url, requestBody: reqBody, isLiveAgentReq: true);

      if (response != null &&
          response.statusCode == 200 &&
          isTokenValid(response.statusCode)) {
        var obj = json.decode(response.body);
        String status = obj["status"];
        if (status == "user_inactive") {
          print("6");
          SnapPeUI().toastError(
              message:
                  "User session is inactive, we have sent a request to the user for starting a live agent request. \n \n You will be notified, once the user confirms.");
          return false;
        } else if (status == "success") {
           print("eoor from over riding");
          return true;
        }
       // SnapPeUI().toastError();
       print("eoor from over riding");
        return false;
      } else {
       // SnapPeUI().toastError();
       print("eoor from over riding");
        return false;

      }
    } catch (e) {
      print("eror");
      SnapPeUI().toastError();
      return false;
    }
  }

  Future<bool> updateFcmInServer(String newFCMtoken) async {
    String? oldFMCToken = await SharedPrefsHelper().getFCMToken();
    if (oldFMCToken == newFCMtoken) {
      return true;
    }
    String? liveAgentUserId = await SharedPrefsHelper().getMerchantUserId();
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();
    if (clientGroupName == null || liveAgentUserId == null) {
      SnapPeUI().toastError();
      return false;
    }

    var reqBody = NetworkConstants.requestBodyFCM(
        liveAgentUserId, newFCMtoken, clientGroupName);

    Uri url = NetworkConstants.getUpdateFCMUrl();

    http.Response? response;
    response = await NetworkHelper()
        .request(RequestType.post, url, requestBody: reqBody);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      print("it is $response");
      await SharedPrefsHelper().setFCMToken(newFCMtoken);
      return true;
    } else {
      SnapPeUI().toastError();
      return false;
    }
  }

  Future<bool> deleteFcmInServer(String token) async {
    Uri url = NetworkConstants.getDeleteFCMUrl(token);

    http.Response? response;
    response = await NetworkHelper().request(RequestType.delete, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      return true;
    } else {
      SnapPeUI().toastError();
      return false;
    }
  }

  bool isTokenValid(int? statusCode) {
    if (statusCode == 401) {
      logOut();
      SnapPeUI().toastError(message: "❌ Your Credentials Expired.");
      return false;
    }
    return true;
  }
}

Future<List<dynamic>> getTemplates(String? selectedApplicationName) async {
  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
  final response = await NetworkHelper().request(
    RequestType.get,
    Uri.parse(
        'https://retail.snap.pe/snappe-services/rest/v1/gupshup/$selectedApplicationName/templates?merchant=$clientGroupName'),
    requestBody: "",
  );
  if (response != null && response.statusCode == 200) {
    var data = jsonDecode(response.body);
    List<dynamic> templates = data['templates'];
    return templates;
  } else {
    throw Exception('Failed to load templates');
  }
}

// Future<Map<String, dynamic>?> defaultData() async {
//   try {
//     String clientGroupName =
//         await SharedPrefsHelper().getClientGroupName() ?? "";
//     final response = await NetworkHelper().request(
//       RequestType.get,
//       Uri.parse(
//           "https://prod-cb-ne.snap.pe/chatbot/rest/v1/merchants/$clientGroupName/business_application/commerce"),
//       requestBody: "",
//     );

//     if (response != null && response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception('Failed to load data');
//     }
//   } catch (e) {
//     // Handle the error here
//     print(e);
//     return null;
//   }
// }
Future<String?> getAppName(mobile) async {
  var clientGroupName = SharedPrefsHelper().getClientGroupNameTest() ?? "";
  final response = await NetworkHelper().request(
    RequestType.get,
    Uri.parse(
        'https://retail.snap.pe/snappe-services/rest/v1/merchants/$clientGroupName/conversations/Customer/app/$mobile'),
    requestBody: "",
  );

  if (response != null && response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse['app_name'];
  } else {
    throw Exception('Failed to load app name');
  }
}
