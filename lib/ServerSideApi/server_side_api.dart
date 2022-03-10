import 'package:chopper/chopper.dart';
import 'package:intermax_task_manager/Brigades%20Settings/brigade_details.dart';
import 'package:intermax_task_manager/JSON%20Converter/JsonToTypeConverter.dart';
import 'package:intermax_task_manager/Tasks%20Settings/task_server_model.dart';
import 'package:intermax_task_manager/User%20Details/user_details.dart';

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

  @Post(path: '/get_tasks.php')
  Future<Response<List<TaskServerModel>>> getTasks(@Body() var data);

  @Post(path: '/get_brigade_tasks.php')
  Future<Response<List<TaskServerModel>>> getBrigadeTask(@Body() var data);


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
    }

    final client = ChopperClient(
      baseUrl: 'http://$ip:1072/Intermax Task Manager',
      services: [_$ServerSideApi()],
      converter: converter,
    );

    return _$ServerSideApi(client);
  }
}