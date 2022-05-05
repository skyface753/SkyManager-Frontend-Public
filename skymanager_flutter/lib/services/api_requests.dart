// ignore_for_file: non_constant_identifier_names

library my_prj.globals;

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flash/flash.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skymanager/helpers/read_write_datas.dart';
import './globals.dart' as globals; // global variables

/*
import 'package:skymanager/services/api_requests.dart' as api;
*/

String serverUrl = "";
String token = "";

// 400 Bad Request - Invalid Input  // Logout
// 401 Unauthorized (Token Expired) //Retry Login
// 403 Forbidden (User is not an Admin)

Future requestApi(String url, var jsonEncodedBody, BuildContext context) async {
  var jsonDecodedBody = json.decode(jsonEncodedBody);
  jsonEncodedBody = json.encode(jsonDecodedBody);
  try {
    var apiUrl = serverUrl + url;
    // Starttime for request in ms
    int startTime = DateTime.now().millisecondsSinceEpoch;
    var response = await http
        .post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': token,
          },
          body: jsonEncodedBody,
        )
        .timeout(const Duration(seconds: 10));
    // Endtime for request in ms
    int endTime = DateTime.now().millisecondsSinceEpoch;
    // Duration of request in ms
    int duration = endTime - startTime;
    // Duration of request in s
    double durationS = duration / 1000;
    globals.addRequestTime(durationS);
    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        // ignore: prefer_typing_uninitialized_variables
        var returnResponse;
        try {
          returnResponse = json.decode(response.body);
        } catch (e) {
          returnResponse = response.body;
        }
        return returnResponse;
      } else {
        throw Exception("No Response from Server");
      }
    } else if (response.statusCode == 400) {
      // 400 Bad Request - Invalid Input  // Logout
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('username');
      prefs.remove('password');
      if (globals.isLoggedIn) {
        globals.isLoggedIn = false;
        if (kDebugMode) {
          print("Logged Out");
        }
        Navigator.pushReplacementNamed(context, "/Login");
      }
      if (kDebugMode) {
        print('Wrong credentials');
      }
      if (response.body == "TOTP Required" || response.body == "TOTP Failed") {
        context.showErrorBar(content: Text(response.body));
        return "TOTP";
      }
      return null;
    } else if (response.statusCode == 401) {
      if (kDebugMode) {
        print("Token expired");
      }
      context.showErrorBar(
          content: const Text("Token Expired - Please Login Again"));
      return null;
    }
  } catch (e) {
    if (kDebugMode) {
      print("Failed to load Post: " + e.toString());
    }
    context.showErrorBar(content: const Text("Failed to load Post"));

    return null;
  }
}

Future login(String username, String password, String totpCode,
    bool isLoginScreen, BuildContext context, bool stayLoggedIn) async {
  var responseUsername = "";
  var response = await requestApi(
      '/login',
      jsonEncode(<String, String>{
        'username': username,
        'password': password,
        'totpCode': totpCode,
        'stayLoggedIn': stayLoggedIn.toString()
      }),
      context);
  if (response != null) {
    if (response == "TOTP") {
      return "TOTP";
    }
    token = response['token'];
    responseUsername = response['username'];
    globals.isLoggedIn = true;
    // globals.token = responseToken,
    globals.ownUsername = responseUsername;
    globals.ownEMail = response['email'];
    globals.ownRoleFK = response['role_fk'];
    globals.sendMailEnabled = response['sendMailEnabled'];
    globals.frontendUrl = response['frontendUrl'] ?? "";
    globals.stayLoggedIn = stayLoggedIn;
    globals.backendVersion = response['backendVersion'];
    int twoFAEnabledInt = response['TOTPenabled'] ?? 0;
    globals.twofaEnabled = twoFAEnabledInt == 1 ? true : false;
    ReadWriteDatas().writeDatas();
    return responseUsername;
  } else {
    if (!isLoginScreen) {
      Navigator.pushReplacementNamed(context, "/Login");
      if (kDebugMode) {
        print("Replace LoginScreen");
      }
    }
    return false;
  }
}

Future requestApiCheckToken(String url, var jsonEncodedBody) async {
  var jsonDecodedBody = json.decode(jsonEncodedBody);
  jsonEncodedBody = json.encode(jsonDecodedBody);
  try {
    var apiUrl = serverUrl + url;
    var response = await http
        .post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': token,
          },
          body: jsonEncodedBody,
        )
        .timeout(const Duration(seconds: 2));
    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        // ignore: prefer_typing_uninitialized_variables
        var returnResponse;
        try {
          returnResponse = json.decode(response.body);
        } catch (e) {
          returnResponse = response.body;
        }
        return returnResponse;
      } else {
        return false;
      }
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}

Future<bool> checkLoginToken() async {
  var response = await requestApiCheckToken(
      '/users/checkLoginToken', jsonEncode(<String, String>{}));
  if (response != false) {
    globals.ownRoleFK = response['role_fk'];
    globals.ownUsername = response['username'];
    globals.ownEMail = response['email'];
    globals.sendMailEnabled = response['sendMailEnabled'];
    globals.frontendUrl = response['frontendUrl'] ?? "";
    globals.isLoggedIn = true;
    int twoFAEnabledInt = response['TOTPenabled'] ?? 0;
    globals.backendVersion = response['backendVersion'];
    globals.twofaEnabled = twoFAEnabledInt == 1 ? true : false;
    return true;
  } else {
    globals.isLoggedIn = false;
    globals.ownUsername = "";
    globals.ownEMail = "";
    globals.ownRoleFK = "";
    globals.sendMailEnabled = false;
    globals.frontendUrl = "";
    return false;
  }
}

Future generateFirstTOTP(BuildContext context) async {
  var response = await requestApi(
      '/users/generateFirstTOTP', jsonEncode(<String, String>{}), context);
  if (response != "Already enabled") {
    return response;
  } else {
    return false;
  }
}

Future verifyFirstTOTP(String totpCode, BuildContext context) async {
  var response = await requestApi('/users/verifyFirstTOTP',
      jsonEncode(<String, String>{'totpCode': totpCode}), context);
  return response;
}

Future disableTOTP(String totpCode, BuildContext context) async {
  var response = await requestApi('/users/disableTOTP',
      jsonEncode(<String, String>{'totpCode': totpCode}), context);
  return response;
}

Future getCurrentTicket(String ticketID, BuildContext context) async {
  var response = await requestApi(
      '/tickets/getDetails',
      jsonEncode(<String, String>{
        'ticketID': ticketID,
      }),
      context);
  return response;
}

getCurrentEintraege(String ticketID, BuildContext context) async {
  var response = await requestApi(
      '/entries', jsonEncode(<String, String>{'ticketID': ticketID}), context);
  return response;
}

//let { ticketEintragID, newEintrag, newArbeitszeit } = req.body;
Future updateEntry(String ticketEintragID, String newEintrag,
    String newArbeitszeit, BuildContext context) async {
  var response = await requestApi(
      '/entries/update',
      jsonEncode(<String, String>{
        'ticketEintragID': ticketEintragID,
        'newEintrag': newEintrag,
        'newArbeitszeit': newArbeitszeit,
      }),
      context);
  return response;
}

Future deleteEntry(String entryID, BuildContext context) async {
  var response = await requestApi(
      '/entries/delete',
      jsonEncode(<String, String>{
        'ticketEintragID': entryID,
      }),
      context);
  return response;
}

// let { ticketID, newEintrag, newArbeitszeit, mailRecipient } = req.body;
Future createEntryWithSendMail(String ticketID, String newEintrag,
    String newArbeitszeit, String mailRecipient, BuildContext context) async {
  var response = await requestApi(
      '/entries/createEntryWithSendMail',
      jsonEncode(<String, String>{
        'ticketID': ticketID,
        'newEintrag': newEintrag,
        'newArbeitszeit': newArbeitszeit,
        'mailRecipient': mailRecipient,
      }),
      context);
  return response;
}

getUser(BuildContext context) async {
  var response =
      await requestApi('/users', jsonEncode(<String, String>{}), context);
  return response;
}

Future saveUsersLatestsTickets(
    String latestTickets, BuildContext context) async {
  var response = await requestApi(
      '/users/saveLastTickets',
      jsonEncode(<String, String>{
        'lastTickets': latestTickets,
      }),
      context);
  return response;
}

Future getUsersLatestsTickets(BuildContext context) async {
  var response = await requestApi(
      '/users/getLastTickets', jsonEncode(<String, String>{}), context);
  return response;
}

getRoles(BuildContext context) async {
  var response =
      await requestApi('/roles', jsonEncode(<String, String>{}), context);
  return response;
}

Future createUser(
    String username, password, email, BuildContext context) async {
  var response = await requestApi(
      '/users/create',
      jsonEncode(<String, String>{
        'username': username.toLowerCase(),
        'password': password,
        'email': email,
      }),
      context);
  return response;
}

Future enableUser(String username, BuildContext context) async {
  var response = await requestApi('/users/enableUser',
      jsonEncode(<String, String>{'username': username}), context);
  return response;
}

Future disableUser(String username, BuildContext context) async {
  var response = await requestApi('/users/disableUser',
      jsonEncode(<String, String>{'username': username}), context);
  return response;
}

Future changeUserRole(
    String username, choosenRole, BuildContext context) async {
  var response = await requestApi(
      '/users/changeRole',
      jsonEncode(
          <String, String>{'newRole': choosenRole, 'username': username}),
      context);
  return response;
}

Future changeUserPassword(
    String username, newPassword, BuildContext context) async {
  var response = await requestApi(
      '/users/changePassword',
      jsonEncode(
          <String, String>{'newPassword': newPassword, 'username': username}),
      context);
  // SnackBar snackBar = SnackBar(content: Text(response));
  // Scaffold.of(context).showSnackBar(snackBar);
  return response;
}

Future changeUserMail(String username, newMail, BuildContext context) async {
  var response = await requestApi(
      '/users/changeMail',
      jsonEncode(<String, String>{'newMail': newMail, 'username': username}),
      context);
  return response;
}

refreshToken(BuildContext context) async {
  var response = await requestApi(
      '/users/refreshToken', jsonEncode(<String, String>{}), context);
  try {
    token = response['token'];
    ReadWriteDatas().writeDatas();
    return true;
  } catch (e) {
    if (kDebugMode) {
      print("Token Refresh Error");
      print(e);
      inspect(response);
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Token not refreshed")));
    // token = "";
    return false;
  }
}

Future getZustaende(BuildContext context) async {
  var response =
      await requestApi('/states', jsonEncode(<String, String>{}), context);
  return response;
}

Future createTicket(String titel, beschreibung, kundenID, zustaendigID,
    zustandID, BuildContext context) async {
  var response = await requestApi(
      '/tickets/create',
      jsonEncode(<String, String>{
        'ticketTitle': titel,
        'ticketBeschreibung': beschreibung,
        'kundenID': kundenID,
        'zustaendigID': zustaendigID,
        'zustandID': zustandID,
      }),
      context);
  return response;
}

Future createCustomer(String name, mail, plz, stadt, strasse, hausnummer,
    BuildContext context) async {
  var response = await requestApi(
      '/customers/create',
      jsonEncode(<String, String>{
        'Name': name,
        'mail': mail,
        'PLZ': plz,
        'Stadt': stadt,
        'Strasse': strasse,
        'Hausnummer': hausnummer,
      }),
      context);
  return response;
}

Future getTickets(BuildContext context) async {
  var response =
      await requestApi('/tickets', jsonEncode(<String, String>{}), context);
  return response;
}

Future getMyTickets(BuildContext context) async {
  var response = await requestApi(
      '/tickets/myTickets', jsonEncode(<String, String>{}), context);
  return response;
}

Future getAllTickets(BuildContext context) async {
  var response = await requestApi(
      '/tickets/allTickets', jsonEncode(<String, String>{}), context);
  return response;
}

Future getTicketsFromUserForToday(BuildContext context) async {
  var response = await requestApi(
      '/tickets/today', jsonEncode(<String, String>{}), context);
  return response;
}

Future getCustomers(BuildContext context) async {
  var response =
      await requestApi('/customers', jsonEncode(<String, String>{}), context);
  return response;
}

Future getAllCustomers(BuildContext context) async {
  var response = await requestApi(
      '/customers/allCustomers', jsonEncode(<String, String>{}), context);
  return response;
}

Future getArchivedCustomers(BuildContext context) async {
  var response = await requestApi(
      '/customers/archivedCustomers', jsonEncode(<String, String>{}), context);
  return response;
}

Future archiveCustomer(String toDeleteKundeID, BuildContext context) async {
  var response = await requestApi(
      '/customers/archive',
      jsonEncode(<String, String>{
        'kundenID': toDeleteKundeID,
      }),
      context);
  return response;
}

Future reActivateCustomer(
    String toActivateKundeID, BuildContext context) async {
  var response = await requestApi(
      '/customers/reActivate',
      jsonEncode(<String, String>{
        'kundenID': toActivateKundeID,
      }),
      context);
  return response;
}

Future createEntry(
    String ticketID, newEintrag, time, BuildContext context) async {
  var response = await requestApi(
      '/entries/create',
      jsonEncode(<String, String>{
        'ticketID': ticketID,
        'newEintrag': newEintrag,
        'newArbeitszeit': time,
      }),
      context);
  return response;
}

Future updateTicket(String ticketID, titel, beschreibung, kundenID,
    zustaendigID, zustandID, BuildContext context) async {
  var response = await requestApi(
      '/tickets/updateDetails',
      jsonEncode(<String, String>{
        'ticketID': ticketID,
        'ticketTitle': titel,
        'ticketBeschreibung': beschreibung,
        'kundenID': kundenID,
        'zustaendigID': zustaendigID,
        'zustandID': zustandID,
      }),
      context);
  return response;
}

Future createCustomerPass(
    String kundenID, titel, username, password, BuildContext context) async {
  var response = await requestApi(
      '/passes/create',
      jsonEncode(<String, String>{
        'kundenID': kundenID,
        'Titel': titel,
        'Benutzername': username,
        'Passwort': password
      }),
      context);
  return response;
}

Future getCustomerPasses(String kundenID, BuildContext context) async {
  var response = await requestApi(
      '/passes',
      jsonEncode(<String, String>{
        'kundenID': kundenID,
      }),
      context);
  return response;
}

Future updatePass(String kundenPassID, titel, username, password,
    BuildContext context) async {
  var response = await requestApi(
      '/passes/edit',
      jsonEncode(<String, String>{
        'kundenPassID': kundenPassID,
        'Titel': titel,
        'Benutzername': username,
        'Passwort': password,
      }),
      context);
  return response;
}

Future deleteCustomerPass(String kundenPassID, BuildContext context) async {
  var response = await requestApi(
      '/passes/delete',
      jsonEncode(<String, String>{
        'kundenPassID': kundenPassID,
      }),
      context);
  return response;
}

Future updateCustomer(String kundenID, name, mail, plz, stadt, strasse,
    hausnummer, BuildContext context) async {
  var response = await requestApi(
      '/customers/edit',
      jsonEncode(<String, String>{
        "kundenID": kundenID,
        "Name": name,
        "mail": mail,
        "PLZ": plz,
        "Stadt": stadt,
        "Strasse": strasse,
        "Hausnummer": hausnummer,
      }),
      context);
  return response;
}

Future getActiveUserTasks(BuildContext context) async {
  var response =
      await requestApi('/tasks', jsonEncode(<String, String>{}), context);
  return response;
}

Future createTask(String title, description, datetime, ticket_fk, selectedUsers,
    BuildContext context) async {
  var response = await requestApi(
      '/tasks/create',
      jsonEncode(<String, String>{
        'title': title,
        'description': description,
        'datetime': datetime,
        'ticket_fk': ticket_fk,
        'selectedUsers': selectedUsers,
      }),
      context);
  return response;
}

Future updateTask(String taskID, title, description, datetime, ticket_fk,
    selectedUsers, BuildContext context) async {
  var response = await requestApi(
      '/tasks/update',
      jsonEncode(<String, String>{
        'taskID': taskID,
        'title': title,
        'description': description,
        'datetime': datetime,
        'ticket_fk': ticket_fk,
        'selectedUsers': selectedUsers,
      }),
      context);
  return response;
}

Future getTaskByID(String taskID, BuildContext context) async {
  var response = await requestApi(
      '/tasks/taskByID',
      jsonEncode(<String, String>{
        'taskID': taskID,
      }),
      context);
  return response;
}

// Future createTaskWithTicket(String title, description, datetime,
//     String ticket_fk, BuildContext context) async {
//   var response = await requestApi(
//       '/tasks/create',
//       jsonEncode(<String, String>{
//         'title': title,
//         'description': description,
//         'date': datetime,
//         'ticket_fk': ticket_fk,
//       }),
//       context);
//   return response;
// }

Future deleteTask(String taskID, BuildContext context) async {
  var response = await requestApi(
      '/tasks/delete',
      jsonEncode(<String, String>{
        'taskID': taskID,
      }),
      context);
  return response;
}

Future completeTask(String taskID, BuildContext context) async {
  var response = await requestApi(
      '/tasks/complete',
      jsonEncode(<String, String>{
        'taskID': taskID,
      }),
      context);
  return response;
}

Future reopenTask(String taskID, BuildContext context) async {
  var response = await requestApi(
      '/tasks/reopen',
      jsonEncode(<String, String>{
        'taskID': taskID,
      }),
      context);
  return response;
}

Future getWiki(BuildContext context) async {
  var response =
      await requestApi('/wiki', jsonEncode(<String, String>{}), context);
  return response;
}

Future getWikiByID(String wikiID, BuildContext context) async {
  var response = await requestApi(
      '/wiki/getWikiByID',
      jsonEncode(<String, String>{
        'wikiID': wikiID,
      }),
      context);
  return response;
}

Future createWiki(String title, description, BuildContext context) async {
  var response = await requestApi(
      '/wiki/create',
      jsonEncode(<String, String>{
        'title': title,
        'text': description,
      }),
      context);
  return response;
}

Future updateWiki(String wikiID, title, text, BuildContext context) async {
  var response = await requestApi(
      '/wiki/update',
      jsonEncode(<String, String>{
        'wikiID': wikiID,
        'title': title,
        'text': text,
      }),
      context);
  return response;
}

Future deleteWiki(String wikiID, BuildContext context) async {
  var response = await requestApi(
      '/wiki/delete',
      jsonEncode(<String, String>{
        'wikiID': wikiID,
      }),
      context);
  return response;
}

Future deleteDocu(String docID, BuildContext context) async {
  var response = await requestApi(
      '/docs/delete',
      jsonEncode(<String, String>{
        'docID': docID,
      }),
      context);
  return response;
}

Future getTotpPerCustomer(String customer_fk, BuildContext context) async {
  var response = await requestApi(
      '/totps',
      jsonEncode(<String, String>{
        'customer_fk': customer_fk,
      }),
      context);
  return response;
}

// secret, issuer, algorithm, digits, period, customer_fk
Future createTotp(String secret, String issuer, String algorithm, String digits,
    String period, String customer_fk, BuildContext context) async {
  var response = await requestApi(
      '/totps/create',
      jsonEncode(<String, String>{
        'secret': secret,
        'issuer': issuer,
        'algorithm': algorithm,
        'digits': digits,
        'period': period,
        'customer_fk': customer_fk,
      }),
      context);
  return response;
}

Future deleteTotp(String totp_id, BuildContext context) async {
  var response = await requestApi(
      '/totps/delete',
      jsonEncode(<String, String>{
        'totp_id': totp_id,
      }),
      context);
  return response;
}

Future importTotps(String customer_fk, importUrl, BuildContext context) async {
  var response = await requestApi(
      '/totps/import',
      jsonEncode(<String, String>{
        'dataUri': importUrl,
        'customer_fk': customer_fk,
      }),
      context);
  return response;
}
