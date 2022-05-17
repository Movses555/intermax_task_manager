import 'package:json_annotation/json_annotation.dart';

part 'brigade_model.g.dart';

@JsonSerializable()
class BrigadeModel{

  @JsonKey(name: 'id')
  var id;

  @JsonKey(name: 'name')
  var name;

  BrigadeModel({this.id, this.name});

  factory BrigadeModel.fromJson(Map<String, dynamic> json) => _$BrigadeModelFromJson(json);

  Map<String, dynamic> toJson() => _$BrigadeModelToJson(this);
}