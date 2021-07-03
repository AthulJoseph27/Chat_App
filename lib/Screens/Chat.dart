import 'package:chat_room_app/Globals.dart';
import 'package:chat_room_app/Network/Client.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:open_file/open_file.dart';

class ChatRoom extends StatefulWidget {
  final String userName;
  final ChatRoomClient client;
  final Person other;
  const ChatRoom({Key key,this.userName,this.client,this.other}) : super(key: key);

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  types.User _user;

  @override
  void initState() {
    super.initState();
    if(widget.client.messages[widget.other.userName] == null)
        widget.client.messages[widget.other.userName] = [];
    _user = types.User(id: widget.userName,firstName: widget.userName);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ValueListenableBuilder(
          valueListenable: refreshChat,
          builder: (BuildContext context, var value, Widget child){
            return Chat(
              messages: widget.client.messages[widget.other.userName].reversed.toList(),
              showUserAvatars: true,
              theme: DarkChatTheme(),
              onMessageTap: _handleMessageTap,
              onSendPressed: _handleSendPressed,
              user: _user,
              showUserNames: true,
            );
          },
        ),
      ),
    );
  }

  void _handleMessageTap(types.Message message) async {
    if (message is types.FileMessage) {
      await OpenFile.open(message.uri);
    }
  }

  void _handleSendPressed(types.PartialText message) {
    widget.client.sendMessage(widget.other.userName,message.text,widget.other.userName == '___GROUP_MESSAGE___');
  }



}
