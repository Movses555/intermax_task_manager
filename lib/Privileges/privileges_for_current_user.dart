class PrivilegesForCurrentUser{

  static var ADD_NEW_TASK = true;
  static var EDIT_TASK = true;
  static var DELETE_TASK = true;
  static var GET_TASK_INFO = true;


  static var ASSIGN_TASK_TO_BRIGADE = true;
  static var CHANGE_TASK_STATUS = true;


  static var REGISTER_ADMIN = true;
  static var REGISTER_BRIGADE = true;


  static var SETTINGS = true;


  static var ADD_TASK_TEMPLATE = true;
  static var DELETE_TASK_TEMPLATE = true;


  static var ADD_BRIGADE = true;
  static var DELETE_BRIGADE = true;


  static var BACKUP_DATA = true;
  static var RESTORE_BACKUP = true;


  static var CHANGE_PASSWORDS = true;


  static var CHANGE_PRIVILEGES = true;



  static void clear(){
    ADD_NEW_TASK = true;
    EDIT_TASK = true;
    DELETE_TASK = true;
    GET_TASK_INFO = true;
    ASSIGN_TASK_TO_BRIGADE = true;
    CHANGE_TASK_STATUS = true;
    REGISTER_ADMIN = true;
    REGISTER_BRIGADE = true;
    SETTINGS = true;
    ADD_TASK_TEMPLATE = true;
    DELETE_TASK_TEMPLATE = true;
    ADD_BRIGADE = true;
    DELETE_BRIGADE = true;
    BACKUP_DATA = true;
    RESTORE_BACKUP = true;
    CHANGE_PASSWORDS = true;
    CHANGE_PRIVILEGES = true;
  }
}