import 'package:custom_searchable_dropdown/custom_searchable_dropdown.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/colorsConstants.dart';
import '../constants/networkConstants.dart';
import '../constants/styleConstants.dart';
import '../helper/SharedPrefsHelper.dart';
import '../models/model_Merchants.dart';
import '../models/model_chat.dart';
import '../Controller/leads_controller.dart';
import '../models/model_lead.dart';
import 'package:multi_select_flutter/dialog/mult_select_dialog.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import '../views/chat/chatDetailsScreen.dart';
import '../views/leads/leadDetails/appController.dart';
import '../views/leads/leadNotesScreen.dart';
import '../views/leads/leadsWidget.dart';
import '../views/leads/quickResponse/QuickPage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../globals.dart';

class SharedFunctions {
  final LeadController leadController;
  final Lead lead;
  final List<ChatModel>? chatModels;
  final VoidCallback? onBack;
  final String? firstAppName;
  final String? liveAgentUserName;
  SharedFunctions({
    required this.leadController,
    required this.lead,
    this.chatModels,
    this.onBack,
    this.firstAppName,
    required this.liveAgentUserName,
  });

  var assignedTags;
  void openAssignTagsDialog(BuildContext context) async {
    leadController.selectedAssignTags.value.clear();
    await showDialog(
      context: context,
      builder: (ctx) {
        return FutureBuilder(
          future: leadController.getAssignTags(lead.id!),
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
                items: leadController.tags
                    .map((e) => MultiSelectItem(e, e.name!))
                    .toList(),
                initialValue: leadController.selectedAssignTags.value,
                onConfirm: (List<Tag> values) async {
                  print("Values length = ${values.length}");
                  leadController.selectedAssignTags.value.clear();
                  print(
                      "selectedAssignTags length = ${leadController.selectedAssignTags.value.length}");
                  leadController.selectedAssignTags.addAll(values);
                  print(
                      "=> selectedAssignTags length = ${leadController.selectedAssignTags.value.length}");
                  assignedTags = values;
                  addTags(lead.id, assignedTags);
                  await leadController.loadData(forcedReload: true);
                  // Get.find<AppController>().updateTags();
                  // Update the value of the tagsUpdated property to trigger a rebuild
                  // tagsUpdated.value = true;
                  // updateTags.call();
                  print('tagsUpdated: ${tagsUpdated.value}');
                  print(
                      "onTagsUpdated before n/n/n/n/n/n//n/n//nn \n\n\n\\nn\\n\n\n\\n\\n\n\n\n\n\n\\n\\n\n\n");
                  leadController.tagsUpdated.value = true;
                  print(
                      "leadController.tagsUpdated.value :${leadController.tagsUpdated.value}");
                },
              ),
            );
          },
        );
      },
    );
  }

  //Function 2

  Widget popUpMenu(
      BuildContext context,
      TextEditingController textController,
      TextEditingController txtFollowUpName,
      TextEditingController txtDescription,
      TextEditingController txtDateTime,
      {isFromChat = false}) {
    final chatModel = chatModels?.firstWhereOrNull(
      (chat) => chat.customerNo == lead.mobileNumber,
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
                          lead.customerName, lead.mobileNumber,
                          onBack: onBack, leadController: leadController),
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
                              leadId: lead.id,
                              leadController: leadController,
                              onBack: onBack)),
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
            // if (lead.mobileNumber != null && isFromChat != true)
            //   Container(
            //       decoration: BoxDecoration(
            //           color: Color.fromARGB(255, 235, 235, 235),
            //           borderRadius: BorderRadius.all(Radius.circular(20))),
            //       child: IconButton(
            //         icon: Image.asset("assets/icon/chat.png", width: 22),
            //         onPressed: () {
            //           Get.back();

            //           print(
            //               'chatModel: ${chatModels} and ${lead.mobileNumber}');
            //           for (final chatModel in chatModels ?? []) {
            //             print('customerNo: ${chatModel}');
            //           }
            //           if (chatModels != null && chatModels!.isNotEmpty) {
            //             final firstChatModel = chatModels!.first;
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
            //           print("firstName isss: $firstAppName");

            //           if (chatModel != null) {
            //             Navigator.push(
            //               context,
            //               MaterialPageRoute(
            //                   builder: (context) => ChatDetailsScreen(
            //                         firstAppName: firstAppName,
            //                         chatModel: chatModel,
            //                         isOther: false,
            //                         isFromLeadsScreen: true,
            //                         leadController: leadController,
            //                       )),
            //             );
            //           } else {
            //             ChatModel newChatModel = ChatModel(
            //               id: Id(customerNo: lead.mobileNumber),
            //               businessNo: "",
            //               customerName: lead.customerName,
            //               customerNo: lead.mobileNumber,
            //               lastTs: DateTime.now().toUtc().toIso8601String(),
            //               leadId: lead.id,
            //               messages: [],
            //               multiTenantContext: 'context',
            //               overrideStatus: OverrideStatus(agentOverride: 1),
            //             );
            //             print("new chat is $newChatModel");
            //             print(
            //                 "${DateTime.now().toUtc().toIso8601String()} is lastTs");
            //             Navigator.push(
            //               context,
            //               MaterialPageRoute(
            //                   builder: (context) => ChatDetailsScreen(
            //                         firstAppName: firstAppName,
            //                         chatModel: newChatModel,
            //                         isOther: false,
            //                         isFromLeadsScreen: true,
            //                         leadController: leadController,
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

  Future<void> btnWhatsapp() async {
    var url = NetworkConstants.getWhatsappUrl(
        "${lead.mobileNumber}".removeAllWhitespace.replaceAll("+", ""));
    if (await canLaunch(url)) {
      await launch(url, enableJavaScript: true, enableDomStorage: true);
    }
  }

  pressCallButton() async {
    var url = "tel:+${lead.mobileNumber !=null? onextraString(lead.mobileNumber!):""}";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
String onextraString(String k){

if(k.contains('+033')){
return k.substring(3);
}
else if(k.contains('033')){
return k.substring(2);
}else{
  return k;
}

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
  //         assignedByDDL(),
  //         SizedBox(height: 10),
  //       ],
  //     ),
  //     textConfirm: "Add",
  //     confirmTextColor: Colors.white,
  //     onConfirm: () async {
  //       leadController.addFollowUp(lead.id, txtFollowUpName.text,
  //           txtDescription.text, txtDateTime.text);
  //       Get.back();
  //     },
  //     onCancel: () {},
  //   );
  // }
  void openFollowUpDialog(context, TextEditingController txtFollowUpName,
      TextEditingController txtDescription, TextEditingController txtDateTime) {
    // String userIdd = SharedPrefsHelper().getMerchantUserId() ?? "";
    // int? userid = int.parse(userIdd);
    // User? user = leadController.assignedTo.value
    //     .firstWhereOrNull((user) => user.userId == userid);
    Map<String,dynamic>_assignedby={};
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
            height: 400, // Adjust as needed
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
                    maxLength: 30,
                    keyboardType: TextInputType.multiline,
                  ),
                  SizedBox(height: 10),
                  // assignedByDDL(),
                  AssignedToDialog(
                    onItemSelected: (selectedItem,) {
                      _assignedby=selectedItem;
                    },
                      leadController: leadController,
                      liveAgentUserName: liveAgentUserName),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      leadController.addFollowUp(lead.id, txtFollowUpName.text,
                          txtDescription.text, txtDateTime.text,_assignedby);
                      Navigator.of(context).pop();
                    },
                    child: Text("Add", style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  assignedByDDL() {
    return CustomSearchableDropDown(
      items: leadController.assignedTo.value,
      label: 'Select AssignedTo',
      initialIndex: 0,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all()),
      prefixIcon: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Icon(Icons.search),
      ),
      dropDownMenuItems: leadController.assignedTo.value.map((user) {
        return "${user.firstName} ${user.lastName}";
      }).toList(),
      onChanged: (user) {
        if (user != null) {
          leadController.taskModel.assignedTo = user;
        } else {
          leadController.taskModel.assignedTo = null;
        }
      },
    );
  }

  //Function 3

  List<Widget> buildTags(
    BuildContext context,
    textController,
    txtFollowUpName,
    txtDescription,
    txtDateTime,
  ) {
    List<Widget> tagsList = [];

    if (lead.tagsDto != null && lead.tagsDto!.tags!.length != 0) {
      int len = lead.tagsDto!.tags!.length;
      for (int i = 0; i < len; i++) {
        tagsList.add(
          Container(
              child: Chip(
            label: Text(
              "${lead.tagsDto!.tags![i].name ?? ""}",
              style: TextStyle(color: Colors.white, fontSize: kSmallFontSize),
            ),
            backgroundColor: lead.tagsDto?.tags![i].color == null
                ? Colors.grey
                : HexColor(lead.tagsDto!.tags![i].color!),
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
}
