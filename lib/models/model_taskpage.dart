class Task {
  final String id;
  final String? name;
  final String? description;
  final Userr assignedBy;
  final Userr assignedTo;
   Taskstatus taskstatus;
  final Tasktype tasktype;
  final String startTime;
  final String endTime;

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.assignedBy,
    required this.assignedTo,
    required this.tasktype,
    required this.taskstatus,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'assignedBy': assignedBy.toJson(),
      'assignedTo': assignedTo.toJson(),
      'taskType': tasktype.toJson(),
      'taskStatus': taskstatus.toJson(),
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'].toString() ?? "",
      name: json['name'] ?? "",
      description: json['description'] ?? '',
      assignedBy: Userr.fromJson(json['assignedBy'] ?? {}),
      assignedTo: Userr.fromJson(json['assignedTo'] ?? {}),
      tasktype: Tasktype.fromJson(json['taskType']),
      taskstatus: Taskstatus.fromJson(json['taskStatus']),
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
    );
  }
}

class Userr {
  final String userName;

  Userr({required this.userName});

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
    };
  }

  factory Userr.fromJson(Map<String, dynamic> json) {
    return Userr(
      userName: json['userName'] ?? "",
    );
  }
}

class Tasktype {
  final String name;

  Tasktype({required this.name});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }

  factory Tasktype.fromJson(Map<String, dynamic> json) {
    return Tasktype(
      name: json['name'] ?? "",
    );
  }
}

class Taskstatus {
  String name;
  int id;

  Taskstatus({required this.name, required this.id});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
    };
  }

  factory Taskstatus.fromJson(Map<String, dynamic> json) {
    return Taskstatus(
      name: json['name'] ?? "",
      id: json['id'] ?? 0,
    );
  }
}
