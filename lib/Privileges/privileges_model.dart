import 'package:json_annotation/json_annotation.dart';

part 'privileges_model.g.dart';

@JsonSerializable()
class PrivilegesModel{

  @JsonKey(name: 'add_new_task')
  var addNewTask;

  @JsonKey(name: 'edit_task')
  var editTask;

  @JsonKey(name: 'delete_task')
  var deleteTask;

  @JsonKey(name: 'get_task_info')
  var getTaskInfo;

  @JsonKey(name: 'assign_task_to_brigade')
  var assignTaskToBrigade;

  @JsonKey(name: 'change_task_status')
  var changeTaskStatus;

  @JsonKey(name: 'register_admin')
  var registerAdmin;

  @JsonKey(name: 'register_brigade')
  var registerBrigade;

  @JsonKey(name: 'settings')
  var settings;

  @JsonKey(name: 'add_task_template')
  var addTaskTemplate;

  @JsonKey(name: 'delete_task_template')
  var deleteTaskTemplate;

  @JsonKey(name: 'add_brigade')
  var addBrigade;

  @JsonKey(name: 'delete_brigade')
  var deleteBrigade;

  @JsonKey(name: 'backup_data')
  var backupData;

  @JsonKey(name: 'restore_backup')
  var restoreBackup;

  @JsonKey(name: 'change_passwords')
  var changePasswords;

  @JsonKey(name: 'change_privileges')
  var changePrivileges;


  PrivilegesModel({
    this.addNewTask,
    this.editTask,
    this.deleteTask,
    this.getTaskInfo,
    this.assignTaskToBrigade,
    this.changeTaskStatus,
    this.registerAdmin,
    this.registerBrigade,
    this.settings,
    this.addTaskTemplate,
    this.deleteTaskTemplate,
    this.addBrigade,
    this.deleteBrigade,
    this.backupData,
    this.restoreBackup,
    this.changePasswords,
    this.changePrivileges,
  });

  factory PrivilegesModel.fromJson(Map<String, dynamic> json) => _$PrivilegesModelFromJson(json);

  Map<String, dynamic> toJson() => _$PrivilegesModelToJson(this);

}