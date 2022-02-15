// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brigade_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Brigade _$BrigadeFromJson(Map<String, dynamic> json) => Brigade(
      username: json['name'],
      brigade: json['brigade'],
      status: json['status'],
    );

Map<String, dynamic> _$BrigadeToJson(Brigade instance) => <String, dynamic>{
      'name': instance.username,
      'brigade': instance.brigade,
      'status': instance.status,
    };
