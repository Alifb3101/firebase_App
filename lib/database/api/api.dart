import 'dart:convert';

import 'package:firebase/database/injection/injection.dart';


class API {
  getUserList() async {
    var res = await restClient.getUserList();
    return (res);
  }
  addUser(String names , String email)async{
    Map<String,dynamic> body = {
      "name"  : names,
      "email" : email
    };
    var res = await restClient.AddUser(body);
    return jsonDecode(res);
  }
}