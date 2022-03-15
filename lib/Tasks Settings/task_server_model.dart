import 'package:json_annotation/json_annotation.dart';

part 'task_server_model.g.dart';

@JsonSerializable()
class TaskServerModel{

  @JsonKey(name: 'id')
  var id;

  @JsonKey(name: 'task')
  var task;

  @JsonKey(name: 'address')
  var address;

  @JsonKey(name: 'telephone')
  var telephone;

  @JsonKey(name: 'brigade')
  var brigade;

  @JsonKey(name: 'date')
  var date;

  @JsonKey(name: 'time')
  var time;

  @JsonKey(name: 'urgent')
  var isUrgent;

  @JsonKey(name: 'note_1')
  var note1;

  @JsonKey(name: 'note_2')
  var note2;

  @JsonKey(name: 'color')
  var color;

  @JsonKey(name: 'added_by')
  var addedBy;

  @JsonKey(name: 'status')
  var status;

  @JsonKey(name: 'on_way_time')
  var onWayTime;

  @JsonKey(name: 'work_time')
  var workTime;

  @JsonKey(name: 'all_task_time')
  var allTaskTime;

  @JsonKey(name: 'cords')
  var cords;

  TaskServerModel({
    this.id,
    this.task,
    this.address,
    this.telephone,
    this.brigade,
    this.date,
    this.time,
    this.isUrgent,
    this.note1,
    this.note2,
    this.color,
    this.addedBy,
    this.status,
    this.onWayTime,
    this.workTime,
    this.allTaskTime,
    this.cords
  });

  factory TaskServerModel.fromJson(Map<String, dynamic> json) => _$TaskServerModelFromJson(json);
  Map<String, dynamic> toJson() => _$TaskServerModelToJson(this);
}