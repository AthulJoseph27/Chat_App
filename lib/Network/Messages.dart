import 'dart:convert';
import 'dart:io';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatMessages{
  int id;
  String userName;
  static const String _USERNAME = 'ChatMessages_Key=USERNAME';
  List<types.Message> messages = [];

  ChatMessages(id){
    this.id = id;
  }

  Future<void>loadMessages()async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    Directory dir = await getApplicationDocumentsDirectory();

    try{
      String path = dir.path;
      path += '/${id}_Messages';
      File file = File(path);

      userName = _prefs.getString(_USERNAME+id.toString());

      if(!file.existsSync())
        return;

      messages = jsonDecode(await file.readAsString());

    }catch(_){
    }

  }

  Future<void>saveMessage()async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    Directory dir = await getApplicationDocumentsDirectory();
    try{
      String path = dir.path;
      path += '/${id}_Messages';
      File file = File(path);

      _prefs.setString(_USERNAME+id.toString(), userName);

      if(file.existsSync())
        file.delete();

      file.writeAsString(jsonEncode(messages));

    }catch(_){
    }
  }

}