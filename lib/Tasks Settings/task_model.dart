import 'dart:convert';

class TaskModel{

  var name;

  var color;

  TaskModel({required this.name, required this.color});

  factory TaskModel.fromJson(Map<String, dynamic> jsonData) {
    return TaskModel(
      name: jsonData['name'],
      color: jsonData['color']
    );
  }

  static Map<String, dynamic> toMap(TaskModel music) => {
    'name': music.name,
    'color': music.color,
  };

  static String encode(List<TaskModel> tasks) => json.encode(
    tasks
        .map<Map<String, dynamic>>((task) => TaskModel.toMap(task))
        .toList(),
  );

  static List<TaskModel> decode(String tasks) =>
      (json.decode(tasks) as List<dynamic>)
          .map<TaskModel>((item) => TaskModel.fromJson(item))
          .toList();
}