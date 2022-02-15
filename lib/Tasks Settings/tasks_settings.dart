import 'package:intermax_task_manager/Tasks%20Settings/task_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Tasks{

  static Tasks? instance;
  static var _shPreferences;

  static List<TaskModel> _tasks = [];

  static void initPreferences() async {
    _shPreferences = await SharedPreferences.getInstance();
  }

  static void addTask(TaskModel task) {
    _tasks.add(task);
    final String encodedData = TaskModel.encode(_tasks);

    _shPreferences.setString('tasks_list', encodedData);
  }

  static void removeTask(TaskModel task) {
    _tasks.remove(task);

    final String encodedData = TaskModel.encode(_tasks);

    _shPreferences.setString('tasks_list', encodedData);
  }


  static List<TaskModel> getTasksList() {
    if(_shPreferences.getString('tasks_list') != null){
      String tasksString = _shPreferences.getString('tasks_list');
      List<TaskModel> tasks = TaskModel.decode(tasksString);
      _tasks = tasks;
    }

    return _tasks;
  }

  static void clearPreferences(){
    _shPreferences.clear();
  }

  static void clearList(){
    _tasks.clear();
  }
}