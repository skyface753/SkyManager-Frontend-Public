import 'package:flutter/material.dart';
import 'package:skymanager/components/drawer.dart';
import 'package:skymanager/components/tickets_view.dart';
import 'package:skymanager/models/ticket.dart';
import 'package:skymanager/services/api_requests.dart' as api;
import 'package:skymanager/services/load_models.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({Key? key}) : super(key: key);

  @override
  TicketsScreenState createState() => TicketsScreenState();
}

class TicketsScreenState extends State<TicketsScreen> {
  var tickets = <Ticket>[];

  final List<Ticket> _searchTickets = <Ticket>[];

  final TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;
  bool _showFilter = false;
  String searchQuery = "Search query";
  int currentFilter = 0;

  Future<List<Ticket>?> getTicketsForFutureBuilder() async {
    try {
      if (_isSearching &&
          (_searchTickets.isNotEmpty ||
              _searchQueryController.text.isNotEmpty)) {
        return _searchTickets;
      } else {
        if (currentFilter == 0) {
          tickets = await loadTicketList(context);
          return tickets;
        } else if (currentFilter == 1) {
          _showFilter = true;
          Iterable list = await api.getAllTickets(context);

          tickets = list.map((model) => Ticket.fromJson(model)).toList();
          return tickets;
        } else if (currentFilter == 2) {
          _showFilter = true;
          Iterable list = await api.getMyTickets(context);
          tickets = list.map((model) => Ticket.fromJson(model)).toList();
          return tickets;
        }
      }
      return tickets;
    } catch (error) {
      return null;
    }
  }

  @override
  void initState() {
    //First call of Ticketview
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: _isSearching ? _buildSearchField() : const Text('Tickets'),
          actions: _buildActions(),
        ),
        drawer: const SkyManagerDrawer(),
        body: RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: Center(child: _buildTicketListView()))));
  }

  Widget _buildTicketListView() {
    return FutureBuilder(
        future: getTicketsForFutureBuilder(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
                child: Text(
                    'An error occurred while loading the tickets. Please try again later.'));
          } else if (snapshot.data == null) {
            return const Center(
                child: Text(
                    'No tickets found. Create a ticket or change the filters at the top right.'));
          } else {
            List<Ticket> ticketsForListView = snapshot.data;
            if (ticketsForListView.isEmpty) {
              return const Center(
                  child: Text(
                      'No tickets found. Create a ticket or change the filters at the top right.'));
            }
            return ListView.builder(
              itemCount: ticketsForListView.length,
              itemBuilder: (context, index) {
                return TicketView(tickets: ticketsForListView, index: index);
              },
            );
          }
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

  List<Widget> _buildActions() {
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
      _searchTickets.clear();
      _isSearching = true;
    });
  }

  void updateSearchQuery(String newQuery) {
    searchQuery = newQuery;
    _searchTickets.clear();
    // Start time in ms
    int startTime = DateTime.now().millisecondsSinceEpoch;
    for (Ticket element in tickets) {
      if (element.id
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          element.titel.toLowerCase().contains(searchQuery.toLowerCase()) ||
          element.kundenname
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          element.zustaendig
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          element.zustand.toLowerCase().contains(searchQuery.toLowerCase()) ||
          element.beschreibung
              .toLowerCase()
              .contains(searchQuery.toLowerCase())) {
        _searchTickets.add(element);
      }
    }
    // End time in ms
    int endTime = DateTime.now().millisecondsSinceEpoch;
    // Show the time it took to search in SnackBar
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Searching took ${endTime - startTime} milliseconds"),
    ));
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
                  title: const Text('Opened Tickets'),
                  onTap: () => {
                        setState(() {
                          _showFilter = false;
                          currentFilter = 0;
                        }),
                        setState(() {}),
                        Navigator.pop(context)
                      }),
              ListTile(
                  leading: const Icon(Icons.airplane_ticket),
                  title: const Text('All Tickets'),
                  onTap: () => {
                        setState(() {
                          _showFilter = true;
                          currentFilter = 1;
                        }),
                        Navigator.pop(context)
                      }),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('My Tickets'),
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
