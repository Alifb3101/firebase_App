
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'todo.g.dart';

List<EmployeModel> employeModelFromJson(String str) => List<EmployeModel>.from(json.decode(str).map((x) => EmployeModel.fromJson(x)));

String employeModelToJson(List<EmployeModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@JsonSerializable()
class EmployeModel {
  @JsonKey(name: "id")
  String? id;
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "email")
  String? email;

  EmployeModel({
    this.id,
    this.name,
    this.email,
  });

  factory EmployeModel.fromJson(Map<String, dynamic> json) => _$EmployeModelFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeModelToJson(this);
}
