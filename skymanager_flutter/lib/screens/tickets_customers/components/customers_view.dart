import 'dart:async';
import 'package:flutter/material.dart';
import 'package:skymanager/components/drawer.dart';
import 'package:skymanager/models/kunde.dart';
import 'package:skymanager/services/globals.dart' as globals;
import 'package:skymanager/services/api_requests.dart' as api;
import 'package:flutter_slidable/flutter_slidable.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({Key? key}) : super(key: key);

  @override
  CustomersScreenState createState() => CustomersScreenState();
}

class CustomersScreenState extends State<CustomersScreen> {
  Timer? timer;
  var kunden = <Kunde>[];

  final List<Kunde> _searchKunden = <Kunde>[];

  final TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;
  String searchQuery = "Search query";
  bool _showFilter = false;
  int currentFilter = 0;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(minutes: 10), (Timer t) {
      setState(() {});
    });
    // log(_customers.length.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: _isSearching ? _buildSearchField() : const Text('Customers'),
          actions: _buildActions(context),
        ),
        drawer: const SkyManagerDrawer(),
        body: RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: Center(child: _buildCustomerListView()))));
  }

  Future<List<Kunde>?> getKundenForListView() async {
    try {
      if (_isSearching &&
          (_searchKunden.isNotEmpty ||
              _searchQueryController.text.isNotEmpty)) {
        return _searchKunden;
      } else if (currentFilter == 1 && _showFilter) {
        var value = await api.getAllCustomers(context);
        if (value == null) {
          return null;
        }
        Iterable list = value;
        kunden = list.map((model) => Kunde.fromJson(model)).toList();
        return kunden;
      } else if (currentFilter == 2 && _showFilter) {
        var value = await api.getArchivedCustomers(context);
        if (value == null) {
          return null;
        }
        Iterable list = value;
        kunden = list.map((model) => Kunde.fromJson(model)).toList();
        return kunden;
      } else {
        var value = await api.getCustomers(context);
        if (value == null) {
          return null;
        }
        Iterable list = value;
        kunden = list.map((model) => Kunde.fromJson(model)).toList();
        globals.kunden = kunden;
        return kunden;
      }
    } catch (error) {
      return null;
    }
  }

  Widget _buildCustomerListView() {
    var currentUserRole = globals.ownRoleFK;
    return FutureBuilder(
      future: getKundenForListView(),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          List<Kunde> kundeForListView = snapshot.data;
          if (kundeForListView.isEmpty) {
            return const Center(child: Text('No customers found'));
          }
          return ListView.builder(
            itemCount: kundeForListView.length,
            // primary: false,
            itemBuilder: (context, index) {
              return Slidable(
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      currentUserRole == "Admin"
                          ? kundeForListView[index].isActive == 1
                              ? SlidableAction(
                                  backgroundColor: const Color(0xFFFE4A49),
                                  foregroundColor: Colors.white,
                                  icon: Icons.archive,
                                  label: 'Archive',
                                  onPressed: (BuildContext context) {
                                    showArchiveOrRestoreAlert(
                                        context, index, false);
                                  },
                                )
                              : SlidableAction(
                                  backgroundColor: const Color(0xFFFE4A49),
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Restore',
                                  onPressed: (BuildContext context) {
                                    showArchiveOrRestoreAlert(
                                        context, index, true);
                                  },
                                )
                          : Container(),
                    ],
                  ),
                  child: Card(
                    child: ListTile(
                      tileColor: kundeForListView[index].isActive == 1
                          ? null
                          : Colors.red,
                      title: Text(kundeForListView[index].name),
                      subtitle: Text(kundeForListView[index].plz +
                          ' ' +
                          kundeForListView[index].stadt),
                      onTap: () {
                        globals.currentKundeID = kundeForListView[index].id;
                        globals.currentKunde = kundeForListView[index];
                        Navigator.pushNamed(context, '/customers/details')
                            .then((value) => setState(() {}));
                      },
                    ),
                  ));
            },
          );
        } else {
          return const Center(child: Text("No Customers loaded"));
        }
      },
    );
  }

  showArchiveOrRestoreAlert(
      BuildContext context, int index, bool shouldRestore) {
    var thisCustomer = kunden[index];
    if (_isSearching) {
      thisCustomer = _searchKunden[index];
    }
    showDialog(
      context: context,
      builder: (BuildContext buildContext) {
        return AlertDialog(
          title: shouldRestore
              ? Text("Restore: " + thisCustomer.name)
              : Text(thisCustomer.name + " delete?"),
          content: shouldRestore
              ? const Text(
                  "Enables the Customer. All Tickets and Passes would be visible.")
              : const Text(
                  "Archives the Customer. All Tickets and Passes would be invisible. An Administrator can restore the Customer."),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(buildContext).pop();
              },
            ),
            TextButton(
              child:
                  shouldRestore ? const Text("Restore") : const Text("Archive"),
              onPressed: () {
                shouldRestore
                    ? api
                        .reActivateCustomer(thisCustomer.id.toString(), context)
                        .then((value) {
                        setState(() {});
                      })
                    : api
                        .archiveCustomer(thisCustomer.id.toString(), context)
                        .then((value) {
                        setState(() {});
                      });
                Navigator.of(buildContext).pop();
              },
            ),
          ],
        );
      },
    );
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
        Ink(
          decoration: ShapeDecoration(
            color: _showFilter ? Colors.blue : null,
            shape: const CircleBorder(),
          ),
          child: IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _filterBottomSheet,
          ),
        ),
        IconButton(
          //Button to Refresh the Tickets
          icon: const Icon(Icons.refresh),
          onPressed: () {
            setState(() {});
          },
        ),
      ];
    }
  }

  void _startSearch() {
    ModalRoute.of(context)!
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      _searchKunden.clear();
      _isSearching = true;
    });
  }

  void updateSearchQuery(String newQuery) {
    searchQuery = newQuery;
    _searchKunden.clear();
    // ignore: avoid_function_literals_in_foreach_calls
    kunden.forEach((element) {
      if (element.id.toString().contains(searchQuery.toLowerCase()) ||
          element.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          element.plz.toLowerCase().contains(searchQuery.toLowerCase()) ||
          element.stadt.toLowerCase().contains(searchQuery.toLowerCase()) ||
          element.strasse.toLowerCase().contains(searchQuery.toLowerCase()) ||
          element.hausnummer
              .toLowerCase()
              .contains(searchQuery.toLowerCase())) {
        _searchKunden.add(element);
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

  _filterBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.lock_open),
                  title: const Text('Active Customers'),
                  onTap: () => {
                        setState(() {
                          _showFilter = false;
                          currentFilter = 0;
                        }),
                        Navigator.pop(context)
                      }),
              ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('All Customers'),
                  onTap: () => {
                        setState(() {
                          _showFilter = true;
                          currentFilter = 1;
                        }),
                        Navigator.pop(context)
                      }),
              ListTile(
                leading: const Icon(Icons.archive),
                title: const Text('Archived Customers'),
                onTap: () => {
                  setState(() {
                    _showFilter = true;
                    currentFilter = 2;
                  }),
                  Navigator.pop(context)
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
