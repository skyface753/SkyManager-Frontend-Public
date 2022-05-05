import 'package:flutter/material.dart';
import 'package:skymanager/models/currticket.dart';
import 'package:skymanager/models/eintrag.dart';
import 'package:skymanager/models/role.dart';
import 'package:skymanager/models/ticket.dart';
import 'package:skymanager/models/user.dart';
import 'package:skymanager/services/api_requests.dart' as api;

import '../../../services/globals.dart' as globals; // global variables

Future<List<CurrTicket>> loadCurrentTicketList(BuildContext context) async {
  var currTicketList = <CurrTicket>[];
  await api
      .getCurrentTicket(globals.currentTicketID.toString(), context)
      .then((value) {
    Iterable list = value;
    currTicketList = list.map((model) => CurrTicket.fromJson(model)).toList();
  });
  return currTicketList;
  // throw Exception('Failed to load current ticket list');
}

Future<List<Eintrag>> loadCurrentEintraegeList(BuildContext context) async {
  var eintraegeList = <Eintrag>[];
  await api
      .getCurrentEintraege(globals.currentTicketID.toString(), context)
      .then((response) {
    Iterable list = response;
    eintraegeList = list.map((model) => Eintrag.fromJson(model)).toList();
  });
  return eintraegeList;
}

Future<List<User>> loadUserList(BuildContext context) async {
  var userList = <User>[];
  await api.getUser(context).then((response) {
    Iterable list = response;
    userList = list.map((model) => User.fromJson(model)).toList();
    globals.zustaendige = userList;
  });
  return userList;
}

Future<List<Role>> loadRoleList(BuildContext context) async {
  var roleList = <Role>[];
  await api.getRoles(context).then((response) {
    Iterable list = response;
    roleList = list.map((model) => Role.fromJson(model)).toList();
    globals.roleList = roleList;
  });
  return roleList;
}

Future<List<Ticket>> loadTicketList(BuildContext context) async {
  var ticketList = <Ticket>[];
  await api.getTickets(context).then((response) {
    if (response != null) {
      Iterable list = response;
      ticketList = list.map((model) => Ticket.fromJson(model)).toList();
      globals.ticketList = ticketList;
    }
  });
  return ticketList;
}
