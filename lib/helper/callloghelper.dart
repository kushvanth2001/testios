import 'dart:convert'; // For JSON encoding/decoding


import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../utils/snapPeNetworks.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/networkConstants.dart';
import 'SharedPrefsHelper.dart';
import 'networkHelper.dart';

class CallLogHelper {



  static Future<bool> postCallsToFirstApi(Map<String,dynamic> prop) async {
   final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

    final SharedPreferences prefs = await _prefs;
  
     String? clientGroup =prefs.getString(NetworkConstants.CLIENT_GROUP_NAME);
         String? token = await prefs.getString(NetworkConstants.TOKEN);
         print(prop);
         print("https://retail.snap.pe/snappe-services/rest/v1/merchants/$clientGroup/filter-leads?page=0&size=20&sortBy=lastModifiedTime&sortOrder=DESC&mobileNumber=${prop['number'].contains('+')?prop['number'].substring(1):prop['number']}");
       var  header={ "Content-Type": "application/json",
      "token": token ?? ""};
         var url=Uri.parse( "https://retail.snap.pe/snappe-services/rest/v1/merchants/$clientGroup/filter-leads?page=0&size=20&sortBy=lastModifiedTime&sortOrder=DESC&mobileNumber=${prop['number'].contains('+')?prop['number'].substring(1):prop['number']}");
       

  
    try{
   var   response = await http.get(url, headers: header);

      // Check if the response is successful (status code 200)
      if (response==null?false:response.statusCode == 200) {
        // Parse the response JSON
        final Map<String,dynamic> jsonResponse = json.decode(response.body) as Map<String,dynamic>;
 print(jsonResponse);

        // Check if the "lead" property is not empty
        if (jsonResponse['leads'] != null && (jsonResponse['leads'] as List).isNotEmpty) {
                    Map<String,dynamic> leads=(jsonResponse['leads'] as List)[0];
         print("${leads['id']}");
         bool v=await postDataToSecondApi(prop,leads['id'].toString());
         if(v==true){
          return true;
         }else{
         return  false;
         }

        } else {
          
String? k=prefs.getString('storelocalnotlead');
if(k==null){
  Map<String,dynamic> l={};
List<dynamic> v=[];
v.add(prop);
 l[prop['number']] =v;
  print("storingthisinlocal$l");
  prefs.setString('storelocalnotlead',jsonEncode(l));
}else{
  Map<String, dynamic> l = jsonDecode(k);

  // Add 'prop' to the existing map
  List<dynamic> v=[];
v.add(prop);
  l[prop['number']]=v;
 l.containsKey(prop['number'])?l[prop['number']].add(prop) :l[prop['number']]= v;
 print("storingthisinlocal$l");
  // Encode the updated map and store it back in SharedPreferences
  prefs.setString('storelocalnotlead', jsonEncode(l));
    
}
  return true;
        }
      } else {
        
        print('Failed to post calls to the first API. Status code: ${response!.statusCode}');
        return false;
      }
    } catch (error) {
      print('Error posting calls to the first API: $error');
      return false;
    }
  }

  // Method to post data to the second API
  static Future<bool> postDataToSecondApi(Map<String,dynamic> leadData,String leadid) async {
  
   final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

    final SharedPreferences prefs = await _prefs;
  
     String? clientGroup =prefs.getString(NetworkConstants.CLIENT_GROUP_NAME);
         String? token = await prefs.getString(NetworkConstants.TOKEN);
  String clientphno=await "${prefs.getString(NetworkConstants.CLIENT_PHONE_NUMBER)}"??"91111111111";
  String clientname=  await prefs.getString("clientName") ?? "";
    DateTime starttimeinmill= DateTime .fromMillisecondsSinceEpoch(leadData["timestamp"]).toUtc();
     DateTime endtime = starttimeinmill.add(Duration(seconds:leadData["duration"]??0 )).toUtc();
  DateFormat formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
var body= {};
if(true)
body= {"status": "OK",
                                                        "isActive": true,
                                                        "startTime": "${starttimeinmill.toIso8601String()}",
                                                        "endTime": "${endtime.toIso8601String()}",
                                                        "leadId": leadid,
                                                        "callType": "call",
                                                        "statusName":capitalize( leadData["callType"]),
                                                        "fromNumber": clientphno,
                                                        "toNumber": leadData['number'].contains('+') ? leadData['number'].substring(1) : leadData['number']
,
                                                        "remarks": "",
                                                        "agentPhoneNumber":clientphno,
                                                        "agentName": clientname,
                                                        
                                                    };



else if(leadData["callType"].substring(leadData["callType"].length - 9).toLowerCase()=="Outgoing")
{


  body= {"status": "OK",
                                                        "isActive": true,
                                                        "startTime": "${formatter.format( DateTime.fromMillisecondsSinceEpoch(leadData["timestamp"]))}",
                                                        "endTime": "${formatter.format( endtime)}",
                                                        "leadId": leadid,
                                                        "callType": "call",
                                                        "statusName": leadData["callType"],
                                                        "fromNumber": leadData['number'],
                                                        "toNumber": clientphno,
                                                        "remarks": "",
                                                        "agentPhoneNumber":clientphno,
                                                        "agentName": clientname,
                                                        
                                                    };
}
else{


body={
                                                        "status": "OK",
                                                        "isActive": true,
                                                          "startTime": "${formatter.format( DateTime.fromMillisecondsSinceEpoch(leadData["timestamp"]))}",
                                                        "endTime": "${formatter.format( endtime)}",
                                                        "leadId": leadid,
                                                        "callType":"call",
                                                        "statusName": leadData["callType"],
                                                        "remarks": "",
                                                        "agentPhoneNumber":clientphno,
                                                        "agentName": clientname
                                                    };

}

         
         print("https://retail.snap.pe/snappe-services/rest/v1/merchants/$clientGroup/call-logs");
       var  header={ "Content-Type": "application/json",
      "token": token ?? ""};
         var url=Uri.parse( "https://retail.snap.pe/snappe-services/rest/v1/merchants/$clientGroup/call-logs") ;
       

    try {
    
   var   response = await http.post(url,body:jsonEncode( body) ,headers: header);

  


      // Perform the second API request with leadData

    
      if (response==null?false:response.statusCode == 200) {
        print("${jsonDecode(response.body)}");
                print('Data successfully posted to the second API.');
        return true;

      } else {
         print('Failed to post data to the second API. Status code: ${response!.statusCode}');
        return false;
       
      }
    } catch (error) {
         print('Error posting data to the second API: $error');
      return false;
   
    }
  }

static Future<bool> checkInternetConnectivity() async {
  var connectivityResult = await Connectivity().checkConnectivity();

  if (connectivityResult == ConnectivityResult.none) {
    return false;
    print('No internet connection');
  } else if (connectivityResult == ConnectivityResult.mobile) {
    print('Mobile data connection');
    return true;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    return true;
  }else{
    return false;
  }
}

}
String capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);