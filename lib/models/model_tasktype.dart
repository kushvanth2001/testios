import 'dart:convert';
import '../helper/SharedPrefsHelper.dart';
import '../helper/networkHelper.dart';

class TaskType {
  final int id;
  final String name;
  final bool isActive;

  TaskType({required this.id, required this.name, required this.isActive});

  factory TaskType.fromJson(Map<String, dynamic> json) {
    return TaskType(
      id: json['id'],
      name: json['name'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isActive': isActive,
    };
  }
}

Future<List<TaskType>> fetchTaskTypes() async {
  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
  try {
    final response = await NetworkHelper().request(
      RequestType.get,
      Uri.parse(
          'https://retail.snap.pe/snappe-services/rest/v1/merchants/$clientGroupName/task-types'),
      requestBody: "",
    );
    if (response != null && response.statusCode == 200) {
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      final parsed = jsonDecode(response.body)['taskTypes'];
      return List<TaskType>.from(parsed.map((json) => TaskType.fromJson(json)));
    } else {
      print('Failed to load task types ${response?.statusCode}');
      throw Exception('Failed to load task types');
    }
  } catch (e) {
    print('Exception occurred: $e');
    throw e;
  }
}
