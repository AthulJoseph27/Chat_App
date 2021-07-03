import 'package:chat_room_app/Network/Client.dart';
import 'package:chat_room_app/Screens/Chat.dart';
import 'package:chat_room_app/Screens/Themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../Globals.dart';

class Home extends StatefulWidget {
  final String userName;
  final bool male;
  final ChatRoomClient client;

  const Home({Key key, this.userName, this.male, this.client})
      : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool loading = false;
  static List<Person> _peoples = [];

  @override
  void initState() {
    super.initState();

    loading = true;

    Person.load().then((value) {
      _peoples = value;
    }).then((value) {
      widget.client.connectToServer().then((value) {
        Function _listener;
        _listener = () {
          if (onlineUsersUpdate.value == FINISHED) return;

          if (onlineUsersUpdate.value == UPDATE) {
            Map<String, Person> mp = Map();

            for (Person p in widget.client.onlineUsers)
              mp[p.id] = Person(p.id, p.userName, true);

            for (Person p in _peoples)
              if (mp.containsKey(p.id)) {
                p.online = true;
              } else {
                p.online = false;
              }

            Map<String, bool> mp2 = Map();

            for (Person p in _peoples) mp2[p.id] = true;

            mp.forEach((key, value) {
              // print(key);
              // print('^'*20);
              if (!mp2.containsKey(key)) _peoples.add(value);
            });

            // for(var value in _peoples)
            //   print(value.id+" "+value.userName);



            setState(() {});
          }
        };
        onlineUsersUpdate.addListener(_listener);
        widget.client.getOnlineUsers();
      });
    });
  }

  @override
  void dispose() async {
    await Person.save(_peoples);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: DarkTheme.darkPurple,
        appBar: AppBar(
          backgroundColor: DarkTheme.deepIndigoAccent,
          title: Text(
            'ChatRoom',
            style: TextStyle(color: LightTheme.starWhite),
          ),
        ),
        body: ListView.builder(
          itemCount: _peoples.length+1,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0)
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ChatRoom(
                            userName: widget.userName,
                            client: widget.client,
                            other: Person(
                              '___GROUP_MESSAGE___',
                              '___GROUP_MESSAGE___',
                              true
                            ),
                          );
                        },
                      ),
                    );
                  },
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      child: Container(
                        height: 45,
                        width: 45,
                        color: DarkTheme.darkGray,
                      ),
                    ),
                    title: Text(
                      'Group Chat',
                      style: TextStyle(color: LightTheme.starWhite),
                    ),
                  ),
                ),
              );
            index--;
            print(_peoples[index].userName);
            print('|'*20);
            print(widget.userName);
            print('{'*20);
            if(_peoples[index].userName == widget.userName)
              return Container();

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ChatRoom(
                          userName: widget.userName,
                          client: widget.client,
                          other: _peoples[index],
                        );
                      },
                    ),
                  );
                },
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                    child: Container(
                      height: 55,
                      width: 55,
                      color: DarkTheme.darkGray,
                      padding: EdgeInsets.all(1),
                      child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                          child:SvgPicture.asset('assets/male_avatar.svg')
                              ),
                    ),
                  ),
                  title: Text(
                    _peoples[index].userName,
                    style: TextStyle(color: LightTheme.starWhite),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                        child: Container(
                          width: 10,
                          height: 10,
                          color: _peoples[index].online ? Colors.green : Colors.amber,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        _peoples[index].online ? 'Online' : 'Offline',
                        style: TextStyle(color: LightTheme.starWhite),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
