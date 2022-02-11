import 'package:json_annotation/json_annotation.dart';

part 'brigade_details.g.dart';

@JsonSerializable()
class Brigade{

  @JsonKey(name: 'name')
  var username;

  @JsonKey(name: 'brigade')
  var brigade;

  @JsonKey(name: 'status')
  var status;

  Brigade({
     this.username,
     this.brigade,
     this.status
  });

  factory Brigade.fromJson(Map<String, dynamic> json) => _$BrigadeFromJson(json);

  Map<String, dynamic> toJson() => _$BrigadeToJson(this);
}