import 'package:json_annotation/json_annotation.dart';

part 'user_details.g.dart';

@JsonSerializable()
class User{

  @JsonKey(name: 'name')
  var username;

  @JsonKey(name: 'status')
  var status;

  User({this.username, this.status});
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}