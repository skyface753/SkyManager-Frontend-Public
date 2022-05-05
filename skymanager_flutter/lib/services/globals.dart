library my_prj.globals;

import 'package:flutter/foundation.dart';
import 'package:skymanager/models/currticket.dart';
import 'package:skymanager/models/instance.dart';
import 'package:skymanager/models/kunde.dart';
import 'package:skymanager/models/role.dart';
import 'package:skymanager/models/task.dart';
import 'package:skymanager/models/ticket.dart';
import 'package:skymanager/models/user.dart';
import 'package:skymanager/models/wiki.dart';
import 'package:skymanager/models/zustand.dart';

var currentInstance = <Instance>[];

//Global variables on runtime
bool isLoggedIn = false;
bool stayLoggedIn = false;
bool sendMailEnabled = false;
String ownUsername = "";
String ownEMail = "";
String ownRoleFK = "";
String frontendUrl = "";
int currentTicketID = 0;
int currentTaskID = 0;
int currentKundeID = 0;

// ignore: prefer_typing_uninitialized_variables
var currentKunde;

var kunden = <Kunde>[];
var zustaende = <Zustand>[];
var zustaendige = <User>[];
var currTicketList = <CurrTicket>[];
var roleList = <Role>[];
var currentTasks = <Task>[];
var ticketList = <Ticket>[];
var wikiList = <Wiki>[];

String backendVersion = "";

// ignore: prefer_typing_uninitialized_variables
var currentWiki;

bool twofaEnabled = false;

//Average time for request
double averageTime = 0;
int requestCounter = 0;
addRequestTime(double requestTimeInSeconds) {
  averageTime = (averageTime * requestCounter + requestTimeInSeconds) /
      (requestCounter + 1);
  requestCounter++;
  if (kDebugMode) {
    print("Average request time: $averageTime");
  }
}

getAverageTimeRoundedInMillisecounds() {
  return (averageTime * 1000).round();
}
