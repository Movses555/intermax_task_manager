import 'dart:convert';

import 'package:intermax_task_manager/FCM%20Controller/send_notification.dart';
import 'package:translit/translit.dart';

class NotifyBrigades {

  static var instance;

  static NotifyBrigades createInstance() {
    if (instance == null) {
      instance = NotifyBrigades();
      return instance;
    } else {
      return instance;
    }
  }

  void notify(String address, String brigade, String title, String date, String time, String isUrgent) {
    if(brigade == 'Эдо-Артур'){
      brigade = 'Edo-Artur';
    }
    String body = address + ", " + date + ", " + time + ", " + isUrgent;
    String notificationJsonData = '{"notification" : {"body" : "$body", "title" : "$title", "sound" : "default"}, "to" : "/topics/${Translit().toTranslit(source: brigade)}"}';

    Notify.create().notify(jsonDecode(notificationJsonData));
  }
}