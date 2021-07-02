import 'package:shared_preferences/shared_preferences.dart';

class StorageHandler{
  static const String _MALE = 'CHAT_ROOM_KEY=MALE';
  static const String _USERNAME = 'CHAT_ROOM_KEY=USERNAME';

  static Future<void>saveData(String userName, bool male)async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    _prefs.setBool(_MALE, male);
    _prefs.setString(_USERNAME, userName);
  }

  static Future<Map<String,dynamic>>loadData()async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    Map<String,dynamic>result = Map();

    try {
      result['male'] = _prefs.get(_MALE);
      result['userName'] = _prefs.get(_USERNAME);
    }catch(_){
    }

    return result;
  }

}

