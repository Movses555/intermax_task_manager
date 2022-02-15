// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      username: json['name'],
      status: json['status'],
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'name': instance.username,
      'status': instance.status,
    };
