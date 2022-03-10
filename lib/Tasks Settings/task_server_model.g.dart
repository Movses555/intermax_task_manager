// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_server_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskServerModel _$TaskServerModelFromJson(Map<String, dynamic> json) =>
    TaskServerModel(
      id: json['id'],
      task: json['task'],
      address: json['address'],
      telephone: json['telephone'],
      brigade: json['brigade'],
      date: json['date'],
      time: json['time'],
      isUrgent: json['urgent'],
      note1: json['note_1'],
      note2: json['note_2'],
      color: json['color'],
      addedBy: json['added_by'],
      status: json['status'],
      onWayTime: json['on_way_time'],
      workTime: json['work_time'],
      allTaskTime: json['all_task_time'],
    );

Map<String, dynamic> _$TaskServerModelToJson(TaskServerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'task': instance.task,
      'address': instance.address,
      'telephone': instance.telephone,
      'brigade': instance.brigade,
      'date': instance.date,
      'time': instance.time,
      'urgent': instance.isUrgent,
      'note_1': instance.note1,
      'note_2': instance.note2,
      'color': instance.color,
      'added_by': instance.addedBy,
      'status': instance.status,
      'on_way_time': instance.onWayTime,
      'work_time': instance.workTime,
      'all_task_time': instance.allTaskTime,
    };
