import 'package:shared_preferences/shared_preferences.dart';

class UserState {
  // ignore: prefer_typing_uninitialized_variables
  static var userName = '';
  // ignore: prefer_typing_uninitialized_variables
  static var temporaryIp = '';
  // ignore: prefer_typing_uninitialized_variables
  static var sharedPreferences;

  static Future<SharedPreferences> init() async {
    sharedPreferences = await SharedPreferences.getInstance();

    return sharedPreferences;
  }

  static void rememberUser(String ip, String name, String password) {
    sharedPreferences.setString('__ip', ip);
    sharedPreferences.setString('__name', name);
    sharedPreferences.setString('__password', password);
  }

  static void rememberBrigade(String brigade) {
    sharedPreferences.setString('__brigade', brigade);
  }

  static void rememberUserState(bool state) {
    sharedPreferences.setBool('user_state', state);
  }

  static String? getUserName() {
    var _name;
    if(sharedPreferences.getString('__name') != null){
      _name = sharedPreferences.getString('__name');
    } else {
      _name = userName;
    }

    return _name;
  }

  static String? getPassword() {
    var _password;
    if(sharedPreferences.getString('__password') != null){
      _password = sharedPreferences.getString('__password');
    }

    return _password;
  }

  static String? getIP() {
    var _ip;
    if (sharedPreferences.getString('__ip') != null) {
      _ip = sharedPreferences.getString('__ip');
    } else {
      _ip = temporaryIp;
    }
    return _ip;
  }

  static String? getBrigade() {
    var _brigade;
    if (sharedPreferences.getString('__brigade') != null) {
      _brigade = sharedPreferences.getString('__brigade');
    }
    return _brigade;
  }

  static Future<bool>? getSignInStatus() async {
    var status;
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getBool('user_state') != null) {
      status = sharedPreferences.getBool('user_state');
    }else{
      status = false;
    }
    return status;
  }

  static void clearBrigade() {
    sharedPreferences.getString('__brigade') == null;
  }

  static void clear() {
    sharedPreferences.clear();
    userName = '';
    temporaryIp = '';
  }
}