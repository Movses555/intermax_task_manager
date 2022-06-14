import 'package:flutter/material.dart';
import 'package:intermax_task_manager/ServerSideApi/server_side_api.dart';
import 'package:intermax_task_manager/Tasks%20Settings/task_server_model.dart';
import 'package:intermax_task_manager/User%20State/user_state.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class StopWatchProvider extends ChangeNotifier{

  static late List<StopWatchTimer> _onWayTimerList;
  static late List<StopWatchTimer> _workTimersList;

  static List<TaskServerModel>? _tasksList;

  List<TaskServerModel>? get taskModelList => _tasksList;


  static void initTimers(List<TaskServerModel>? tasksList){
    print('inited');
    _tasksList = tasksList;

    _onWayTimerList = List.generate(tasksList!.length, (index) => StopWatchTimer());
    _workTimersList = List.generate(tasksList.length, (index) => StopWatchTimer());
  }

  void startOnWayTimer(int index){
      _onWayTimerList[index] = StopWatchTimer(
          mode: StopWatchMode.countUp,
          onChange: (value){
            _tasksList![index].onWayTime = StopWatchTimer.getDisplayTime(value, milliSecond: false);

            notifyListeners();
          }
      );

      _onWayTimerList[index].onExecute.add(StopWatchExecute.start);
  }


  void startWorkTimer(int index){
      _workTimersList[index] = StopWatchTimer(
          mode: StopWatchMode.countUp,
          onChange: (value){
            _tasksList![index].workTime = StopWatchTimer.getDisplayTime(value, milliSecond: false);

            notifyListeners();
          }
      );

      _workTimersList[index].onExecute.add(StopWatchExecute.start);
  }


  void updateTime(int index) async {
    DateTime dateTime1 = DateTime.now();

    String? onWayTimeStr = _tasksList![index].onWayTime.toString();
    String? workTimeStr = _tasksList![index].workTime.toString();

    int hours1 = int.parse(onWayTimeStr.split(':')[0]);
    int minutes1 = int.parse(onWayTimeStr.split(':')[1]);
    int seconds1 = int.parse(onWayTimeStr.split(':')[2]);

    int hours2 = int.parse(workTimeStr.split(':')[0]);
    int minutes2 = int.parse(workTimeStr.split(':')[1]);
    int seconds2 = int.parse(workTimeStr.split(':')[2]);

    DateTime onWayTimeDateTime = DateTime(dateTime1.year, dateTime1.month, dateTime1.day, hours1, minutes1, seconds1);

    DateTime allTaskTime = onWayTimeDateTime.add(Duration(hours: hours2, minutes: minutes2, seconds: seconds2));

    _tasksList![index].allTaskTime = allTaskTime.hour.toString().padLeft(2, '0') + ':' + allTaskTime.minute.toString().padLeft(2, '0') + ':' + allTaskTime.second.toString().padLeft(2, '0');

    var data = {
      'id' : _tasksList![index].id,
      'on_way_time' : onWayTimeStr,
      'work_time' : workTimeStr,
      'all_task_time' : _tasksList![index].allTaskTime
    };

    await ServerSideApi.create(UserState.temporaryIp, 1).setTime(data);
  }


  void stopOnWayTimer(int index){
    _onWayTimerList[index].onExecute.add(StopWatchExecute.stop);
    _onWayTimerList[index].onExecute.close();
    _onWayTimerList[index].dispose();

    notifyListeners();
  }

  void stopWorkTimer(int index){
    _workTimersList[index].onExecute.add(StopWatchExecute.stop);
    _workTimersList[index].onExecute.close();
    _workTimersList[index].dispose();

    notifyListeners();
  }

  void resetOnWayTimer(int index){
    _onWayTimerList[index].onExecute.add(StopWatchExecute.reset);

    notifyListeners();
  }

  void resetWorkTimer(int index){
    _workTimersList[index].onExecute.add(StopWatchExecute.reset);

    notifyListeners();
  }
}