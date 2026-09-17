import 'package:hive/hive.dart';

import '../models/user_session.dart';



class AuthStorage {


  static const boxName =
      "auth_box";



  static Future<void> save(

      UserSession session

      ) async {



    final box =
    await Hive.openBox(
        boxName
    );



    await box.put(
        "token",
        session.token
    );


    await box.put(
        "userId",
        session.userId
    );


    await box.put(
        "email",
        session.email
    );


  }





  static Future<String?> getToken()

  async {


    final box =
    await Hive.openBox(
        boxName
    );


    return box.get(
        "token"
    );


  }





  static Future<void> clear()

  async {


    final box =
    await Hive.openBox(
        boxName
    );


    await box.clear();


  }



}