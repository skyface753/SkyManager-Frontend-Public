import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:skymanager/models/ticket.dart';
import '../../../services/globals.dart' as globals; // global variables
import 'package:skymanager/services/api_requests.dart' as api;

class TicketView extends StatelessWidget {
  final List<Ticket> tickets;
  final int index;
  final VoidCallback? afterOnClick;

  const TicketView(
      {Key? key, required this.tickets, required this.index, this.afterOnClick})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
      trailing: Icon(tickets[index].zustand == "open"
          ? Icons.lock_open
          : tickets[index].zustand == "in progress"
              ? Icons.work
              : tickets[index].zustand == "closed"
                  ? Icons.lock
                  : Icons.lock_outline),
      title:
          Text("#" + tickets[index].id.toString() + " " + tickets[index].titel),
      subtitle: Text(tickets[index].kundenname),
      onTap: () {
        globals.currentTicketID = tickets[index].id;
        _addTicketToLatestTickets(tickets[index], context);
        Navigator.pushNamed(context, '/tickets/details').then((value) {
          afterOnClick?.call();
          FocusScope.of(context).unfocus();
        });
      },
    ));
  }

  // Add ticket to latest tickets
  _addTicketToLatestTickets(Ticket ticket, BuildContext context) async {
    List<int> ids = await getLatestTickets(context);
    if (ids.isNotEmpty) {
      for (int i = 0; i < ids.length; i++) {
        if (ids[i] == ticket.id) {
          ids.removeAt(i);
        }
      }
      while (ids.length >= 5) {
        ids.removeLast();
      }
    }
    ids.insert(0, ticket.id);
    await api.saveUsersLatestsTickets(jsonEncode(ids), context);
  }
}

Future<List<int>> getLatestTickets(BuildContext context) async {
  var respone = await api.getUsersLatestsTickets(context);
  List<int> ids = [];
  if (respone != "" && respone != null) {
    ids = List<int>.from(jsonDecode(respone));
  }
  return ids;
}
