import 'dart:math';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import '../../constants/styleConstants.dart';
import '../../helper/SharedPrefsHelper.dart';
import '../../models/model_taskpage.dart';
import 'TaskNotesPage.dart';
import 'leadNotesScreen.dart';
import 'taskDetails.dart';
import 'dart:convert';
import '../../helper/networkHelper.dart';
import 'package:intl/intl.dart';
import '../../utils/snapPeUI.dart';
import '../../widgets/customcoloumnwidgets.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:uuid/uuid.dart';
import 'package:async/async.dart';
import '../../models/model_Merchants.dart';
import '../../models/model_Users.dart';
import '../../models/model_taskstatus.dart';
import '../../utils/snapPeNetworks.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({Key? key}) : super(key: key);

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  DateTime selectedDate = DateTime.now();
  List<Widget> cards = [];
  List<Task> _tasks=[];
  List<dynamic> _selectedDates = [];
  TextEditingController _textcontroller = TextEditingController();
  DateTime? startTime = DateTime.now().subtract(Duration(days: 7));
  DateTime? endtime = DateTime.now().add(Duration(days: 7));
List<TaskStatus> _taskStatuses = [];
List<User> users=[];
String selectedAssignedto="";
String selectedAssignedby='';

  @override
  void initState() {
    super.initState();
    // fetchTasks();
  

    
   
      fetchTaskStatuses().then((taskStatuses) {
      if (mounted) {
        setState(() {
          _taskStatuses = taskStatuses;
        
      
        });
      }
    });
    
  
    fetchAllTasks();
    _textcontroller.text =
        "${DateFormat('MMMM d, y').format(startTime!)} - ${DateFormat('MMMM d, y').format(endtime!)}";
         setdata();
         
  }
setdata()async{
   var s=await SnapPeNetworks().getUsers();
     if (s != null) {
    
      
      setState(() {
        print(usersModelFromJson(s).users);
       users = usersModelFromJson(s).users?? [];
        
         
      });
      print("userrrrr");
    
    }else{print("siszero");}
}
  // Future<void> fetchTasks() async {
  //   try {
  //     String clientGroupName =
  //         await SharedPrefsHelper().getClientGroupName() ?? "";
  //     String userId = await SharedPrefsHelper().getMerchantUserId();

  //     final response = await NetworkHelper().request(
  //         RequestType.get,
  //         Uri.parse(
  //             'https://retail.snap.pe/snappe-services/rest/v1/merchants/$clientGroupName/dashboard-tasks?dueDate=${selectedDate.millisecondsSinceEpoch ~/ 1000}&assignedTo=$userId'),
  //         requestBody: "");
  //     print(selectedDate.millisecondsSinceEpoch ~/ 1000);
  //     if (response != null && response.statusCode == 200) {
  //       print('Response Status: ${response.statusCode}');
  //       print('Response Body: ${response.body}');
  //       final jsonResponse = json.decode(response.body);
  //       final List<dynamic> tasksList = jsonResponse["tasks"];
  //       final List<Task> tasks =
  //           tasksList.map((json) => Task.fromJson(json)).toList();
  //       print(". $tasks .");
  //       cards = tasks.map<Widget>((task) {
  //         return Card(
  //           child: Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Row(
  //               children: <Widget>[
  //                 Expanded(
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: <Widget>[
  //                       Text(
  //                         '${task.name}',
  //                         style: TextStyle(
  //                             fontSize: 20, fontWeight: FontWeight.bold),
  //                       ),
  //                       Text('Created By : ${task.assignedBy.userName}'),
  //                       Text('Assigned To : ${task.assignedTo.userName}'),
  //                       Text('Due Date: ${task.endTime.split("T")[0]}'),
  //                     ],
  //                   ),
  //                 ),
  //                 PopupMenuButton<int>(
  //                   itemBuilder: (context) => [
  //                     PopupMenuItem(
  //                       value: 1,
  //                       child: Row(
  //                         children: <Widget>[
  //                           Icon(Icons.edit),
  //                           Text("   Edit",
  //                               style: TextStyle(
  //                                   fontWeight: FontWeight.bold, fontSize: 20)),
  //                         ],
  //                       ),
  //                     ),
  //                     PopupMenuItem(
  //                       value: 2,
  //                       child: Row(
  //                         children: <Widget>[
  //                           Icon(Icons.note_add),
  //                           Text(
  //                             "   Notes",
  //                             style: TextStyle(
  //                                 fontWeight: FontWeight.bold, fontSize: 20),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ],
  //                   onSelected: (value) {
  //                     if (value == 1) {
  //                       Navigator.push(
  //                         context,
  //                         MaterialPageRoute(
  //                           builder: (context) => TaskDetails(
  //                             fromEdit: true,
  //                             taskName: task.name,
  //                             description: task.description,
  //                             tasktype: task.tasktype.name,
  //                             taskstatus: task.taskstatus?.name,
  //                             createdBy: task.assignedBy.userName,
  //                             assignedTo: task.assignedTo.userName,
  //                             startDate: task.endTime.split("T")[0],
  //                             endDate: task.endTime.split("T")[0],
  //                           ),
  //                         ),
  //                       );
  //                     } else if (value == 2) {
  //                       Navigator.push(
  //                         context,
  //                         MaterialPageRoute(
  //                             builder: (context) =>
  //                                 TaskNotesScreen(taskId: task.id)),
  //                       );
  //                     }
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       }).toList();

  //       setState(() {});
  //     } else {
  //       print('Failed to load tasks');
  //     }
  //   } catch (e) {
  //     print('Exception occurred: $e');
  //   }
  // }

  Future<void> fetchAllTasks() async {
    try {
      String clientGroupName =
          await SharedPrefsHelper().getClientGroupName() ?? "";
      String userId = await SharedPrefsHelper().getMerchantUserId();

      final response = await NetworkHelper().request(RequestType.get,
          Uri.parse(getUrl(startTime, endtime, clientGroupName)),
          requestBody: "");
      print(selectedDate.millisecondsSinceEpoch ~/ 1000);
      if (response != null && response.statusCode == 200) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
        final jsonResponse = json.decode(response.body);
        final List<dynamic> tasksList = jsonResponse["tasks"];
        print(". $tasksList .");
        final List<Task> tasks =
            tasksList.map((json) => Task.fromJson(json)).toList();
        print(". $tasks .");
        setState(() {
         _tasks=tasks; 
        });

        cards = tasks.map<Widget>((task) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${task.name}',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text('Created By : ${task.assignedBy.userName}'),
                        Text('Assigned To : ${task.assignedTo.userName}'),
                        Text('Due Date: ${task.endTime.split("T")[0]}'),
                        Row(
                          children: [
                            Text('Status:${task.taskstatus?.name}'),
                             DropdownButton<String>(
      value:task.taskstatus?.name,
      onChanged: (String? newValue) async{
        setState(() {
       Taskstatus   k=Taskstatus(id: getIdByStatus(_taskStatuses, newValue??""),name: newValue??"") ;
      
       Task u=task;
       u.taskstatus=k;
       task=u;
          // task.taskstatus!=null?task.taskstatus =k:null;
          print(task.taskstatus?.name );
        });
   
  
      },
      items:  _taskStatuses.map((e) => e.name).toList().map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    )
                            
          
                          ],
                        )
                      ],
                    ),
                  ),
                  PopupMenuButton<int>(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 1,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.edit),
                            Text("   Edit",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 2,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.note_add),
                            Text(
                              "   Notes",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskDetails(
                              fromEdit: true,
                              taskName: task.name,
                              description: task.description,
                              tasktype: task.tasktype.name,
                              taskstatus: task.taskstatus?.name,
                              createdBy: task.assignedBy.userName,
                              assignedTo: task.assignedTo.userName,
                              startDate: task.endTime.split("T")[0],
                              endDate: task.endTime.split("T")[0],
                            ),
                          ),
                        );
                      } else if (value == 2) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  TaskNotesScreen(taskId: task.id)),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        }).toList();

        setState(() {});
      } else {
        print('Failed to load tasks');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: SnapPeUI().appBarText("Tasks", kBigFontSize),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TaskDetails()),
              );
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
        
          InkWell(
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              child: TextFormField(
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.calendar_month_outlined,
                      color: Colors.blue,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4.0))),
                    fillColor: Colors.grey.shade300,
                    filled: true),
                controller: _textcontroller,
                enabled: false,
              ),
            ),
            onTap: () async {
              var k = await showCalendarDatePicker2Dialog(
                context: context,
                config: CalendarDatePicker2WithActionButtonsConfig(
                  calendarType: CalendarDatePicker2Type.range,
                  currentDate: DateTime.now(),
                ),
                dialogSize: const Size(325, 400),
                value: [DateTime.now(), DateTime(2050)],
                borderRadius: BorderRadius.circular(15),
              );
              print(k);
              if (k != null) {
                if (k.length == 2) {
                  print(k[0].toString() + k[1].toString());
                  if (k[0].toString() == DateTime.now().toString() &&
                      k[1].toString() == "2050-01-01 00:00:00.000") {
                    setState(() {
                      startTime = k[0];
                      endtime = null;
                    });

                    print(startTime);
                    _textcontroller.text =
                        DateFormat('MMMM d, y').format(k[0]!);
                  } else if (k[0].toString() == k[1].toString()) {
                    setState(() {
                      startTime = k[0];
                      endtime = null;
                    });

                    print(startTime);
                    _textcontroller.text =
                        DateFormat('MMMM d, y').format(k[0]!);
                  } else {
                    setState(() {
                      startTime = k[0]!;
                      endtime = k[1]!;
                    });

                    print(DateFormat('MMMM d, y').format(k[0]!) +
                        " - " +
                        DateFormat('MMMM d, y').format(k[1]!));
                    _textcontroller.text =
                        DateFormat('MMMM d, y').format(k[0]!) +
                            " - " +
                            DateFormat('MMMM d, y').format(k[1]!);
                  }
                }
                if (k.length == 1) {
                  setState(() {
                    startTime = k[0]!;
                    endtime = null;
                  });

                  print(DateFormat('MMMM d, y').format(k[0]!));
                  _textcontroller.text = DateFormat('MMMM d, y').format(k[0]!);
                }
              }
              await fetchAllTasks();
              print(k);
            },
          ),
//       
 users.length!=0?SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Container(
    padding: EdgeInsets.all(8),
    height: 50,
    width: MediaQuery.of(context).size.width,
    child: ListView(
      scrollDirection: Axis.horizontal,
    
      children: [
        Center(child: Text("Assigned To: ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),)),
        SizedBox(
           width: 200,
          
          child: DropDownTextField(
            initialValue: 'All',
            clearOption: false,
       textFieldDecoration: InputDecoration(
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
  ),
),
      onChanged: (k){
selectedAssignedto=k.value;
fetchAllTasks();
      },
        
             dropDownList: [
              ...users.map((e) => DropDownValueModel(value: e.id != null ? e.userId.toString() : "", name: e.fullName ?? "")).toList(),
            DropDownValueModel(name: 'All', value: '')
            ]
          ),
        ),
         SizedBox(width: 5,),
         Icon(Icons.arrow_circle_right),
        SizedBox(width: 40,),
       Center(child: Text("Assigned By: ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),)),
        SizedBox(
          width: 200,
          child:  DropDownTextField(
            initialValue: 'All',
            clearOption: false,
       textFieldDecoration: InputDecoration(
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
  ),
),
      onChanged: (k){
selectedAssignedby=k.value;
fetchAllTasks();
      },
        
             dropDownList: [
              ...users.map((e) => DropDownValueModel(value: e.id != null ? e.userId.toString() : "", name: e.fullName ?? "")).toList(),
            DropDownValueModel(name: 'All', value: '')
            ]
          ),
        ),
      ],
    ),
  ),
):Container(),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Divider(color: Colors.grey, height: 1.0, thickness: 1)),
          Expanded(
            child: cards.isEmpty
                ? SnapPeUI().noDataFoundImage2(msg: "You have no Tasks !!")
                // child: Text("No tasks found for this date.",
                //     style: TextStyle(
                //         fontStyle: FontStyle.italic,
                //         fontWeight: FontWeight.bold,
                //         fontSize: 20))

                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index,) =>Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${_tasks[index].name}',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text('Created By : ${_tasks[index].assignedBy.userName}'),
                        Text('Assigned To : ${_tasks[index].assignedTo.userName}'),
                        Text('Due Date: ${_tasks[index].endTime.split("T")[0]}'),
                        Row(
                          children: [
                            Text('Status:'),
                             DropdownButton<String>(
      value:_tasks[index].taskstatus?.name,
      onChanged: (String? newValue) async{
        setState(() {
       Taskstatus   k=Taskstatus(id: getIdByStatus(_taskStatuses, newValue??""),name: newValue??"") ;
      
       Task u=_tasks[index];
       u.taskstatus=k;
       _tasks[index]=u;
          // task.taskstatus!=null?task.taskstatus =k:null;
          print(_tasks[index].taskstatus?.name );

        });

        var s= await fetchTaskById(_tasks[index].id);
        s["taskStatus"]['name']=_tasks[index].taskstatus?.name;
        s["taskStatus"]['id']=_tasks[index].taskstatus?.id;
        await editTask(s, _tasks[index].id);

      },
      items:  _taskStatuses.map((e) => e.name).toList().map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    )
                            
          
                          ],
                        )
                      ],
                    ),
                  ),
                  PopupMenuButton<int>(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 1,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.edit),
                            Text("   Edit",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 2,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.note_add),
                            Text(
                              "   Notes",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskDetails(
                              fromEdit: true,
                              taskName: _tasks[index].name,
                              description: _tasks[index].description,
                              tasktype: _tasks[index].tasktype.name,
                              taskstatus: _tasks[index].taskstatus?.name,
                              createdBy: _tasks[index].assignedBy.userName,
                              assignedTo: _tasks[index].assignedTo.userName,
                              startDate: _tasks[index].endTime.split("T")[0],
                              endDate: _tasks[index].endTime.split("T")[0],
                            ),
                          ),
                        );
                      } else if (value == 2) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  TaskNotesScreen(taskId: _tasks[index].id)),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
                  ),
          ),
        ],
      ),
    );
  }
  String getUrl(DateTime? startdate, DateTime? enddate, String clientGroupName) {
  String startMicroseconds = startdate != null
      ? (startdate.millisecondsSinceEpoch ~/ 1000)
          .toString() // Using integer division to convert milliseconds to seconds
      : '';

  String endMicroseconds = enddate != null
      ? (enddate.millisecondsSinceEpoch ~/ 1000)
          .toString() // Using integer division to convert milliseconds to seconds
      : (startdate!.add(Duration(hours: 20)).millisecondsSinceEpoch ~/ 1000)
          .toString(); // Default end time if enddate is null

  return "https://retail.snap.pe/snappe-services/rest/v1/merchants/$clientGroupName/task-filter?endFrom=$startMicroseconds&endTo=$endMicroseconds&page=0&size=2000&sortBy=createdOn&sortOrder=DESC" + '${selectedAssignedby == "" ? "" : "&assignedBy=${int.tryParse(selectedAssignedby)}"}'+
    '${selectedAssignedto == "" ? "" : "&assignedTo=${int.tryParse(selectedAssignedto)}"}';  //  "https://retail.snap.pe/snappe-services/rest/v1/merchants/$clientGroupName/task-filter?createdOnFrom=$startMicroseconds&createdOnTo=$endMicroseconds&page=0&size=20&sortBy=createdOn&sortOrder=DESC";
}
}


String getStatusName(List<TaskStatus> dataList, int id) {
  for (var item in dataList) {
    if (item.id == id) {
      return item.name; // Assuming 'status' is the key for the status name
    }
  }
  return 'Status not found';
}

// Function to get ID by status name
int getIdByStatus(List<TaskStatus> dataList, String status) {
  for (var item in dataList) {
    if (item.name == status) { // Assuming 'status' is the key for the status name
      return item.id;
    }
  }
  return -1; // Return -1 if status not found
}
   Future<Map<String,dynamic>> fetchTaskById(String taskId) async {
    final String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "";
    
      

    try {
      final response = await NetworkHelper().request(
      RequestType.get, // Use PUT request for updating
      Uri.parse(
          'https://retail.snap.pe/snappe-services/rest/v1/merchants/$clientGroupName/task/$taskId'), // Assuming task id is used in the URL for updating
        );

      if (response!.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        print('Failed to fetch task. Status code: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('Error fetching task: $e');
      return {};
    }
  }
Future<void> editTask(Map<String,dynamic> s,String id) async {
  try {


    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "";
    final response = await NetworkHelper().request(
      RequestType.put, // Use PUT request for updating
      Uri.parse(
          'https://retail.snap.pe/snappe-services/rest/v1/merchants/$clientGroupName/task/$id'), // Assuming task id is used in the URL for updating
      requestBody: jsonEncode(s));
print(s);
    if (true) {
      print('Task updated successfully');
    } else {
      print('Failed to update task');
    }
  } catch (e) {
    print('Exception occurred while editing task: $e');
  }
}