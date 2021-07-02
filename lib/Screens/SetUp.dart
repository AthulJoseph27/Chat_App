import 'package:chat_room_app/Globals.dart';
import 'package:chat_room_app/Network/Client.dart';
import 'package:chat_room_app/Screens/Themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'Home.dart';

class SetUp extends StatefulWidget {
  const SetUp({Key key}) : super(key: key);

  @override
  _SetUpState createState() => _SetUpState();
}

class _SetUpState extends State<SetUp> {
  bool male = true;
  bool available = true;
  bool loading = false;
  String userName;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: DarkTheme.darkPurple,
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: <Widget>[
                Spacer(),
                Container(
                  alignment: Alignment(-1, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ChatRoom',
                        style: TextStyle(
                            color: LightTheme.starWhite,
                            fontWeight: FontWeight.w400,
                            fontSize: 36),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Icon(
                        Icons.chat_bubble,
                        color: LightTheme.starWhite,
                      ),
                    ],
                  ),
                ),
                Spacer(
                  flex: 2,
                ),
                Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(75)),
                    color: DarkTheme.lightPurple,
                  ),
                  child: male
                      ? SvgPicture.asset('assets/male_avatar.svg')
                      : SvgPicture.asset('assets/female_avatar.svg'),
                ),
                Spacer(
                  flex: 2,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      Container(
                        child: Text(
                          'User Name',
                          style: TextStyle(
                              color: LightTheme.starWhite.withOpacity(0.8),
                              fontWeight: FontWeight.w600,
                              fontSize: 20),
                        ),
                        alignment: Alignment(-0.95, 0),
                      ),
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          maxLines: 1,
                          style: TextStyle(
                              color: LightTheme.starWhite, fontSize: 18),
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: LightTheme.starWhite.withOpacity(0.8)),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: LightTheme.starWhite.withOpacity(0.8)),
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: LightTheme.starWhite.withOpacity(0.8)),
                            ),
                            contentPadding: EdgeInsets.only(left: 10),
                            filled: false,
                          ),
                          onChanged: (val) {
                            userName = val;
                          },
                          validator: (val) => val.isEmpty
                              ? 'Enter your name'
                              : (available
                                  ? null
                                  : 'User Name is already taken!'),
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(
                  flex: 2,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Theme(
                        data: ThemeData.dark(),
                        child: Row(
                          children: <Widget>[
                            Spacer(),
                            Text(
                              'Male',
                              style: TextStyle(
                                  color: LightTheme.starWhite.withOpacity(0.8),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18),
                            ),
                            Radio(
                                activeColor: LightTheme.starWhite,
                                focusColor: LightTheme.starWhite,
                                value: true,
                                groupValue: male,
                                onChanged: (value) {
                                  setState(() {
                                    male = value;
                                  });
                                }),
                            Spacer(),
                            Text(
                              'Female',
                              style: TextStyle(
                                  color: LightTheme.starWhite.withOpacity(0.8),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18),
                            ),
                            Radio(
                                activeColor: LightTheme.starWhite,
                                value: false,
                                groupValue: male,
                                onChanged: (value) {
                                  setState(() {
                                    male = value;
                                  });
                                }),
                            Spacer(),
                          ],
                        ),
                      )),
                ),
                Spacer(
                  flex: 2,
                ),
                GestureDetector(
                  onTap: () async {
                    available = true;

                    if (!_formKey.currentState.validate()) return;

                    setState(() {
                      loading = true;
                    });

                    ChatRoomClient client = ChatRoomClient(null, userName);
                    client.connectToServer();

                    Function _listener;

                    _listener = () {
                      print(userNameValidator.value);
                      if (userNameValidator.value == PENDING) return;
                      if (userNameValidator.value == ACCEPTED) {
                        available = true;

                        setState(() {
                          loading = false;
                        });
                        print("HELLO!!!!!!!!!!!!!!!!!!");
                        userNameValidator.removeListener(_listener);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return Home(
                                male: male,
                                userName: userName,
                                client:client,
                              );
                            },
                          ),
                        );

                      }

                      if (userNameValidator.value == DECLINED)
                        available = false;

                      setState(() {
                        loading = false;
                      });

                      _formKey.currentState.validate();

                      userNameValidator.removeListener(_listener);
                    };

                    userNameValidator.addListener(_listener);
                  },
                  child: Container(
                    width: 150,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(40)),
                      color: DarkTheme.deepIndigoAccent,
                    ),
                    child: Center(
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                            color: LightTheme.starWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
