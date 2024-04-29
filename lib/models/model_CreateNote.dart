import 'dart:convert';

CreateNote createNoteFromJson(String str) =>
    CreateNote.fromJson(json.decode(str));

String createNoteToJson(CreateNote data) => json.encode(data.toJson());

class CreateNote {
  CreateNote({
    this.status,
    this.isActive,
    this.createdBy,
    this.documents,
    this.remarks,
  });

  String? status;
  bool? isActive;
  String? createdBy;
  Documents? documents;
  String? remarks;

  factory CreateNote.fromJson(Map<String, dynamic> json) => CreateNote(
        status: json["status"],
        isActive: json["isActive"],
        createdBy: json["createdBy"],
        documents: json["documents"] == null
            ? null
            : Documents.fromJson(json["documents"]),
        remarks: json["remarks"],
      );

  Map<String, dynamic> toJson() => {
        "status": status??= "OK",
        "isActive": isActive??= true,
        "createdBy": createdBy,
        "documents": documents == null ? Documents() : documents!.toJson(),
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
            ? []
            : List<dynamic>.from(json["documents"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "documents": documents == null
            ? []
            : List<dynamic>.from(documents!.map((x) => x)),
      };
}
