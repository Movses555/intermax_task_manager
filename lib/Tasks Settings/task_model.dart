import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'task_model.g.dart';

@JsonSerializable()
class TaskModel{

  @JsonKey(name: 'name')
  var name;

  @JsonKey(name: 'color')
  var color;

  TaskModel({required this.name, required this.color});

  factory TaskModel.fromJson(Map<String, dynamic> json) => _$TaskModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaskModelToJson(this);


  static Map<String, dynamic> toMap(TaskModel task) => {
    'name': task.name,
    'color': task.color,
  };

  static String encode(List<TaskModel> tasks) => json.encode(
    tasks.map<Map<String, dynamic>>((task) => TaskModel.toMap(task)).toList(),
  );

  static List<TaskModel> decode(String tasks) =>
      (json.decode(tasks) as List<dynamic>)
          .map<TaskModel>((item) => TaskModel.fromJson(item))
          .toList();
}