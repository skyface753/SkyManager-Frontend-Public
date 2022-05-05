// ignore_for_file: empty_catches, duplicate_ignore

import 'dart:async';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:skymanager/screens/tickets_customers/components/tasks/tasks_view.dart';
import 'package:skymanager/screens/tickets_customers/components/tickets_view.dart';

import 'package:skymanager/screens/tickets_customers/components/customers_view.dart';

import 'package:skymanager/models/user.dart';
import 'package:skymanager/models/zustand.dart';
import 'package:skymanager/screens/tickets_customers/components/wiki/wiki_view.dart';
import 'package:skymanager/services/check_biometrics.dart';
import 'package:skymanager/services/load_models.dart';
import 'package:uni_links/uni_links.dart';
import '../../../services/globals.dart' as globals; // global variables
import 'package:skymanager/services/api_requests.dart' as api;

// import 'package:skymanager/services/notification_service.dart';

//Entrypoint for TicketScreen
class TicketCustomersScreen extends StatefulWidget {
  const TicketCustomersScreen({Key? key}) : super(key: key);

  @override
  _TicketCustomersScreenState createState() => _TicketCustomersScreenState();
}

class _TicketCustomersScreenState extends State<TicketCustomersScreen>
    with WidgetsBindingObserver {
  // NotificationService _notificationService = NotificationService();
  GlobalKey<TasksViewState> tasksViewKey = GlobalKey<TasksViewState>();
  GlobalKey<TicketsScreenState> ticketsViewKey =
      GlobalKey<TicketsScreenState>();
  GlobalKey<CustomersScreenState> customersViewKey =
      GlobalKey<CustomersScreenState>();
  GlobalKey<WikiViewState> wikiViewKey = GlobalKey<WikiViewState>();

  String fromURL = "";
  bool wasPaused = false;
  var zustaende = <Zustand>[];
  var zustaendige = <User>[];
  Timer? timer;
  int _selectedIndex = 0;

  // List<Widget> _widgetOptions = ;

  late StreamSubscription<Uri?> sub;

  @override
  void initState() {
    _getZustaende();
    loadUserList(context).then((value) => zustaendige = value);
    // _checkLogin();
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    initUniLinks(); // for handling deep links and web links

    timer = Timer.periodic(const Duration(minutes: 5), (Timer t) {
      // _getZustaende();
      loadUserList(context).then((value) => zustaendige = value);
      api.refreshToken(context);
    });
    checkBiometrics(context);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (wasPaused) {
          checkBiometrics(context);
          wasPaused = false;
        }
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        wasPaused = true;
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    // timer?.cancel();
    super.dispose();
    WidgetsBinding.instance?.removeObserver(this);

    sub.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = SchedulerBinding.instance!.window.platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[
          TicketsScreen(
            key: ticketsViewKey,
          ),
          CustomersScreen(
            key: customersViewKey,
          ),
          TasksView(
            key: tasksViewKey,
          ),
          WikiView(
            key: wikiViewKey,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "homeFab",
        onPressed: () {
          if (_selectedIndex == 0) {
            Navigator.pushNamed(context, '/tickets/create')
                .then((value) => ticketsViewKey.currentState?.setState(() {}));
          } else if (_selectedIndex == 1) {
            Navigator.pushNamed(context, '/customers/create').then(
                (value) => customersViewKey.currentState?.setState(() {}));
          } else if (_selectedIndex == 2) {
            Navigator.pushNamed(context, '/tasks/create')
                .then((value) => tasksViewKey.currentState?.reloadTasks());
          } else if (_selectedIndex == 3) {
            globals.currentWiki = null;
            Navigator.pushNamed(context, '/wikis')
                .then((value) => wikiViewKey.currentState?.setState(() {}));
          }
        },
        tooltip: _selectedIndex == 0
            ? "Create Ticket"
            : _selectedIndex == 1
                ? "Create Customer"
                : _selectedIndex == 2
                    ? "Create Task"
                    : _selectedIndex == 3
                        ? "Create Wiki"
                        : "",
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Colors.transparent,
        color: isDarkMode ? Colors.white : Colors.black,
        activeColor: isDarkMode ? Colors.white : Colors.black,
        top: -25,
        style: TabStyle.react,
        items: const [
          TabItem(
            icon: Icons.list,
            title: "Tickets",
          ),
          TabItem(
            icon: Icons.people,
            title: "Customers",
          ),
          TabItem(
            icon: Icons.assignment,
            title: "Tasks",
          ),
          TabItem(
            icon: Icons.book,
            title: "Wikis",
          ),
        ],
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  _getZustaende() {
    api.getZustaende(context).then((value) {
      setState(() {
        Iterable list = value;
        zustaende = list.map((model) => Zustand.fromJson(model)).toList();
        globals.zustaende = zustaende;
      });
    });
  }

  Future<void> initUniLinks() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      final initialLink = await getInitialUri();
      if (initialLink != null) {
        parseLink(initialLink);
      }
      sub = uriLinkStream.listen((Uri? link) {
        if (link != null) {
          parseLink(link);
        }
      }, onError: (err) {});
      // ignore: empty_catches
    } catch (e) {}
  }

  parseLink(Uri uri) async {
    var linkTicketID = "";
    var linkTaskID = "";
    uri.queryParameters.forEach((key, value) {
      if (key == "ticketID") {
        linkTicketID = value;
      }
      if (key == "taskID") {
        linkTaskID = value;
      }
    });
    if (linkTicketID != "") {
      try {
        globals.currentTicketID = int.parse(linkTicketID);
        Navigator.pushNamed(context, '/tickets/details').then((value) {
          FocusScope.of(context).unfocus();
        });
      } catch (e) {}
    } else {
      if (linkTaskID != "") {
        try {
          await loadTicketList(context);
          while (globals.currentTasks.isEmpty) {
            await Future.delayed(const Duration(milliseconds: 100));
          }
          globals.currentTaskID = int.parse(linkTaskID);
          if (kDebugMode) {
            print("Open Task in Home like Deeplink");
          }
          Navigator.pushNamed(context, '/tasks/edit?taskID=' + linkTaskID)
              .then((value) {
            globals.currentTaskID = 0;
            FocusScope.of(context).unfocus();
          });
        } catch (e) {}
      }
    }
  }
}
