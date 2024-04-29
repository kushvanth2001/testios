import 'dart:convert';
import '../helper/SharedPrefsHelper.dart';
import '../helper/networkHelper.dart';

class TaskStatus {
  final int id;
  final String name;
  final int sequenceOrder;

  TaskStatus(
      {required this.id, required this.name, required this.sequenceOrder});

  factory TaskStatus.fromJson(Map<String, dynamic> json) {
    return TaskStatus(
      id: json['id'],
      name: json['name'],
      sequenceOrder: json['sequenceOrder'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sequenceOrder': sequenceOrder,
    };
  }
}

Future<List<TaskStatus>> fetchTaskStatuses() async {
  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
  try {
    final response = await NetworkHelper().request(
      RequestType.get,
      Uri.parse(
          'https://retail.snap.pe/snappe-services/rest/v1/merchants/$clientGroupName/task-status'),
      requestBody: "",
    );
    if (response != null && response.statusCode == 200) {
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      final parsed = jsonDecode(response.body)['tasks'];
      return List<TaskStatus>.from(
          parsed.map((json) => TaskStatus.fromJson(json)));
    } else {
      print('Failed to load task statuses ${response?.statusCode}');
      throw Exception('Failed to load task statuses');
    }
  } catch (e) {
    print('Exception occurred: $e');
    throw e;
  }
}
