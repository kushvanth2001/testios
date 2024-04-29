// To parse this JSON data, do
//
//     final followUpModel = followUpModelFromJson(jsonString);

import 'dart:convert';

FollowUpModel followUpModelFromJson(String str) =>
    FollowUpModel.fromJson(json.decode(str));

String followUpModelToJson(FollowUpModel data) => json.encode(data.toJson());

class FollowUpModel {
  FollowUpModel({
    this.status,
    this.isActive,
    this.createdBy,
    this.documents,
    this.leadId,
    this.taskId,
    this.remarks,
  });

  String? status;
  bool? isActive;
  dynamic createdBy;
  Documents? documents;
  int? leadId;
  int? taskId;
  String? remarks;

  factory FollowUpModel.fromJson(Map<String, dynamic> json) => FollowUpModel(
        status: json["status"],
        isActive: json["isActive"],
        createdBy: json["createdBy"],
        documents: Documents.fromJson(json["documents"]),
        leadId: json["leadId"],
        taskId: json["taskId"],
        remarks: json["remarks"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "isActive": isActive,
        "createdBy": createdBy,
        "documents":
            documents == null ? Documents().toJson() : documents!.toJson(),
        "leadId": leadId,
        "taskId": taskId,
        "remarks": remarks,
      };
}

class Documents {
  Documents({
    this.documents,
  });

  List<dynamic>? documents;

  factory Documents.fromJson(Map<String, dynamic> json) => Documents(
        documents: json["documents"] == null
            ? null
            : List<dynamic>.from(json["documents"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "documents": documents == null
            ? []
            : List<dynamic>.from(documents!.map((x) => x)),
      };
}
