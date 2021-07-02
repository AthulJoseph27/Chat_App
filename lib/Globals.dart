import 'package:flutter/cupertino.dart';

final ValueNotifier<bool>lightTheme = ValueNotifier<bool>(true);
final ValueNotifier<bool>refreshChat = ValueNotifier<bool>(true);
final ValueNotifier<int>userNameValidator = ValueNotifier<int>(FINISHED);
final ValueNotifier<int>onlineUsersUpdate = ValueNotifier<int>(FINISHED);

const int PENDING = 0;
const int ACCEPTED = 1;
const int DECLINED = 2;
const int FINISHED = 3;
const int UPDATE = 4;