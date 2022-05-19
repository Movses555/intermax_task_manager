import 'package:intermax_task_manager/Privileges/privileges_constants.dart';
import 'package:intermax_task_manager/Privileges/privileges_for_current_user.dart';
import 'package:intermax_task_manager/Privileges/privileges_model.dart';
import 'package:intermax_task_manager/ServerSideApi/server_side_api.dart';
import 'package:intermax_task_manager/User%20State/user_state.dart';

class Privileges{

  static var privileges;

  static Privileges createInstance(){
    privileges ??= Privileges();

    return privileges;
  }

  Future getPrivileges(String name) async {
    var data = {'name' : name};
    return Future.wait([
      _getPrivileges(data)
    ]);
  }


  Future getPrivilegesForCurrentUser(String name) async {
    var data = {'name' : name};
    return Future.wait([
      ServerSideApi.create(UserState.temporaryIp, 8).getPrivileges(data)
    ]).then((value){
      PrivilegesModel? privilegesModel = value[0].body;
      if(privilegesModel != null){
        PrivilegesForCurrentUser.ADD_NEW_TASK = privilegesModel.addNewTask;
        PrivilegesForCurrentUser.EDIT_TASK = privilegesModel.editTask;
        PrivilegesForCurrentUser.DELETE_TASK = privilegesModel.deleteTask;
        PrivilegesForCurrentUser.GET_TASK_INFO = privilegesModel.getTaskInfo;
        PrivilegesForCurrentUser.ASSIGN_TASK_TO_BRIGADE = privilegesModel.assignTaskToBrigade;
        PrivilegesForCurrentUser.CHANGE_TASK_STATUS = privilegesModel.changeTaskStatus;
        PrivilegesForCurrentUser.REGISTER_ADMIN = privilegesModel.registerAdmin;
        PrivilegesForCurrentUser.REGISTER_BRIGADE = privilegesModel.registerBrigade;
        PrivilegesForCurrentUser.SETTINGS = privilegesModel.settings;
        PrivilegesForCurrentUser.ADD_TASK_TEMPLATE = privilegesModel.addTaskTemplate;
        PrivilegesForCurrentUser.DELETE_TASK_TEMPLATE = privilegesModel.deleteTaskTemplate;
        PrivilegesForCurrentUser.ADD_BRIGADE = privilegesModel.addBrigade;
        PrivilegesForCurrentUser.DELETE_BRIGADE = privilegesModel.deleteBrigade;
        PrivilegesForCurrentUser.BACKUP_DATA = privilegesModel.backupData;
        PrivilegesForCurrentUser.RESTORE_BACKUP = privilegesModel.restoreBackup;
        PrivilegesForCurrentUser.CHANGE_PASSWORDS = privilegesModel.changePasswords;
        PrivilegesForCurrentUser.CHANGE_PRIVILEGES = privilegesModel.changePrivileges;
      }else{
        PrivilegesForCurrentUser.clear();
      }
    });
  }


  Future _getPrivileges(var data) async {
    return Future.wait([
      ServerSideApi.create(UserState.temporaryIp, 8).getPrivileges(data)
    ]).then((value){
      PrivilegesModel? privilegesModel = value[0].body;
      if(privilegesModel != null){
        PrivilegesConstants.ADD_NEW_TASK = privilegesModel.addNewTask;
        PrivilegesConstants.EDIT_TASK = privilegesModel.editTask;
        PrivilegesConstants.DELETE_TASK = privilegesModel.deleteTask;
        PrivilegesConstants.GET_TASK_INFO = privilegesModel.getTaskInfo;
        PrivilegesConstants.ASSIGN_TASK_TO_BRIGADE = privilegesModel.assignTaskToBrigade;
        PrivilegesConstants.CHANGE_TASK_STATUS = privilegesModel.changeTaskStatus;
        PrivilegesConstants.REGISTER_ADMIN = privilegesModel.registerAdmin;
        PrivilegesConstants.REGISTER_BRIGADE = privilegesModel.registerBrigade;
        PrivilegesConstants.SETTINGS = privilegesModel.settings;
        PrivilegesConstants.ADD_TASK_TEMPLATE = privilegesModel.addTaskTemplate;
        PrivilegesConstants.DELETE_TASK_TEMPLATE = privilegesModel.deleteTaskTemplate;
        PrivilegesConstants.ADD_BRIGADE = privilegesModel.addBrigade;
        PrivilegesConstants.DELETE_BRIGADE = privilegesModel.deleteBrigade;
        PrivilegesConstants.BACKUP_DATA = privilegesModel.backupData;
        PrivilegesConstants.RESTORE_BACKUP = privilegesModel.restoreBackup;
        PrivilegesConstants.CHANGE_PASSWORDS = privilegesModel.changePasswords;
        PrivilegesConstants.CHANGE_PRIVILEGES = privilegesModel.changePrivileges;
      }
    });
  }
}