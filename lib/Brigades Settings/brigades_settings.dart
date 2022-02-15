import 'package:shared_preferences/shared_preferences.dart';

class Brigades{

  static Brigades? instance;
  static SharedPreferences? _shPreferences;

  static List<String> _brigades = [];

  static void initPreferences() async {
    _shPreferences = await SharedPreferences.getInstance();
  }

  static void addBrigade(String brigade){
    _brigades.add(brigade);

    _shPreferences!.setStringList('brigades_list', _brigades);
  }

  static void removeBrigade(String brigade){
    _brigades.remove(brigade);
    _shPreferences!.setStringList('brigades_list', _brigades);
  }

  static List<String>? getBrigadesList(){
    if(_shPreferences!.getStringList('brigades_list') != null){
      _brigades = _shPreferences!.getStringList('brigades_list')!;
    }

    return _brigades;
  }

  static void clear(){
    _brigades.clear();
    _shPreferences!.clear();
  }
}