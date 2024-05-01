import 'dart:convert';
import 'dart:core';


import 'package:custom_searchable_dropdown/custom_searchable_dropdown.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:multi_select_flutter/dialog/mult_select_dialog.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../Controller/chat_controller.dart';
import '../../constants/colorsConstants.dart';
import '../../constants/networkConstants.dart';
import '../../helper/SharedPrefsHelper.dart';
import '../../helper/networkHelper.dart';
import '../../models/model_CreateNote.dart';
import '../../models/model_Merchants.dart';
import '../../models/model_application.dart';
import '../../models/model_callstatus.dart';
import '../../models/model_chat.dart';
import '../../models/model_lead.dart';
import '../../models/model_tags.dart';
import '../../utils/SharedFunctions.dart';
import '../../utils/snapPeNetworks.dart';
import '../chat/chatDetailsScreen.dart';
import 'callLogsScreen.dart';
import 'leadDetails/leadDetails.dart';
import 'leadNotesScreen.dart';
import 'quickResponse/QuickPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Controller/leads_controller.dart';
import '../../constants/styleConstants.dart';

class LeadWidget extends StatefulWidget {
  final VoidCallback onBack;
  final Lead lead;
  final AssignedTo? assignedTo;
  final LeadController leadController;
  final String? firstAppName;
  final String? liveAgentUserName;
final Color? color;
  bool isNewleadd;
  final List<CallStatus> statusList;

  final List<ChatModel>? chatModels;
  LeadWidget({
    Key? key,
    required this.onBack,
    this.firstAppName,
    required this.liveAgentUserName,
    required this.lead,
    required this.leadController,
    this.assignedTo,
    required this.isNewleadd,
    required this.statusList,
    this.chatModels, this.color,
  }) : super(key: key);

  @override
  State<LeadWidget> createState() => _LeadWidgetState();
}

class _LeadWidgetState extends State<LeadWidget> {
  LeadController leadController=LeadController();
  late final SharedFunctions sharedFunctions;
  // Define a MethodChannel with a unique name
  static const platform = MethodChannel('com.example.myapp/callLog');
  // Invoke the getCallInfo method in the platform-specific code
  Future<Map<String, dynamic>?> getCallInfo(String phoneNumber) async {
    try {
      final result = (await platform.invokeMethod<Map<dynamic, dynamic>>(
              'getCallInfo', phoneNumber))
          ?.map((key, value) => MapEntry(key.toString(), value));

      return result;
    } on PlatformException catch (e) {
      // Handle the exception
      return null;
    }
  }

  List<CallStatus> _statusList = [];
  @override
  void initState() {
    super.initState();
    sharedFunctions = SharedFunctions(
      liveAgentUserName: widget.liveAgentUserName,
      leadController: widget.leadController,
      lead: widget.lead,
      chatModels: widget.chatModels,
      firstAppName: widget.firstAppName,
    );
   // print("${widget.firstAppName} in leadswidget \n\n\\n\n\\n\\n\n\\n\n");

// Fetch the list of call status objects and update the state
    _statusList = widget.statusList;
  }

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();
    final TextEditingController txtFollowUpName = new TextEditingController(
        text: 'Follow Up with ${widget.lead.customerName}');
    final TextEditingController txtDescription = new TextEditingController();
    final TextEditingController txtDateTime =
        new TextEditingController(text: DateTime.now().toString());
    // var leadController=widget.leadController;

    DateTime parsedDate = DateTime.parse(widget.lead.createdOn.toString());
    String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
    return InkWell(
      onTap: () async{

SharedPreferences prefs=await SharedPreferences.getInstance();
        widget.leadController.inlightlead.value=widget.lead.id??0;
      widget.leadController.scrolloffset.value=widget.leadController.scrollController.offset;
prefs.setInt('leadid',widget.lead.id??0);

print(  widget.leadController.scrolloffset);
        Get.to(() => LeadDetails(
              onBack: widget.onBack,
              openAssignTagsDialog: openAssignTagsDialog,
              menuItems: popUpMenu,
              leadController: widget.leadController,
              leadId: widget.lead.id,
              lead: widget.lead,
              chatModels: widget.chatModels,
              firstAppName: widget.firstAppName,
              isNewleadd: widget.isNewleadd,
              buildTags: buildTags,
              textController: textController,
              txtFollowUpName: txtFollowUpName,
              txtDescription: txtDescription,
              txtDateTime: txtDateTime,
            ));
      },
      child:  Obx(() =>
         Card(
          color:widget.leadController.inlightlead.value==widget.lead.id?Colors.blue.shade200:Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 10,
          child: Padding(
            padding:
                const EdgeInsets.only(bottom: 3, top: 12, left: 12, right: 12),
            child: Column(
              children: [
                //Row 1
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 7,
                      child: Text(
                        "${widget.lead.customerName ?? widget.lead.mobileNumber ?? ""}",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: kMediumFontSize,
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 3,
                      child: Text(
                        "${widget.lead.leadStatus?.statusName ?? ""}",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: kSmallFontSize,
                        ),
                      ),
                    )
                  ],
                ),
                //Row 2
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 2),
                      child: Text(
                        "${widget.lead.organizationName ?? ""}",
                        //|  ${order.customerNumber}
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: kMediumFontSize,
                            color: kBlackColor.withOpacity(0.7)),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        popUpMenu(textController, txtFollowUpName, txtDescription,
                            txtDateTime)
                      ]),
                ),
                //Row 3
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 5,
                      child: Text(
                        "${widget.lead.assignedTo?.userName ?? ""}",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.withOpacity(0.6),
                          fontWeight: FontWeight.w600,
                          fontSize: kSmallFontSize,
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 5,
                      child: Text(
                        "${formattedDate ?? ""}",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.withOpacity(0.6),
                          fontWeight: FontWeight.bold,
                          fontSize: kSmallFontSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildTags(
      textController, txtFollowUpName, txtDescription, txtDateTime) {
    List<Widget> tagsList = [];

    if (widget.lead.tagsDto != null && widget.lead.tagsDto!.tags!.length != 0) {
      int len = widget.lead.tagsDto!.tags!.length;
      for (int i = 0; i < len; i++) {
        tagsList.add(
          Container(
              child: Chip(
            label: Text(
              "${widget.lead.tagsDto!.tags![i].name ?? ""}",
              style: TextStyle(color: Colors.white, fontSize: kSmallFontSize),
            ),
            backgroundColor: widget.lead.tagsDto?.tags![i].color == null
                ? Colors.grey
                : HexColor(widget.lead.tagsDto!.tags![i].color!),
          )),
        );
      }
    }
    tagsList.add(
      IconButton(
        icon: Icon(
          Icons.add_circle_outline_outlined,
          color: Colors.black,
        ),
        onPressed: () {
          openAssignTagsDialog(context);
        },
      ),
    );
    // tagsList.add(popUpMenu(textController, txtFollowUpName, txtDescription, txtDateTime));

    return tagsList;
  }

  popUpMenu(textController, txtFollowUpName, txtDescription, txtDateTime) {
    final chatModel = widget.chatModels?.firstWhereOrNull(
      (chat) => chat.customerNo == widget.lead.mobileNumber,
    );

    return Row(
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Color.fromARGB(255, 235, 235, 235),
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: IconButton(
                icon: Image.asset(
                  "assets/icon/send.png",
                  width: 25,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuickResponsePage(
                          widget.lead.customerName, widget.lead.mobileNumber,
                          onBack: widget.onBack,
                          leadController: widget.leadController),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 4),

            Container(
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 235, 235, 235),
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: IconButton(
                  icon: Image.asset(
                    "assets/icon/note.png",
                    width: 20,
                  ),
                  onPressed: () {
                    Get.back();

                    // openCreateNoteDialog(textController);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LeadNotesScreen(
                              leadId: widget.lead.id,
                              leadController: widget.leadController,
                              onBack: widget.onBack)),
                    );
                  },
                )),
            SizedBox(width: 4),
            Container(
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 235, 235, 235),
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: IconButton(
                  icon: Image.asset(
                    "assets/icon/follow-up.png",
                    width: 20,
                  ),
                  onPressed: () {
                    Get.back();

                    openFollowUpDialog(
                        context, txtFollowUpName, txtDescription, txtDateTime);
                  },
                )),
            SizedBox(width: 4),

            // if (widget.lead.mobileNumber != null)

            Container(
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 235, 235, 235),
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: IconButton(
                  icon: Image.asset(
                    "assets/icon/telephone.png",
                    width: 27,
                  ),
                  onPressed: () async {
                    if (await Permission.phone.request().isGranted) {
                      // Permission was granted

                      pressCallButton();

                      Get.back();
                    } else {
                      // Permission was denied

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Permission required"),
                          content: Text(
                              "This app needs access to call logs to function properly."),
                          actions: [
                            TextButton(
                              child: Text("Grant permission"),
                              onPressed: () async {
                                Navigator.of(context).pop();

                                openAppSettings();
                              },
                            ),
                            TextButton(
                              child: Text("Cancel"),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                )),
            SizedBox(width: 4),

            //  if (widget.lead.mobileNumber != null)

            Container(
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 235, 235, 235),
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: IconButton(
                  icon: Image.asset(
                    "assets/icon/whatsappIcon.png",
                    width: 24,
                  ),
                  onPressed: () {
                    Get.back();

                    btnWhatsapp();
                  },
                )),
            SizedBox(width: 4),
            // if (widget.lead.mobileNumber != null)
            //   Container(
            //       decoration: BoxDecoration(
            //           color: Color.fromARGB(255, 235, 235, 235),
            //           borderRadius: BorderRadius.all(Radius.circular(20))),
            //       child: IconButton(
            //         icon: Image.asset("assets/icon/chat.png", width: 22),
            //         onPressed: () {
            //           Get.back();

            //           print(
            //               'chatModel: ${widget.chatModels} and ${widget.lead.mobileNumber}');
            //           for (final chatModel in widget.chatModels ?? []) {
            //             print('customerNo: ${chatModel}');
            //           }
            //           if (widget.chatModels != null &&
            //               widget.chatModels!.isNotEmpty) {
            //             final firstChatModel = widget.chatModels!.first;
            //             print('First ChatModel:');
            //             print('  id: ${firstChatModel.id}');
            //             if (firstChatModel.id != null) {
            //               print('First ChatModel id:');
            //               // Replace 'property1', 'property2', etc. with the actual property names of the Id class
            //               print(
            //                   '  property1: ${firstChatModel.id?.customerNo}');
            //               // ...
            //             }
            //             print('  businessNo: ${firstChatModel.businessNo}');
            //             print('  customerName: ${firstChatModel.customerName}');
            //             print('  customerNo: ${firstChatModel.customerNo}');
            //             print('  lastTs: ${firstChatModel.lastTs}');
            //             print('  messages: ${firstChatModel.messages}');
            //             print(
            //                 '  multiTenantContext: ${firstChatModel.multiTenantContext}');
            //             print(
            //                 '  overrideStatus: ${firstChatModel.overrideStatus}');
            //           }

            //           print("chatModel isss: ${chatModel}");
            //           print("firstName isss: ${widget.firstAppName}");

            //           if (chatModel != null) {
            //             Navigator.push(
            //               context,
            //               MaterialPageRoute(
            //                   builder: (context) => ChatDetailsScreen(
            //                         firstAppName: widget.firstAppName,
            //                         chatModel: chatModel,
            //                         isOther: false,
            //                         leadController: widget.leadController,
            //                         isFromLeadsScreen: true,
            //                       )),
            //             );
            //           } else {
            //             ChatModel newChatModel = ChatModel(
            //               id: Id(customerNo: widget.lead.mobileNumber),
            //               businessNo: "",
            //               customerName: widget.lead.customerName,
            //               customerNo: widget.lead.mobileNumber,
            //               lastTs: DateTime.now().toUtc().toIso8601String(),
            //               messages: [],
            //               multiTenantContext: 'context',
            //               overrideStatus: OverrideStatus(agentOverride: 1),
            //             );
            //             print(
            //                 "${DateTime.now().toUtc().toIso8601String()} is lastTs");
            //             Navigator.push(
            //               context,
            //               MaterialPageRoute(
            //                   builder: (context) => ChatDetailsScreen(
            //                         firstAppName: widget.firstAppName,
            //                         chatModel: newChatModel,
            //                         isOther: false,
            //                         leadController: widget.leadController,
            //                         isFromLeadsScreen: true,
            //                       )),
            //             );
            //           }
            //         },
            //       )),
          ],
        )
      ],
    );
  }

  void conversations(BuildContext context) {
    // Navigator.push(context, MaterialPageRoute(builder: (context) {
    //   return Scaffold(
    //     appBar: AppBar(
    //       title: Container(
    //         decoration: BoxDecoration(
    //           color: Colors.white,
    //           borderRadius: BorderRadius.circular(10),
    //           border: Border.all(
    //             width: 1,
    //           ),
    //         ),
    //         child: DropdownButton<String>(
    //           value: _selectedApplicationName,
    //           icon: const Icon(Icons.arrow_drop_down),
    //           onChanged: (value) {
    //             setState(() {
    //               _selectedApplicationName = value;
    //             });
    //           },
    //           items: _applicationNames.map((appName) {
    //             return DropdownMenuItem<String>(
    //               value: appName,
    //               child: Text(appName!),
    //             );
    //           }).toList(),
    //         ),
    //       ),
    //     ),
    //     body: ListView.builder(
    //       itemCount: 5,
    //       itemBuilder: (BuildContext context, int index) {
    //         return ListTile(
    //           title: Text("Hey"),
    //           // subtitle: Text("Hi"),
    //           trailing: Text("HI"),
    //           onTap: () {
    //             // navigate to conversation detail page
    //           },
    //         );
    //       },
    //     ),
    //   );
    // }));
  }
String onextraString(String k){

if(k.startsWith('+033') && k.length>12){
return k.substring(4);
}
else if(k.startsWith('033') && k.length>12){
return k.substring(3);
}else{
  return k;
}}
  pressCallButton() async {
    var url = "tel:+${widget.lead.mobileNumber!=null? onextraString(widget.lead.mobileNumber!):"" }";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  showdialogBox() async {
    String phoneNumber = widget.lead.mobileNumber?.toString() ?? "";
    Map<String, dynamic>? callInfo = await getCallInfo(phoneNumber);
    String? callDuration = callInfo?["duration"];
    String? callTime = callInfo?["time"];

    if (callDuration == null || callTime == null) {
      // Handle the situation when callDuration or callTime is null
      // For example, you could show an error message to the user
      print("Error: Call duration or call time is null");
      Navigator.of(context).pop();
      return;
    }

    int timestamp = int.parse(callTime);
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);

    var formatter = DateFormat('MMM d, y, h:mm:ss a');
    String formattedDate = formatter.format(date);

    int duration = int.parse(callDuration);

    int hours = duration ~/ 3600;
    int minutes = (duration % 3600) ~/ 60;
    int seconds = duration % 60;

    String formattedDuration = '$hours:$minutes:$seconds';

    print("$callDuration");
    print("$callTime");
    TextEditingController callTimeController =
        TextEditingController(text: formattedDate);
    TextEditingController callDurationController =
        TextEditingController(text: formattedDuration);
    TextEditingController remarksController = TextEditingController();
    final _statusController = TextEditingController();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Call Logs"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                enabled: false,
                controller: callTimeController,
                decoration: InputDecoration(labelText: "Call Time"),
              ),
              TextField(
                enabled: false,
                controller: callDurationController,
                decoration: InputDecoration(labelText: "Call Duration"),
              ),
              DropdownButtonFormField(
                items: _statusList
                    .map<DropdownMenuItem<int>>((item) => DropdownMenuItem<int>(
                          value: item.id,
                          child: Text(item.statusName),
                        ))
                    .toList(),
                onChanged: (int? value) {
                  // Find the selected call status object
                  final selectedStatus =
                      _statusList.firstWhere((status) => status.id == value);

                  // Update the controller with the selected status name
                  _statusController.text = selectedStatus.statusName;
                },
                decoration: InputDecoration(labelText: "Call Status Check"),
              ),
              TextField(
                controller: remarksController,
                decoration: InputDecoration(labelText: "Remarks"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await SnapPeNetworks().createLeadNotes(
                  widget.lead.id,
                  CreateNote(
                      remarks:
                          "<b>Call Records<b><br><br> Call Time : $formattedDate <br> Call Duration :   $formattedDuration<br> Status :  ${_statusController.text}<br> Remarks : ${remarksController.text}"),
                );
                Get.back();
                Navigator.of(context).pop();
              },
              child: Text("OKAY"),
            ),
          ],
        );
      },
    );
  }

  Future<void> btnWhatsapp() async {
  
  const String phoneNumber = "1234567890"; // Replace with the desired phone number

  // final AndroidIntent intent = AndroidIntent(
  //   action: 'action_view',
  
  //   package: 'com.whatsapp', // Package name for WhatsApp Business
  //   flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
  // );

  // await intent.launch();

    var url = NetworkConstants.getWhatsappUrl(
        "${widget.lead.mobileNumber}".removeAllWhitespace.replaceAll("+", ""));
    if (await canLaunch(url)) {
      await launch(url, enableJavaScript: true, enableDomStorage: true);
    }
  }

  Widget iconText(Icon iconWidget, Text textWidget) {
    return Row(
      children: [iconWidget, SizedBox(width: 5), textWidget],
    );
  }

  openCreateNoteDialog(TextEditingController textController) {
    return Get.defaultDialog(
      title: "Create Note",
      content: Column(
        children: [
          TextField(
            controller: textController,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: kPrimaryColor))),
            maxLines: 10,
            maxLength: 200,
            keyboardType: TextInputType.multiline,
          )
        ],
      ),
      textConfirm: "Save",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        widget.leadController.createNote(widget.lead.id, textController.text);
        Get.back();
      },
      onCancel: () {},
    );
  }

  void openFollowUpDialog(
    context,
    TextEditingController txtFollowUpName,
    TextEditingController txtDescription,
    TextEditingController txtDateTime,
  ) {
    // String userIdd = SharedPrefsHelper().getMerchantUserId() ?? "";

    // int? userid = int.parse(userIdd);
    // User? user = widget.leadController.assignedTo.value
    //     .firstWhereOrNull((user) => user.userId == userid);
   Map<String,dynamic> _selectedassignto={};
   bool setvalue=false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 5,
          backgroundColor: Colors.white,
          child: Container(
            height: 402, // Adjust as needed
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DateTimePicker(
                    controller: txtDateTime,
                    type: DateTimePickerType.dateTime,
                    dateMask: 'd MMM, yyyy - HH:mm',
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    icon: Icon(Icons.event),
                    dateLabelText: 'Date',
                    timeLabelText: "Hour",
                    onChanged: (val) {
                      print(val);
                    },
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: txtFollowUpName,
                    decoration: InputDecoration(
                        labelText: 'Follow Up Name',
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: kPrimaryColor))),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: txtDescription,
                    decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: kPrimaryColor))),
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                  ),
                  SizedBox(height: 5),
                  AssignedToDialog(
                      leadController: widget.leadController,
                      liveAgentUserName: widget.liveAgentUserName, onItemSelected: (value) {setState(() {
                        _selectedassignto=value;
                        print(_selectedassignto);
                        setvalue=true;
                      }); },),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.redAccent, // Background color
                            onPrimary: Colors.white, // Text color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: EdgeInsets.all(12.0),
                          ),
                          onPressed: () async {
                            print("${widget.liveAgentUserName} id");
                            Navigator.of(context).pop();
                          },
                          child: Text("      Cancel      ",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                   Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                                255, 23, 151, 255), // Background color
                            foregroundColor: Colors.white, // Text color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: EdgeInsets.all(12.0),
                          ),
                          onPressed: () async {
                            if(_selectedassignto.length!=0){
                            widget.leadController.addFollowUp(
                                widget.lead.id,
                                txtFollowUpName.text,
                                txtDescription.text,
                                txtDateTime.text,_selectedassignto);
                           Navigator.of(context).pop();
                            }else{
                              Fluttertoast.showToast(msg: "Add a Assigned To Value");
                            }
                          },
                          child: Text("  Add Follow Up  ",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // openFollowUpDialog(TextEditingController txtFollowUpName,
  //     TextEditingController txtDescription, TextEditingController txtDateTime) {
  //   return Get.defaultDialog(
  //     title: "Add Follow Up",
  //     content: Column(
  //       children: [
  //         DateTimePicker(
  //           controller: txtDateTime,
  //           type: DateTimePickerType.dateTime,
  //           dateMask: 'd MMM, yyyy - HH:mm',
  //           firstDate: DateTime(2000),
  //           lastDate: DateTime(2100),
  //           icon: Icon(Icons.event),
  //           dateLabelText: 'Date',
  //           timeLabelText: "Hour",
  //           onChanged: (val) {
  //             print(val);
  //           },
  //         ),
  //         SizedBox(height: 10),
  //         TextField(
  //           controller: txtFollowUpName,
  //           decoration: InputDecoration(
  //               labelText: 'Follow Up Name',
  //               enabledBorder: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(10.0),
  //                   borderSide: BorderSide(color: kPrimaryColor))),
  //         ),
  //         SizedBox(height: 10),
  //         TextField(
  //           controller: txtDescription,
  //           decoration: InputDecoration(
  //               labelText: 'Description',
  //               border: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(10.0),
  //                   borderSide: BorderSide(color: kPrimaryColor))),
  //           maxLines: 3,
  //           maxLength: 30,
  //           keyboardType: TextInputType.multiline,
  //         ),
  //         SizedBox(height: 10),
  //         // assignedByDDL(),
  //         AssignedToDialog(leadController: widget.leadController),
  //         SizedBox(height: 10),
  //       ],
  //     ),
  //     textConfirm: "Add",
  //     confirmTextColor: Colors.white,
  //     onConfirm: () async {
  //       widget.leadController.addFollowUp(widget.lead.id, txtFollowUpName.text,
  //           txtDescription.text, txtDateTime.text);
  //       Get.back();
  //     },
  //     onCancel: () {},
  //   );
  // }

  // String _selectedItem = 'Select AssignedTo';

  // assignedByDDL() {
  //   var items = widget.leadController.assignedTo.value
  //       .map<DropdownMenuItem<String>>((user) {
  //     return DropdownMenuItem<String>(
  //       value: "${user.firstName} ${user.lastName}",
  //       child: Text("${user.firstName} ${user.lastName}"),
  //     );
  //   }).toList();

  //   // Add 'Select AssignedTo' item to the list
  //   items.insert(
  //       0,
  //       DropdownMenuItem<String>(
  //         value: 'Select AssignedTo',
  //         child: Text('Select AssignedTo'),
  //       ));

  //   return DropdownButton<String>(
  //     value: _selectedItem,
  //     icon: Icon(Icons.arrow_downward),
  //     iconSize: 24,
  //     elevation: 16,
  //     style: TextStyle(color: Colors.deepPurple),
  //     underline: Container(
  //       height: 2,
  //       color: Colors.deepPurpleAccent,
  //     ),
  //     onChanged: (String? newValue) {
  //       if (newValue != null && newValue != 'Select AssignedTo') {
  //         setState(() {
  //           _selectedItem = newValue;
  //           widget.leadController.taskModel.assignedTo =
  //               widget.leadController.assignedTo.value.firstWhere(
  //                   (user) => "${user.firstName} ${user.lastName}" == newValue);
  //         });
  //       }
  //     },
  //     items: items,
  //   );
  // }

  String _selectedItem = 'Select AssignedTo';

  assignedByDDL() {
    return CustomSearchableDropDown(
      initialValue: [ widget.leadController.assignedTo.value[0]],
      items: widget.leadController.assignedTo.value,
      label: "$_selectedItem",
      initialIndex: 0,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all()),
      prefixIcon: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Icon(Icons.search),
      ),
      dropDownMenuItems: widget.leadController.assignedTo.value.map((user) {
           print("namecheck${user.firstName} ${user.lastName}");
        return "${user.firstName} ${user.lastName}";
     
      }).toList(),
      onChanged: (user) {
        if (user != null) {
          widget.leadController.taskModel.assignedTo = user;
          print("${user.firstName} ${user.lastName}");
          setState(() {
            _selectedItem = "${user.firstName} ${user.lastName}";
          });
        } else {
    
       
          widget.leadController.taskModel.assignedTo = null;
          setState(() {
            _selectedItem = 'Select AssignedTo';
          });
        }
      },
    );
  }

  var assignedTags;
  void openAssignTagsDialog(BuildContext context) async {
    widget.leadController.selectedAssignTags.value.clear();
    await showDialog(
      context: context,
      builder: (ctx) {
        return FutureBuilder(
          future: widget.leadController.getAssignTags(widget.lead.id!),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            return Obx(
              () => MultiSelectDialog(
                searchable: true,
                separateSelectedItems: true,
                unselectedColor: Colors.grey.withOpacity(0.1),
                listType: MultiSelectListType.CHIP,
                items: widget.leadController.tags
                    .map((e) => MultiSelectItem(e, e.name!))
                    .toList(),
                initialValue: widget.leadController.selectedAssignTags.value,
                onConfirm: (List<Tag> values) {
                  print("Values length = ${values.length}");
                  widget.leadController.selectedAssignTags.value.clear();
                  print(
                      "selectedAssignTags length = ${widget.leadController.selectedAssignTags.value.length}");
                  widget.leadController.selectedAssignTags.addAll(values);
                  print(
                      "=> selectedAssignTags length = ${widget.leadController.selectedAssignTags.value.length}");
                  assignedTags = values;
                  addTags(widget.lead.id, assignedTags);
                  widget.leadController.loadData(forcedReload: true);
                },
              ),
            );
          },
        );
      },
    );
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    try {
      hexColor = hexColor.toUpperCase().replaceAll("#", "");
      if (hexColor.length == 6) {
        hexColor = "FF" + hexColor;
      }
      return int.parse(hexColor, radix: 16);
    } catch (ex) {
      print("Error Tags color code is String - $hexColor");
      return int.parse("FFF44336", radix: 16); //Default Color Red
    }
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

Future<void> addTags(leadid, List<Tag> assignedTags) async {
  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
  List<Map<String, dynamic>> tagsData = assignedTags.map((tag) {
    return {
      "status": "OK",
      "messages": [],
      "id": tag.id,
      "name": tag.name,
      "type": "lead",
      "clientGroupId": "",
      "color": tag.color,
      "description": tag.description,
      "isLeadTag": null,
      "createdOn": "",
    };
  }).toList();

  // Create the request data
  Map<String, dynamic> requestData = {"tags": tagsData};
  final response = await NetworkHelper().request(
      RequestType.put,
      Uri.parse(
          'https://retail.snap.pe/snappe-services/rest/v1/merchants/$clientGroupName/tag/$leadid'),
      requestBody: jsonEncode(requestData));

  if (response != null && response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load data');
  }
}

class AssignedToDialog extends StatefulWidget {
  final LeadController leadController;
  final String? liveAgentUserName;
    final void Function(Map<String,dynamic> selectedItem) onItemSelected; 
  AssignedToDialog(
      {required this.leadController, required this.liveAgentUserName, required this.onItemSelected});

  @override
  _AssignedToDialogState createState() => _AssignedToDialogState();
}

class _AssignedToDialogState extends State<AssignedToDialog> {
  
  String _selectedItem = 'Assign To';
  int _selectedId=0;
  @override
  void initState() {
   
    super.initState();
    // Check if liveAgentUserName exists in the list and set it as the initial value
    if (widget.liveAgentUserName != null &&
        widget.leadController.assignedTo.value
            .map((user) => "${user.firstName} ${user.lastName}")
            .toSet()
            .contains(widget.liveAgentUserName)) {
      _selectedItem = widget.liveAgentUserName!;
       getdata();
      print("${widget.liveAgentUserName} from init");
    }
  }
getdata()async{
  var k=await SharedPrefsHelper().getMerchantUserId();
  int? liveAgentUserId = int.tryParse(k);
  setState(() {
    _selectedId=liveAgentUserId??0;
  });
}
  @override
  Widget build(BuildContext context) {
    // Get a list of unique dropdown items.


    Map<String, dynamic> userMap = Map.fromIterable(
  widget.leadController.assignedTo.value,
  key: (user) => "${user.firstName} ${user.lastName}",
  value: (user) =>{ "userId":user.userId,"id":user.id}

);
    List<String> uniqueItems = widget.leadController.assignedTo.value
        .map((user) => "${user.firstName} ${user.lastName}")
        .toSet()
        .toList();
        setState(() {
          _selectedId=userMap[_selectedItem]["id"];
          
        });
         
print("usermap"+userMap.toString());
    return Container(
      width: 250.0,
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all()),


      child: DropdownButtonHideUnderline(
        
        child:DropDownTextField(
          
          textFieldDecoration: InputDecoration(hintText: "Select Assigned To") ,
        clearOption: false,
          dropDownList: [
                  ... userMap.entries.map((entry) {
  return DropDownValueModel(
    value: entry.value,
    name: entry.key,
  );
})
        ],
        onChanged: (value) {
           if (value != null && value != '') {
              setState(() {
                _selectedItem = value.name;
                _selectedId=value.value["id"]??0;
                print({"status":"OK",
      "messages":[],
    

         "userName":_selectedItem,
      "userId":_selectedId,
      "id":userMap[_selectedItem]["id"]
      });
               widget.onItemSelected(  {"status":"OK",
      "messages":[],
    

         "userName":_selectedItem,
      "userId":userMap[_selectedItem]["userId"],
      "id":_selectedId
      }); 
              });
              
            } else {
              setState(() {
                _selectedItem = 'Assign To';
              });
            }
          
        },
        )
        
        
        
       
      ),
    );
  }
}
