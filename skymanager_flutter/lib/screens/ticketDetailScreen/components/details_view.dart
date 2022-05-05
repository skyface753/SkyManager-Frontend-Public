// ignore_for_file: non_constant_identifier_names

import 'package:skymanager/models/currticket.dart';

import 'package:skymanager/services/api_requests.dart' as api;
import 'package:flutter/material.dart';
import 'package:skymanager/services/load_models.dart';
import '../../../services/globals.dart' as globals; // global variables
import 'package:skymanager/models/kunde.dart';
import 'package:skymanager/models/user.dart';
import 'package:skymanager/models/zustand.dart';
import 'package:dropdown_search/dropdown_search.dart';

class DetailsView extends StatefulWidget {
  final bool isNewTicket;
  const DetailsView({Key? key, required this.isNewTicket}) : super(key: key);

  @override
  _DetailsViewState createState() => _DetailsViewState();
}

class _DetailsViewState extends State<DetailsView> {
  bool isNewTicket = false;
  bool _allLoaded = false;
  var currTicketList = <CurrTicket>[];

  final TextEditingController _titelController = TextEditingController(),
      _beschreibungController = TextEditingController(),
      _kundennameController = TextEditingController(),
      _zustaendigController = TextEditingController(),
      _zustandController = TextEditingController(),
      _kunden_FKController = TextEditingController(),
      _user_FKController = TextEditingController(),
      _zustand_FKController = TextEditingController();

  var kunden = <Kunde>[];
  var zustaende = <Zustand>[];
  var zustaendige = <User>[];

  late Kunde? selectedKunde;
  late User? selectedUser;
  late Zustand? selectedZustand;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
        child: Center(
            child: Column(
          children: <Widget>[
            TextField(
              controller: _titelController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            TextField(
              controller: _beschreibungController,
              maxLines: 6,
              minLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
            ),
            const SizedBox(height: 10),
            _allLoaded == false
                ? const Center(child: CircularProgressIndicator())
                : DropdownSearch<Kunde>(
                    mode: Mode.MENU,
                    isFilteredOnline: true,
                    showSelectedItems: true,
                    compareFn: (i, s) => i?.isEqual(s!) ?? false,
                    dropdownSearchDecoration: const InputDecoration(
                      labelText: "Customer",
                      contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                      border: OutlineInputBorder(),
                    ),
                    onFind: (String? filter) => getKunde(filter),
                    onChanged: (data) {
                      setState(() {
                        _kunden_FKController.text = data!.id.toString();
                      });
                    },
                    selectedItem: isNewTicket ? null : selectedKunde,
                    showSearchBox: true,
                  ),
            const SizedBox(height: 10),
            _allLoaded == false
                ? const Center(child: CircularProgressIndicator())
                : DropdownSearch<User>(
                    mode: Mode.MENU,
                    isFilteredOnline: true,
                    showSelectedItems: true,
                    compareFn: (i, s) => i?.isEqual(s!) ?? false,
                    dropdownSearchDecoration: const InputDecoration(
                      labelText: "User",
                      contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                      border: OutlineInputBorder(),
                    ),
                    onFind: (String? filter) => getUser(filter),
                    onChanged: (data) {
                      setState(() {
                        _user_FKController.text = data!.name;
                      });
                    },
                    selectedItem: isNewTicket ? null : selectedUser,
                    showSearchBox: true,
                  ),
            const SizedBox(height: 10),
            _allLoaded == false
                ? const Center(child: CircularProgressIndicator())
                : DropdownSearch<Zustand>(
                    mode: Mode.MENU,
                    isFilteredOnline: true,
                    showSelectedItems: true,
                    compareFn: (i, s) => i?.isEqual(s!) ?? false,
                    dropdownSearchDecoration: const InputDecoration(
                      labelText: "Status",
                      contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                      border: OutlineInputBorder(),
                    ),
                    onFind: (String? filter) => getZustand(),
                    onChanged: (data) {
                      setState(() {
                        _zustand_FKController.text = data!.id.toString();
                      });
                    },
                    selectedItem: isNewTicket ? null : selectedZustand,
                  ),
            const SizedBox(height: 10),
            ElevatedButton(
                child: const Text('Save'),
                onPressed: () {
                  if (_allLoaded &&
                      _titelController.text.isNotEmpty &&
                      _beschreibungController.text.isNotEmpty &&
                      _kunden_FKController.text.isNotEmpty &&
                      _user_FKController.text.isNotEmpty &&
                      _zustand_FKController.text.isNotEmpty) {
                    if (isNewTicket) {
                      api
                          .createTicket(
                              _titelController.text,
                              _beschreibungController.text,
                              _kunden_FKController.text,
                              _user_FKController.text,
                              _zustand_FKController.text,
                              context)
                          .then((value) {
                        const snackBar = SnackBar(
                            content: Text('Ticket created'),
                            duration: Duration(milliseconds: 300));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        FocusScope.of(context).unfocus();
                        Navigator.pop(context);
                      });
                    } else {
                      api
                          .updateTicket(
                              globals.currentTicketID.toString(),
                              _titelController.text,
                              _beschreibungController.text,
                              _kunden_FKController.text,
                              _user_FKController.text,
                              _zustand_FKController.text,
                              context)
                          .then((value) {
                        const snackBar = SnackBar(content: Text('Saved'));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      });
                    }
                  } else {
                    const snackBar =
                        SnackBar(content: Text('Please fill out all fields'));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                }),
            const SizedBox(height: 20),
            isNewTicket
                ? Container()
                : ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                          context,
                          "/tasks/create?ticketID=" +
                              globals.currentTicketID.toString());
                    },
                    child: const Text("Create Task from this Ticket"))
          ],
        )));
  }

  Future<List<Kunde>> getKunde(String? filter) async {
    if (filter == null) {
      return kunden;
    }
    var searchedKunden = <Kunde>[];
    for (var kunde in kunden) {
      if (kunde.name.toLowerCase().contains(filter.toLowerCase()) ||
          kunde.id.toString().contains(filter) ||
          kunde.stadt.contains(filter)) {
        searchedKunden.add(kunde);
      }
    }
    return searchedKunden;
  }

  Future<List<User>> getUser(String? filter) async {
    if (filter == null) {
      return zustaendige;
    }
    var searchedUser = <User>[];
    for (var user in zustaendige) {
      if (user.name.toLowerCase().contains(filter.toLowerCase()) ||
          user.email.contains(filter)) {
        searchedUser.add(user);
      }
    }
    return searchedUser;
  }

  Future<List<Zustand>> getZustand() async {
    return zustaende;
  }

  @override
  void initState() {
    isNewTicket = widget.isNewTicket;
    if (!isNewTicket) {
      loadCurrentTicketList(context).then((value) {
        setState(() {
          currTicketList = value;
          _allLoaded = true;
          _titelController.text = currTicketList[0].titel;
          _beschreibungController.text = currTicketList[0].beschreibung;
          _kundennameController.text = currTicketList[0].kundenname;
          _zustaendigController.text = currTicketList[0].zustaendig;
          _zustandController.text = currTicketList[0].zustand;
          _kunden_FKController.text = currTicketList[0].kunden_FK.toString();
          _user_FKController.text = currTicketList[0].user_FK;
          _zustand_FKController.text = currTicketList[0].zustand_FK.toString();
          kunden = globals.kunden;
          zustaende = globals.zustaende;
          zustaendige = globals.zustaendige;
          selectedKunde = globals.kunden.firstWhere(
              (Kunde value) => value.id == currTicketList[0].kunden_FK);
          selectedUser = globals.zustaendige.firstWhere(
              (User value) => value.name == currTicketList[0].user_FK);
          selectedZustand = globals.zustaende.firstWhere(
              (Zustand value) => value.id == currTicketList[0].zustand_FK);
          _allLoaded = true;
        });
      });
    } else {
      setState(() {
        kunden = globals.kunden;
        zustaende = globals.zustaende;
        zustaendige = globals.zustaendige;
        _allLoaded = true;
      });
    }
    super.initState();
  }
}
