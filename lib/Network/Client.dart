import 'dart:convert';
import 'dart:io';
import 'package:chat_room_app/Globals.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Person {
  String id;
  String userName;
  bool online;
  Person(String id, String userName, bool online) {
    this.id = id;
    this.userName = userName;
    this.online = online;
  }

  Map<String, dynamic> toJson() =>
      {'id': id, 'userName': userName, 'online': false};

  Person.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userName = json['userName'],
        online = json['online'];

  static Future<void> save(List<Person> list) async {
    Directory dir = await getApplicationDocumentsDirectory();

    String path = dir.path;
    path += '/All_Users_00';

    File file = File(path);

    if (await file.exists()) await file.delete();

    String json = jsonEncode(list);

    file.writeAsString(json);
  }

  static Future<List<Person>> load() async {
    Directory dir = await getApplicationDocumentsDirectory();

    String path = dir.path;
    path += '/All_Users_00';

    File file = File(path);

    if (!(await file.exists())) return [];

    List data = jsonDecode(await file.readAsString());
    List<Person> result = [];

    for (Map<String, dynamic> mp in data) result.add(Person.fromJson(mp));

    return result;
  }
}

class ChatRoomClient {
  static const int _PORT = 9086;
  // static const int _CONNECTION_REQUEST = 0;
  static const int _MESSAGE = 1;
  static const int _MY_ID = 2;
  static const int _STOP = 3;
  static const int _CHECK_USER_NAME = 4;
  static const String _SEPARATOR = '##CHAT_SERVICE##';
  static const String _USER_ID = 'CHAT_ROOM_KEY=USER_ID';
  static const String _AVAILABLE = '__A_V_A_I_L_A_B_L_E__';
  static const String _NOT_AVAILABLE = '__N_O_T___A_V_A_I_L_A_B_L_E__';
  static const String _GET_USERS = '__GET_ONLINE_USERS__';
  static const String _GROUP_MESSAGE = '___GROUP_MESSAGE___';
  // static const String _RECEIVED = '((MESSAGE_RECEIVED))';
  Socket _clientSocket;
  String _address;
  String userName;
  String _id = '-1';
  Map<String, List<types.Message>> messages;
  List<Person> onlineUsers = [];

  ChatRoomClient(String address, String userName) {
    this._address = address ?? 'localhost'; // Place IP address of the Server here.
    this.userName = userName;
    messages = Map();
  }

  // Future<void> loadUserId() async {
  //   SharedPreferences _prefs = await SharedPreferences.getInstance();
  //
  //   try {
  //     _id = _prefs.getString(_USER_ID);
  //   } catch (_) {
  //     _id = '-1';
  //   }
  //
  //   if (_id == null) _id = '-1';
  // }

  Future<void> saveUserId() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    try {
      _prefs.setString(_USER_ID, _id);
    } catch (_) {}
  }

  void checkUserNameAvailability(String userName) async {
    this.userName = userName;
    userNameValidator.value = PENDING;
    _clientSocket.writeln(
        _CHECK_USER_NAME.toString() + _SEPARATOR + userName + _SEPARATOR);
  }

  Future<bool> connectToServer() async {
    if (_clientSocket != null) return true;

    try {
      _clientSocket = await Socket.connect(_address, _PORT);

      _clientSocket.listen((List<int> event) {
        /// FLAG<>Name<>Name<>Message
        /// MY_ID<>ID
        List<String> data = utf8.decode(event).split(_SEPARATOR);

        print("DEBUGGING>>>");
        print(data);

        if (data.isEmpty) return;

        if (data[0] == _MY_ID.toString()) {
          _id = data[1];
          saveUserId();
          return;
        }

        if (data[0] == _CHECK_USER_NAME.toString()) {
          if (data[1] == _AVAILABLE) {
            userNameValidator.value = ACCEPTED;
          } else if (data[1] == _NOT_AVAILABLE) {
            userNameValidator.value = DECLINED;
          }
          return;
        }

        if (data[0] == _GET_USERS) {
          onlineUsersUpdate.value = PENDING;
          List<String> users = data[1].split(';<SPLIT>;');
          for (String user in users) onlineUsers.add(Person(user, user, true));
          onlineUsersUpdate.value = UPDATE;
          return;
        }

        if (data[0] == _GROUP_MESSAGE) {
          messages[_GROUP_MESSAGE].add(
            types.TextMessage(
              author: types.User(
                id: data[1],
                firstName: data[2],
              ),
              createdAt: DateTime.now().millisecondsSinceEpoch,
              id: const Uuid().v4(),
              text: data[3],
            ),
          );
        }

        if (data[0] != _MESSAGE.toString()) return;

        if (!messages.containsKey(data[1])) messages[data[1]] = [];

        messages[data[1]].add(
          types.TextMessage(
            author: types.User(
              id: data[1],
              firstName: data[2],
            ),
            createdAt: DateTime.now().millisecondsSinceEpoch,
            id: const Uuid().v4(),
            text: data[3],
          ),
        );

        refreshChat.value = !refreshChat.value;
      });

      // await loadUserId();

      _clientSocket.writeln('$_MY_ID$_SEPARATOR$_id$_SEPARATOR');
      if (_id == '-1') {
        userNameValidator.value = PENDING;
        _clientSocket
            .writeln('$_CHECK_USER_NAME$_SEPARATOR$userName$_SEPARATOR');
      }

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> sendMessage(
      String toUserName, String text, bool isGroupMessage) async {
    if (isGroupMessage) toUserName = _GROUP_MESSAGE;

    if (_clientSocket == null) {
      bool result = await connectToServer();
      if (!result) return false;
    }

    if (!messages.containsKey(toUserName)) messages[toUserName] = [];

    messages[toUserName].add(
      types.TextMessage(
        author: types.User(
          id: userName,
          firstName: userName,
        ),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: text,
      ),
    );

    /// FLAG<>ToID<>FromID<>message<>

    text = _MESSAGE.toString() +
        _SEPARATOR +
        toUserName +
        _SEPARATOR +
        userName +
        _SEPARATOR +
        text +
        _SEPARATOR;

    print("Text->"+text);

    _clientSocket.writeln(text);

    refreshChat.value = !refreshChat.value;

    return true;
  }

  Future<void> closeConnection() async {
    if (_clientSocket == null) return;

    _clientSocket.writeln("$_STOP$_SEPARATOR");
    _clientSocket.close();
  }

  Future<void> loadMessages() async {
    Directory dir = await getApplicationDocumentsDirectory();

    try {
      String path = dir.path;
      path += '/All_Messages';
      File file = File(path);

      if (file.existsSync()) {
        if (messages == null) {
          messages = Map();
        } else {
          messages.clear();
        }
        Map<String, dynamic> temp = jsonDecode(await file.readAsString());
        temp.forEach((key, value) {
          messages[key] = [];
          for (Map<String, dynamic> mp in value) {
            messages[key].add(types.Message.fromJson(mp));
          }
        });
      }
    } catch (_) {}
  }

  Future<void> saveMessage() async {
    Directory dir = await getApplicationDocumentsDirectory();
    try {
      String path = dir.path;
      path += '/All_Messages';
      File file = File(path);

      if (file.existsSync()) file.delete();

      await file.writeAsString(jsonEncode(messages));
    } catch (_) {}
  }

  void getOnlineUsers() {
    _clientSocket.writeln(_GET_USERS + _SEPARATOR);
  }
}
