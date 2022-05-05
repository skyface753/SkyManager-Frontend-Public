// ignore_for_file: avoid_types_as_parameter_names, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:skymanager/models/pass.dart';

import 'package:skymanager/services/api_requests.dart' as api;
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../services/globals.dart' as globals;
import 'package:flutter/services.dart';

class PassesListScreen extends StatefulWidget {
  const PassesListScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PassesListScreenState();
}

class PassesListScreenState extends State<PassesListScreen> {
  var allPasses = <Pass>[];

  final List<Pass> _searchPass = <Pass>[];
  bool _isSearching = false;
  String searchQuery = "Search query";
  final TextEditingController _searchQueryController = TextEditingController();

  getPassesForCustomer() {
    api
        .getCustomerPasses(globals.currentKundeID.toString(), context)
        .then((value) {
      setState(() {
        Iterable list = value;
        allPasses = list.map((model) => Pass.fromJson(model)).toList();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getPassesForCustomer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: _isSearching
              ? _buildSearchField()
              : Text('Passes #' +
                  globals.currentKundeID.toString() +
                  ' - ' +
                  globals.currentKunde.name),
          actions: _buildActions(context),
        ),
        body: RefreshIndicator(
            onRefresh: () async {
              getPassesForCustomer();
            },
            child: Center(
                child: _searchPass.isNotEmpty ||
                        _searchQueryController.text.isNotEmpty
                    ? buildPassesListView(_searchPass)
                    : buildPassesListView(allPasses))));
  }

  Widget buildPassesListView(List<Pass> passesforListView) {
    return ListView.builder(
        itemCount: passesforListView.length,
        itemBuilder: (context, index) {
          return Slidable(
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  // A SlidableAction can have an icon and/or a label.
                  SlidableAction(
                    // onPressed: (print("HI")),
                    backgroundColor: const Color(0xFFFE4A49),
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                    onPressed: (BuildContext context) {
                      showDeleteAlert(context, passesforListView[index]);
                    },
                  ),
                ],
              ),
              child: Card(
                  child: InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(
                            text: passesforListView[index].passwort));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(children: <Widget>[
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                passesforListView[index].titel,
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                passesforListView[index].benutzername,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          )),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                passesforListView[index].passwort,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          )),
                          Expanded(
                              child: IconButton(
                            icon: const Icon(Icons.content_copy),
                            onPressed: () {
                              // print("Hallo");
                              _displayCopyOptions(
                                  context, passesforListView[index]);
                            },
                          )),
                          Expanded(
                            child: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _displayChangePassDialog(
                                    context, passesforListView[index]);
                              },
                            ),
                          )
                        ]),
                      ))));
        });
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: "Search Data...",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white30),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  List<Widget> _buildActions(BuildContext scaffoldContext) {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchQueryController.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            _clearSearchQuery();
          },
        ),
      ];
    } else {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _startSearch,
        ),
        IconButton(
          //Button to Refresh the Tickets
          icon: const Icon(Icons.refresh),
          onPressed: () {
            getPassesForCustomer();
          },
        ),
      ];
    }
  }

  _displayChangePassDialog(BuildContext context, Pass currentPass) async {
    TextEditingController _changeTitleController = TextEditingController(),
        _changeUsernameController = TextEditingController(),
        _changePasswordController = TextEditingController();

    _changeTitleController.text = currentPass.titel;
    _changeUsernameController.text = currentPass.benutzername;
    _changePasswordController.text = currentPass.passwort;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text("Change Password"),
              content:
                  Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                TextField(
                  controller: _changeTitleController,
                  decoration: const InputDecoration(
                    labelText: "Title",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.white30),
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                ),
                TextField(
                  controller: _changeUsernameController,
                  decoration: const InputDecoration(
                    labelText: "Username",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.white30),
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                ),
                TextField(
                  controller: _changePasswordController,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.white30),
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                ),
              ]),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                TextButton(
                  child: const Text("Submit"),
                  onPressed: () {
                    // kundenPassID, Titel, Benutzername, Passwort
                    api
                        .updatePass(
                            currentPass.id.toString(),
                            _changeTitleController.text,
                            _changeUsernameController.text,
                            _changePasswordController.text,
                            context)
                        .then((value) => Navigator.pop(context));
                  },
                ),
                TextButton(
                  child: const Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  _displayCopyOptions(BuildContext context, Pass currentPass) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Column(
            children: [
              Expanded(
                child: SimpleDialog(
                  title: const Text('Copy'),
                  children: [
                    SimpleDialogOption(
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: currentPass.titel));
                        },
                        child: Text('Title: ' + currentPass.titel)),
                    SimpleDialogOption(
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: currentPass.benutzername));
                        },
                        child: Text('Username: ' + currentPass.benutzername)),
                    SimpleDialogOption(
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: currentPass.passwort));
                        },
                        child: Text('Password: ' + currentPass.passwort)),
                  ],
                  elevation: 10,
                  //backgroundColor: Colors.green,
                ),
              )
            ],
          );
        });
  }

  showDeleteAlert(BuildContext context, Pass currentPass) {
    showDialog(
      context: context,
      builder: (BuildContext buildContext) {
        return AlertDialog(
          title: Text(currentPass.titel + " delete?"),
          content: const Text("This action is irreversible. Delete Password?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Delete"),
              onPressed: () {
                api
                    .deleteCustomerPass(currentPass.id.toString(), context)
                    .then((value) {
                  getPassesForCustomer();
                  Navigator.of(buildContext).pop();
                });
              },
            ),
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                //Put your code here which you want to execute on No button click.
                Navigator.of(buildContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _startSearch() {
    ModalRoute.of(context)!
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      _searchPass.clear();
      _isSearching = true;
    });
  }

  void updateSearchQuery(String newQuery) {
    searchQuery = newQuery;
    _searchPass.clear();
    // ignore: avoid_function_literals_in_foreach_calls
    allPasses.forEach((element) {
      if (element.id.toString().contains(searchQuery.toLowerCase()) ||
          element.benutzername
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          element.passwort.toLowerCase().contains(searchQuery.toLowerCase()) ||
          element.titel.toLowerCase().contains(searchQuery.toLowerCase())) {
        _searchPass.add(element);
      }
    });
    setState(() {});
  }

  void _stopSearching() {
    _clearSearchQuery();

    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery("");
    });
  }
}
