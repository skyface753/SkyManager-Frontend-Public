import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skymanager/services/api_requests.dart' as api;
import 'package:skymanager/services/globals.dart' as globals;
import 'package:universal_html/html.dart'; // global variables

class ReadWriteDatas {
  Future<void> writeDatas() async {
    // write datas to shared preferences
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('serverUrl', api.serverUrl);
    prefs.setString('username', globals.ownUsername);
    prefs.setString('ownRoleFK', globals.ownRoleFK);
    prefs.setString('ownEMail', globals.ownEMail);
    prefs.setBool('stayLoggedIn', globals.stayLoggedIn);
    prefs.setBool('twofaEnabled', globals.twofaEnabled);
    if (kIsWeb) {
      window.sessionStorage['token'] = api.token;
      if (globals.stayLoggedIn) {
        prefs.setString('token', api.token);
      }
    } else {
      prefs.setString('token', api.token);
    }
  }

  Future<void> readDatas() async {
    // read the data from the shared preferences
    final prefs = await SharedPreferences.getInstance();

    api.serverUrl = prefs.getString('serverUrl') ?? "";
    globals.ownUsername = prefs.getString('username') ?? "";
    globals.ownRoleFK = prefs.getString('ownRoleFK') ?? "";
    globals.ownEMail = prefs.getString('ownEMail') ?? "";
    globals.stayLoggedIn = prefs.getBool('stayLoggedIn') ?? false;
    globals.twofaEnabled = prefs.getBool('twofaEnabled') ?? false;
    if (kIsWeb) {
      api.token = window.sessionStorage['token'] ?? "";
      if (api.token == "") {
        api.token = prefs.getString('token') ?? "";
      }
    } else {
      api.token = prefs.getString('token') ?? "";
    }
  }

  Future<void> clearDatas() async {
    // clear all data
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('serverUrl');
    prefs.remove('username');
    prefs.remove('ownRoleFK');
    prefs.remove('ownEMail');
    prefs.remove('stayLoggedIn');
    prefs.remove('twofaEnabled');
    prefs.remove('token');
    window.sessionStorage.clear();
  }
}
