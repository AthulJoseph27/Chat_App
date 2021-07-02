import 'package:chat_room_app/Storage.dart';
import 'package:flutter/material.dart';

import 'Network/Client.dart';
import 'Screens/Home.dart';
import 'Screens/Loading.dart';
import 'Screens/SetUp.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loading = true;
  String userName;
  bool male;

  @override
  void initState() {
    super.initState();
    loading = false;
    // StorageHandler.loadData().then((Map<String, dynamic> data) {
    //   userName = data['userName'];
    //   male = data['male'];
    //   setState(() {
    //     loading = false;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    if (loading)
      return MaterialApp(
        home: Loading(),
      );

    if (userName != null) {
      ChatRoomClient client = ChatRoomClient(null, userName);
      return MaterialApp(
        home: Home(
          userName: userName,
          male: male,
          client: client,
        ),
      );
    }

    return MaterialApp(
      home: SetUp(),
    );
  }
}
