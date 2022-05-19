// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'privileges_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrivilegesModel _$PrivilegesModelFromJson(Map<String, dynamic> json) =>
    PrivilegesModel(
      addNewTask: json['add_new_task'],
      editTask: json['edit_task'],
      deleteTask: json['delete_task'],
      getTaskInfo: json['get_task_info'],
      assignTaskToBrigade: json['assign_task_to_brigade'],
      changeTaskStatus: json['change_task_status'],
      registerAdmin: json['register_admin'],
      registerBrigade: json['register_brigade'],
      settings: json['settings'],
      addTaskTemplate: json['add_task_template'],
      deleteTaskTemplate: json['delete_task_template'],
      addBrigade: json['add_brigade'],
      deleteBrigade: json['delete_brigade'],
      backupData: json['backup_data'],
      restoreBackup: json['restore_backup'],
      changePasswords: json['change_passwords'],
      changePrivileges: json['change_privileges'],
    );

Map<String, dynamic> _$PrivilegesModelToJson(PrivilegesModel instance) =>
    <String, dynamic>{
      'add_new_task': instance.addNewTask,
      'edit_task': instance.editTask,
      'delete_task': instance.deleteTask,
      'get_task_info': instance.getTaskInfo,
      'assign_task_to_brigade': instance.assignTaskToBrigade,
      'change_task_status': instance.changeTaskStatus,
      'register_admin': instance.registerAdmin,
      'register_brigade': instance.registerBrigade,
      'settings': instance.settings,
      'add_task_template': instance.addTaskTemplate,
      'delete_task_template': instance.deleteTaskTemplate,
      'add_brigade': instance.addBrigade,
      'delete_brigade': instance.deleteBrigade,
      'backup_data': instance.backupData,
      'restore_backup': instance.restoreBackup,
      'change_passwords': instance.changePasswords,
      'change_privileges': instance.changePrivileges,
    };
