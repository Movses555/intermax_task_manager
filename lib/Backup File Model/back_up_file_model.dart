import 'package:json_annotation/json_annotation.dart';

part 'back_up_file_model.g.dart';

@JsonSerializable()
class BackupFile{

  @JsonKey(name: 'filename')
  var filename;

  BackupFile({this.filename});

  factory BackupFile.fromJson(Map<String, dynamic> json) => _$BackupFileFromJson(json);

  Map<String, dynamic> toJson() => _$BackupFileToJson(this);
}