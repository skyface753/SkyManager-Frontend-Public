// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:skymanager/screens/ticketDetailScreen/components/details_view.dart';

class NewTicketScreen extends StatefulWidget {
  const NewTicketScreen({Key? key}) : super(key: key);

  @override
  _NewTicketScreenState createState() => _NewTicketScreenState();
}

class _NewTicketScreenState extends State<NewTicketScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('New Ticket'),
        ),
        body: const DetailsView(isNewTicket: true));
  }
}
