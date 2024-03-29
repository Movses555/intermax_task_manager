import 'package:chopper/chopper.dart';
import 'package:intermax_task_manager/Brigade%20Model/brigade_model.dart';
import 'package:intermax_task_manager/Brigades%20Settings/brigade_details.dart';
import 'package:intermax_task_manager/JSON%20Converter/JsonToTypeConverter.dart';
import 'package:intermax_task_manager/Tasks%20Settings/task_model.dart';
import 'package:intermax_task_manager/Tasks%20Settings/task_server_model.dart';
import 'package:intermax_task_manager/User%20Details/user_details.dart';

import '../Backup File Model/back_up_file_model.dart';
import '../Privileges/privileges_model.dart';

part 'server_side_api.chopper.dart';

@ChopperApi()
abstract class ServerSideApi extends ChopperService{

  @Post(path: '/login_user.php')
  Future<Response<User>> loginUser(@Body() var data);

  @Post(path: '/login_brigade.php')
  Future<Response<Brigade>> loginBrigade(@Body() var data);

  @Post(path: '/register_user.php')
  Future<Response> registerUser(@Body() var data);

  @Post(path: '/register_brigade.php')
  Future<Response> registerBrigade(@Body() var data);

  @Post(path: '/add_task.php')
  Future<Response> addTask(@Body() var data);

  @Post(path: '/edit_task.php')
  Future<Response> editTask(@Body() var data);

  @Post(path: '/edit_notes1.php')
  Future<Response> editNotes1(@Body() var data);

  @Post(path: '/edit_notes2.php')
  Future<Response> editNotes2(@Body() var data);

  @Post(path: '/delete_task.php')
  Future<Response> deleteTask(@Body() var data);

  @Post(path: '/update_status.php')
  Future<Response> updateStatus(@Body() var data);

  @Post(path: '/update_time_1.php')
  Future<Response> updateOnWayTime(@Body() var data);

  @Post(path: '/update_time_2.php')
  Future<Response> updateWorkTime(@Body() var data);

  @Post(path: '/change_brigade.php')
  Future<Response> changeBrigade(@Body() var data);

  @Post(path: '/add_brigade.php')
  Future<Response> addBrigade(@Body() var data);

  @Post(path: '/add_task_to_list.php')
  Future<Response> addTaskToList(@Body() var data);

  @Post(path: '/delete_brigade_from_list.php')
  Future<Response> deleteBrigadeFromList(@Body() var data);

  @Post(path: '/delete_task_from_list.php')
  Future<Response> deleteTaskFromList(@Body() var data);

  @Post(path: '/back_up_data.php')
  Future<Response> backupData(@Body() var data);

  @Post(path: '/restore_backup.php')
  Future<Response> restoreBackup(@Body() var data);

  @Post(path: '/change_user_password.php')
  Future<Response> changeUserPassword(@Body() var data);

  @Post(path: '/change_brigade_password.php')
  Future<Response> changeBrigadePassword(@Body() var data);

  @Post(path: '/get_tasks.php')
  Future<Response<List<TaskServerModel>>> getTasks(@Body() var data);

  @Post(path: '/get_brigade_tasks.php')
  Future<Response<List<TaskServerModel>>> getBrigadeTask(@Body() var data);

  @Post(path: '/get_privileges.php')
  Future<Response<PrivilegesModel>> getPrivileges(@Body() var data);

  @Post(path: '/submit_privileges.php')
  Future<Response> submitPrivileges(@Body() var data);

  @Post(path: '/unregister_admin.php')
  Future<Response> unregisterAdmin(@Body() var data);

  @Post(path: '/unregister_brigade.php')
  Future<Response> unregisterBrigade(@Body() var data);

  @Post(path: '/set_time.php')
  Future<Response> setTime(@Body() var data);

  @Get(path: '/get_backup_files.php')
  Future<Response<List<BackupFile>>> getBackupFiles();

  @Get(path: '/get_tasks_from_server.php')
  Future<Response<List<TaskModel>>> getTasksFromServer();

  @Get(path: '/get_brigades_from_server.php')
  Future<Response<List<BrigadeModel>>> getBrigadesFromServer();

  @Get(path: '/get_admins.php')
  Future<Response<List<User>>> getAdmins();

  @Get(path: '/get_brigades.php')
  Future<Response<List<User>>> getBrigades();

  @Get(path: '/get_brigades_status.php')
  Future<Response<List<Brigade>>> getBrigadesStatus();



  static ServerSideApi create(String ip, int converterCode){
    JsonConverter? converter;

    switch(converterCode){
      case 1:
        converter = const JsonConverter();
        break;
      case 2:
        converter = JsonToTypeConverter({
          User: (json) => User.fromJson(json)
        });
        break;
      case 3:
        converter = JsonToTypeConverter({
          TaskServerModel: (json) => TaskServerModel.fromJson(json)
        });
        break;
      case 4:
        converter = JsonToTypeConverter({
          Brigade: (json) => Brigade.fromJson(json)
        });
        break;
      case 5:
        converter = JsonToTypeConverter({
          TaskModel: (json) => TaskModel.fromJson(json)
        });
        break;
      case 6:
        converter = JsonToTypeConverter({
          BrigadeModel: (json) => BrigadeModel.fromJson(json)
        });
        break;
      case 7:
        converter = JsonToTypeConverter({
          BackupFile: (json) => BackupFile.fromJson(json)
        });
        break;
      case 8:
        converter = JsonToTypeConverter({
          PrivilegesModel: (json) => PrivilegesModel.fromJson(json)
        });
        break;
    }

    final client = ChopperClient(
      baseUrl: 'http://$ip:1072/Intermax Task Manager',
      services: [_$ServerSideApi()],
      converter: converter,
    );

    return _$ServerSideApi(client);
  }
}