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
    this.status
  });

  factory TaskServerModel.fromJson(Map<String, dynamic> json) => _$TaskServerModelFromJson(json);
  Map<String, dynamic> toJson() => _$TaskServerModelToJson(this);
}