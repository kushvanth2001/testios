import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/helper/networkHelper.dart';
import 'package:leads_manager/models/model_callstatus.dart';
import 'package:leads_manager/models/model_lead.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';
import 'package:leads_manager/utils/snapPeUI.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/model_CreateNote.dart' hide Documents;
import '../models/model_FollowUp.dart' hide Documents;
import '../models/model_LeadStatus.dart';
import '../models/model_Merchants.dart';
import '../models/model_Task.dart';
import '../models/model_Users.dart';

class LeadController extends GetxController {
  Rx<LeadModel> leadModel = LeadModel().obs;
  RxBool tagsUpdated = false.obs;
  RxList<Tag> tags = <Tag>[].obs;
  Map<int, Tag> tagsMap = {};
  RxList<Tag> selectedTags = <Tag>[].obs;
  RxList<Tag> selectedAssignTags = <Tag>[].obs;
  final statusList = <CallStatus>[].obs;

  RxList<User> assignedTo = <User>[].obs;
  RxList<User> selectedAssignedTo = <User>[].obs;

  RxList<User> assignedBy = <User>[].obs;
  RxList<User> selectedAssignedBy = <User>[].obs;

  RxList<AllLeadsStatus> leadStatus = <AllLeadsStatus>[].obs;
  RxList<AllLeadsStatus> selectedLeadStatus = <AllLeadsStatus>[].obs;
  RxList<String> selectedSources = <String>[].obs;
  RxList<String> selectedDates = <String>[].obs;
  Rx<double> scrolloffset=0.0.obs;
  Rx<int> inlightlead=0.obs;
  bool onceexecutor=true;
  RxList<String> featureKeys = [
    "Tags",
    "AssignedTo",
    "Status",
    "AssignedBy",
    "Source",
    "Date"
  ].obs; // "Organization Name", "Email", "Source"
  Rx<String> selectedFeatureKey = "Tags".obs; //Default selected

  ScrollController scrollController = ScrollController();

  int currentPage = 0, size = 20, totalRecords = 0, pages = 0;

  TaskModel taskModel = TaskModel();
  FollowUpModel followUpModel = FollowUpModel();
  void fetchCallStatus() async {
    final statusList = await SnapPeNetworks.getcallStatus();
    this.statusList.value = statusList;
  }

  @override
  void onInit() {
    super.onInit();
    
    
  
    print("0calllist");
    print(statusList);
  
  }
  LeadController() {
 
    loadData();
    scrollListener();
    
     getDataFromSharedPreferences();
  //scrolltoid();
  }

 
getDataFromSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  
  int? leadId = prefs.getInt('leadid');

  if (leadId != null) {
  
    inlightlead.value=leadId;
    
  }



}
 
  scrollListener() async {
    scrollController.addListener(() {
        
      
      if (scrollController.position.maxScrollExtent - scrollController.offset==
          0) {
    fetchCallStatus();
       // print("end currentPage - $currentPage Pages - $pages currentRecords -${leadModel.value.leads!.length}  TotalRecords - $totalRecords");
        if (currentPage != pages &&
            leadModel.value.leads!.length != totalRecords) {
      

          getFilteredLeads(page: ++currentPage);
  
      
        } else {
          SnapPeUI().toastWarning(message: "No More Record.");
        }
      }
    });
  }

  loadData({bool forcedReload = false}) async {
    if (forcedReload) {
      await getFromNetwork();
    } else {
      await getFromDB();
    }
  }

  Future<void> getFromDB() async {
    String? leads = await SharedPrefsHelper().getLeads();
    String? leadTags = await SharedPrefsHelper().getLeadTags();
    String? usersJSON = await SharedPrefsHelper().getUsers();
    String? leadStatusJSON = await SharedPrefsHelper().getLeadStatus();
 //   print("userjson $usersJSON");
    if (leads != null &&
        leadTags != null &&
        usersJSON != null &&
        leadStatusJSON != null) {
      leadModel.value = leadModelFromJson(leads);
      totalRecords = leadModel.value.totalRecords ?? 0;
      pages = leadModel.value.pages ?? 0;
   //   print("Pages - $pages  TotalRecords - $totalRecords");
      tags.value = tagsDtoFromJson(leadTags).tags ?? [];
      createTagMap();
      assignedTo.value = usersModelFromJson(usersJSON).users ?? [];
      assignedBy.value = usersModelFromJson(usersJSON).users ?? [];
      leadStatus.value =
          leadStatusModelFromJson(leadStatusJSON).allLeadsStatus ?? [];
    } else {
      await getFromNetwork();
    }
  }

  Future<void> getFromNetwork() async {
    if (selectedTags.length == 0 && selectedAssignedTo.length == 0) {
      print("1");
      getFilteredLeads();
    } else {
      getFilteredLeads();
    }
    //getFilteredLeads();
    getTags();
   // print(" getTags(); called ");
    getUsers();
    getLeadStatus();
  }

  void getFilteredLeads({
    dynamic nameOrMobile,
    int page = 0,
  }) async {
    print("2");
    currentPage = page;
  //  print("Page - $page, CurrentPage - $currentPage");

    List<String> tagNameList = selectedTags.value.map((e) => e.name!).toList();
    List<int> assignedToUserIdList =
        selectedAssignedTo.value.map((e) => e.userId!).toList();
    List<int> assignedByUserIdList =
        selectedAssignedBy.value.map((e) => e.id!).toList();
    List<String> status = selectedLeadStatus.map((e) => e.statusName!).toList();
    List<String> selectedSourcess = selectedSources.value;
    List<String> selectedDatess = selectedDates.value;
    String? leadsJSON = await SnapPeNetworks().filterLeads(page, size,
        nameOrMobile: nameOrMobile,
        tags: tagNameList,
        assignedTo: assignedToUserIdList,
        assignedBy: assignedByUserIdList,
        selectedSources: selectedSourcess,
        selectedDatess: selectedDatess,
        leadStatus: status);
    if (leadsJSON != null) {
      if (page != 0) {
        leadModelFromJson(leadsJSON).leads!.forEach((e) {
          leadModel.update((value) {
            value?.leads?.add(e);
          });
        });
      } else {
        leadModel.value = leadModelFromJson(leadsJSON);
        totalRecords = leadModel.value.totalRecords ?? 0;
        pages = leadModel.value.pages ?? 0;
        SharedPrefsHelper().setLeads(leadsJSON);
      }
    }
  }

  void getTags() async {
    print("3");
    String? leadTagsJSON = await SnapPeNetworks().getLeadTags();
    if (leadTagsJSON != null) {
      tags.value = tagsDtoFromJson(leadTagsJSON).tags ?? [];
      createTagMap();
      SharedPrefsHelper().setLeadTags(leadTagsJSON);
    }
  }

  createTagMap() {
    tagsMap = {};
    for (Tag tag in tags.value) {
      tagsMap[tag.id!] = tag;
    }
  }

  Future<List<Tag>> getAssignTags(int leadId) async {
    print("4");
    String? leadTagsJSON = await SnapPeNetworks().getAssignTags(leadId);
    if (leadTagsJSON != null) {
      List<Tag> list = tagsDtoFromJson(leadTagsJSON).tags ?? [];

      for (Tag tag in list) {
        if (tagsMap.containsKey(tag.id)) {
          selectedAssignTags.value.add(tagsMap[tag.id]!);
        }
      }
    }
    return selectedAssignTags.value;
  }

  updateAssignTag(int leadId) async {
     print("5");
    String? leadTagsJSON = await SnapPeNetworks()
        .updateAssignTags(leadId, TagsDto(tags: selectedAssignTags));
    if (leadTagsJSON != null) {
      selectedAssignTags.value = tagsDtoFromJson(leadTagsJSON).tags ?? [];

    //  print("selectedAssignTags length = ${selectedAssignTags.value.length}");
    }
  }

  void getUsers() async {
     print("6");
    String? usersJSON = await SnapPeNetworks().getUsers();
    if (usersJSON != null) {
      assignedTo.value = usersModelFromJson(usersJSON).users ?? [];
      SharedPrefsHelper().setUsers(usersJSON);
    }
  }

  void getLeadStatus() async {
     print("7");
    String? leadStatusJSON = await SnapPeNetworks().getLeadStatus();
    if (leadStatusJSON != null) {
      leadStatus.value =
          leadStatusModelFromJson(leadStatusJSON).allLeadsStatus ?? [];
      SharedPrefsHelper().setLeadStatus(leadStatusJSON);
    }
  }

  void clearFilter() {
    selectedTags.clear();
    selectedAssignedTo.clear();
    selectedAssignedBy.clear();
    selectedSources.clear();
    selectedLeadStatus.clear();
    selectedDates.clear();
  }

  void addFollowUp(int? leadId, String followUpName, String description,
      String strDatetime,Map<String,dynamic> assignedto) async {
    taskModel.name = followUpName;
    taskModel.description = description;
taskModel.assignedTo=assignedto;
print("fromfunc"+assignedto.toString());
    DateTime datetime = DateTime.parse(strDatetime);
    DateTime utcDT = DateTime.utc(datetime.year, datetime.month, datetime.day);
    String lastTime = "${datetime.hour}:${datetime.minute}:00";

    taskModel.startTime = utcDT;
    taskModel.endTime = utcDT;
    taskModel.lastTime = lastTime;
    

    // print(utcDT);
    // print(lastTime);
    // print(taskModel);

    String? res = await SnapPeNetworks().createTask(leadId, taskModel);

    if (res != null) {
      TaskModel task = taskModelFromJson(res);
 //print("resultis notnull");
      followUpModel.taskId = task.id;
      followUpModel.status = "OK";
      followUpModel.leadId = leadId;
      followUpModel.isActive = true;
      followUpModel.remarks = "Follow Up Added Successfully";

      await SnapPeNetworks().addFollowUp(leadId, followUpModel);
    }
    else{
      print("resultisnull");
    }
  }

  void createNote(int? id, String text) async {
    await SnapPeNetworks()
        .createLeadNotes(id, CreateNote(remarks: "<p>$text</p>"));
  }
}

