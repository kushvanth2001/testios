import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../helper/SharedPrefsHelper.dart';
import '../../helper/networkHelper.dart';
import '../../models/model_assignedTo.dart';
import '../../models/model_priority.dart';
import '../../models/model_taskstatus.dart';
import '../../models/model_tasktype.dart';

class TaskDetails extends StatefulWidget {
  String? taskName;
  String? description;
  String? createdBy;
  String? assignedTo;
  String? startDate;
  String? endDate;
  String? tasktype;
  String? taskstatus;
  bool? fromEdit;
  TaskDetails({
    Key? key,
    this.taskName,
    this.description,
    this.createdBy,
    this.assignedTo,
    this.startDate,
    this.endDate,
    this.tasktype,
    this.taskstatus,
    this.fromEdit,
  }) : super(key: key);

  @override
  State<TaskDetails> createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> {
  // Define controllers for text fields
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  TextEditingController _controller3 = TextEditingController();
  TextEditingController _controller4 = TextEditingController();

  List<User> _users = [];
  List<Priority> _priorities = [];
  List<TaskStatus> _taskStatuses = [];
  List<TaskType> _taskTypes = [];

  int? _selectedUser;
  int? _selectedPriority;
  int? _selectedTaskStatus;
  int? _selectedTaskType;
  String? title;
  @override
  void initState() {
    super.initState();
    if (widget.startDate != null) {
      DateTime startDate = DateTime.parse(widget.startDate!);
      String formattedDate = DateFormat('yyyy-MM-dd').format(startDate);
      _controller3.text = formattedDate;
    } else {
      _controller3.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
    if (widget.endDate != null) {
      DateTime endDate = DateTime.parse(widget.endDate!);
      String formattedDate = DateFormat('yyyy-MM-dd').format(endDate);
      _controller4.text = formattedDate;
    } else {
      _controller4.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
    _controller1.text = widget.taskName ?? '';
    if (widget.fromEdit == true) {
      title = "Task Details";
    } else {
      title = "Add Task";
    }
    fetchUsers().then((users) {
      if (mounted) {
        setState(() {
          _users = users;
          if (widget.assignedTo != null) {
            final user = _users.firstWhereOrNull(
              (user) =>
                  '${user.firstName} ${user.lastName}' == widget.assignedTo,
            );
            if (user != null) {
              _selectedUser = user.id;
            }
          }
        });
      }
    });

    fetchPriorities().then((priorities) {
      if (mounted) {
        setState(() {
          _priorities = priorities;
        });
      }
    });
    fetchTaskStatuses().then((taskStatuses) {
      if (mounted) {
        setState(() {
          _taskStatuses = taskStatuses;
          if (widget.taskstatus != null) {
            final taskStatus = _taskStatuses.firstWhereOrNull(
              (taskStatus) => taskStatus.name == widget.taskstatus,
            );
            if (taskStatus != null) {
              _selectedTaskStatus = taskStatus.id;
            }
          }
        });
      }
    });

    fetchTaskTypes().then((taskTypes) {
      if (mounted) {
        setState(() {
          _taskTypes = taskTypes;
          if (widget.tasktype != null) {
            final taskType = _taskTypes.firstWhereOrNull(
              (taskType) => taskType.name == widget.tasktype,
            );
            if (taskType != null) {
              _selectedTaskType = taskType.id;
            } else {
              _selectedTaskType = 3;
            }
          }
        });
      }
    });
  }

  Future<void> addTask() async {
    print("${_controller3.text} ... .. .. . ... .. . r");
    DateFormat inputFormat = DateFormat('yyyy-MM-dd');
    DateTime startDate = inputFormat.parse(_controller3.text);
  
   // startDate = startDate.add(Duration(hours: 15, minutes: 29, seconds: 56));
    String formattedStartDate =startDate.toIso8601String();
       // DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(startDate) + 'Z';

    DateTime endDate = inputFormat.parse(_controller4.text);
   // endDate = endDate.add(Duration(hours: 15, minutes: 29, seconds: 56));
    String formattedEndDate =endDate.toIso8601String();
       // DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(endDate) + 'Z';

    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "";
    final response = await NetworkHelper().request(
      RequestType.post,
      Uri.parse(
          'https://retail.snap.pe/snappe-services/rest/v1/merchants/$clientGroupName/task'),
      requestBody: jsonEncode({
        "assignedTo": {
          "id": _selectedUser,
        },
        "taskStatus": {
          "id": _selectedTaskStatus,
        },
        "name": _controller1.text,
        "startTime": formattedStartDate,
        "endTime": formattedEndDate,
        "priorityId": {
          "id": _selectedPriority,
        },
        "taskType": {
          "id": _selectedTaskType,
        },
      }),
    );

    if (response?.statusCode == 200) {
      print('Task added successfully');
    } else {
      print('Failed to add task');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$title'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 14, bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.grey),
                ),
                child: TextFormField(
                  controller: _controller1,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: "Task",
                    labelText: "Task Name",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(
                        left: 10, right: 10, bottom: 15, top: 10),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.grey)),
                child: DropdownButtonFormField<int>(
                  value: _selectedTaskType,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(
                        left: 10, right: 10, bottom: 15, top: 10),
                    border: InputBorder.none,
                    hintText: 'Task Type',
                    labelText: "Task Type",
                  ),
                  items: _taskTypes.map((taskType) {
                    return DropdownMenuItem<int>(
                      value: taskType.id,
                      child: Text(taskType.name),
                    );
                  }).toList(),
                  onChanged: (selectedTaskTypeId) {
                    setState(() {
                      print(" tasktype is $selectedTaskTypeId");
                      _selectedTaskType = selectedTaskTypeId;
                    });
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.grey),
                ),
                child: TextFormField(
                  controller:
                      TextEditingController(text: widget.description ?? ''),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: "Description",
                    labelText: "Description",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(
                        left: 10, right: 10, bottom: 15, top: 10),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.grey)),
                child: DropdownButtonFormField<int>(
                  value: _selectedUser,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(
                          left: 10, right: 10, bottom: 15, top: 10),
                      hintText: "Assign To",
                      labelText: "Assign To"),
                  items: _users.map((user) {
                    return DropdownMenuItem<int>(
                      value: user.id,
                      child: Text('${user.firstName} ${user.lastName}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedUser = value;
                    });
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.grey)),
                child: DropdownButtonFormField<int>(
                  value: _selectedTaskStatus,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(
                        left: 10, right: 10, bottom: 15, top: 10),
                    border: InputBorder.none,
                    hintText: 'Status',
                    labelText: "Status",
                  ),
                  items: _taskStatuses.map((taskStatus) {
                    return DropdownMenuItem<int>(
                      value: taskStatus.id,
                      child: Text(taskStatus.name),
                    );
                  }).toList(),
                  onChanged: (selectedTaskStatusId) {
                    setState(() {
                      _selectedTaskStatus = selectedTaskStatusId;
                    });
                  },
                ),
              ),

              SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.grey)),
                child: DropdownButtonFormField<int>(
                  value: _selectedPriority,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(
                        left: 10, right: 10, bottom: 15, top: 10),
                    border: InputBorder.none,
                    hintText: 'Priority',
                    labelText: "Priority",
                  ),
                  items: _priorities.map((priority) {
                    return DropdownMenuItem<int>(
                      value: priority.id,
                      child: Text(priority.name),
                    );
                  }).toList(),
                  onChanged: (selectedPriorityId) {
                    setState(() {
                      _selectedPriority = selectedPriorityId;
                    });
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: _controller3,
                decoration: InputDecoration(
                  hintText: "Start date",
                  suffixIcon: IconButton(
                    onPressed: () async {
                      DateTime? date = DateTime.now();
                      FocusScope.of(context).requestFocus(new FocusNode());
                      date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      _controller3.text = date != null
                          ? DateFormat('dd-MM-yyyy').format(date)
                          : "";
                    },
                    icon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: _controller4,
                decoration: InputDecoration(
                  hintText: "End date",
                  suffixIcon: IconButton(
                    onPressed: () async {
                      DateTime? date = DateTime.now();
                      FocusScope.of(context).requestFocus(new FocusNode());
                      date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      _controller4.text = date != null
                          ? DateFormat('dd-MM-yyyy').format(date)
                          : "";
                    },
                    icon: Icon(Icons.calendar_today),
                  ),
                ),
              ),

              // Repeat DropdownButton for remaining fields...
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          addTask();
          Navigator.pop(context);
        },
        label: Text('     Add     '),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
