import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'SharedPrefsHelper.dart';
import '../utils/snapPeNetworks.dart';

enum RequestType { get, post, put, delete }

class NetworkHelper {
  Future<http.Response?> request(RequestType requestType, Uri uri,
      {dynamic requestBody = "", bool isLiveAgentReq = false}) async {

    EasyLoading.show(dismissOnTap: true);
    print("Request - $requestType Url - $uri");
    print("RequestBody - $requestBody");
    String? token = await SharedPrefsHelper().getToken();
    sendTokenToCallLogReceiver(token);
    Map<String, String> defaultHeader = {
      "Content-Type": "application/json",
      "token": token ?? ""
    };
    Map<String, String> defaultHeaderForLiveAgent = {
      "Content-Type": "application/json",
      "token": token ?? "",
      "source_system": "merchant_app"
    };
    var header =
        isLiveAgentReq == true ? defaultHeaderForLiveAgent : defaultHeader;
   // print("Header - $defaultHeader");
    http.Response? response;
    try {
      switch (requestType) {
        case RequestType.get:
          response = await http.get(uri, headers: header);
          break;
        case RequestType.post:
          if (requestBody is http.MultipartRequest) {
            requestBody.headers.addAll(header);
            var streamedResponse = await requestBody.send();
            response = await http.Response.fromStream(streamedResponse);
          } else {
            response = await http.post(uri, body: requestBody, headers: header);
          }
          break;
        case RequestType.put:
          response = await http.put(uri, body: requestBody, headers: header);
          break;
        case RequestType.delete:
          response = await http.delete(uri, body: requestBody, headers: header);
          break;
      }
      print("Response Code - ${response.statusCode} and token is $token");
       print("Response Body - ${response.body}");
      EasyLoading.dismiss();
      return response;
    } catch (ex) {
      EasyLoading.dismiss();
      print("Network Error - $ex");
      return response;
    }
  }

 

  Future<http.Response?> requestwithouteasyloading(RequestType requestType, Uri uri,
      {dynamic requestBody = "", bool isLiveAgentReq = false}) async {
   //EasyLoading.show(dismissOnTap: true);
    print("Request - $requestType Url - $uri");
    print("RequestBody - $requestBody");
    String? token = await SharedPrefsHelper().getToken();
    sendTokenToCallLogReceiver(token);
    Map<String, String> defaultHeader = {
      "Content-Type": "application/json",
      "token": token ?? ""
    };
    Map<String, String> defaultHeaderForLiveAgent = {
      "Content-Type": "application/json",
      "token": token ?? "",
      "source_system": "merchant_app"
    };
    var header =
        isLiveAgentReq == true ? defaultHeaderForLiveAgent : defaultHeader;
   // print("Header - $defaultHeader");
    http.Response? response;
    try {
      switch (requestType) {
        case RequestType.get:
          response = await http.get(uri, headers: header);
          break;
        case RequestType.post:
          if (requestBody is http.MultipartRequest) {
            requestBody.headers.addAll(header);
            var streamedResponse = await requestBody.send();
            response = await http.Response.fromStream(streamedResponse);
          } else {
            response = await http.post(uri, body: requestBody, headers: header);
          }
          break;
        case RequestType.put:
          response = await http.put(uri, body: requestBody, headers: header);
          break;
        case RequestType.delete:
          response = await http.delete(uri, body: requestBody, headers: header);
          break;
      }
      // print("Response Code - ${response.statusCode} and token is $token");
      // print("Response Body - ${response.body}");
    //  EasyLoading.dismiss();
      return response;
    } catch (ex) {
     // EasyLoading.dismiss();
      print("Network Error - $ex");
      return response;
    }
  }}


const platform = const MethodChannel('com.example.myapp/callLog');
void sendTokenToCallLogReceiver(token) {
  try {
   // print(" sent to background $token /n/n//n/nn\\n\\n\\\n\nn\\?/n//n/n/n/n/nn");
    platform.invokeMethod('sendToken', {'token': token});
  } on PlatformException catch (e) {
 //   print("Failed to send token: '${e.message}'.");
  }
}























































// class NetworkHelper {
//   SnapPeNetworks snapPeNetworks =SnapPeNetworks();
//   Future<http.Response?> request(RequestType requestType, Uri uri,{dynamic requestBody = "",bool isLiveAgentReq = false,bool retry = true}) async {
//   EasyLoading.show(status: "Loading");
//   print("Request - $requestType Url - $uri");
//   print("RequestBody - $requestBody");
//   String? token = await SharedPrefsHelper().getToken();
//   sendTokenToCallLogReceiver(token);
//   Map<String, String> defaultHeader = {
//     "Content-Type": "application/json",
//     "token": token ?? ""
//   };
//   Map<String, String> defaultHeaderForLiveAgent = {
//     "Content-Type": "application/json",
//     "token": token ?? "",
//     "source_system": "merchant_app"
//   };
//   var header =
//       isLiveAgentReq == true ? defaultHeaderForLiveAgent : defaultHeader;
//   print("Header - $defaultHeader");
//   http.Response? response;
//   try {
//     switch (requestType) {
//       case RequestType.get:
//         response = await http.get(uri, headers: header);
//         break;
//       case RequestType.post:
//         if (requestBody is http.MultipartRequest) {
//           requestBody.headers.addAll(header);
//           var streamedResponse = await requestBody.send();
//           response = await http.Response.fromStream(streamedResponse);
//         } else {
//           response =
//               await http.post(uri, body: requestBody, headers: header);
//         }
//         break;
//       case RequestType.put:
//         response = await http.put(uri, body: requestBody, headers: header);
//         break;
//       case RequestType.delete:
//         response = await http.delete(uri, body: requestBody, headers: header);
//         break;
//     }
//     print("Response Code - ${response.statusCode}");
//     print("Response Body - ${response.body}");
//     Map<String, dynamic> responseBody = jsonDecode(response.body);
//     if (retry &&
//         responseBody["status"] == "ERROR" &&
//         responseBody["messages"] != null &&
//         responseBody["messages"].contains("Unauthorized access detected")) {
//       // The token has expired, so log the user back in
//       String? newToken = await snapPeNetworks.loginWithStoredCredentials();
//       if (newToken != null) {
//           await SharedPrefsHelper().setToken(newToken);
//         // Update the header with the new token
//         header["token"] = newToken;
//         print("new token is $newToken ");
//          sendTokenToCallLogReceiver(newToken);
//         // Retry the request with the updated header and retry set to false
//         return await request(requestType, uri,
//             requestBody: requestBody,
//             isLiveAgentReq: isLiveAgentReq,
//             retry: false);
//       }
//     }
//   } catch (ex) {
//     print("Network Error - $ex");
//   }
//   EasyLoading.dismiss();
//   return response;
// }

// }











// const platform = const MethodChannel('com.example.myapp/callLog');
// void sendTokenToCallLogReceiver(token) {
//     try {
//       print(" sent to background $token /n/n//n/nn\\n\\n\\\n\nn\\?/n//n/n/n/n/nn");
//         platform.invokeMethod('sendToken', {'token': token});
//     } on PlatformException catch (e) {
//         print("Failed to send token: '${e.message}'.");
//     }
// }