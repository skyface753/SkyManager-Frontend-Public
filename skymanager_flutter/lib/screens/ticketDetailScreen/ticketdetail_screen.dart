import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:skymanager/screens/ticketDetailScreen/components/details_view.dart';
import 'package:skymanager/screens/ticketDetailScreen/components/eintraege_view.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/globals.dart' as globals; // global variables
import 'package:share/share.dart';
import 'package:mailto/mailto.dart';
import 'package:flutter/foundation.dart';

class TicketDetailScreen extends StatefulWidget {
  const TicketDetailScreen({Key? key}) : super(key: key);

  @override
  _TicketDetailScreenState createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  GlobalKey<EintraegeViewState> entryViewStateKey =
      GlobalKey<EintraegeViewState>();

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    var brightness = SchedulerBinding.instance!.window.platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return Scaffold(
        appBar: AppBar(
          title: Text('Ticket #' + globals.currentTicketID.toString()),
          leading: const BackButton(),
          actions: [
            globals.sendMailEnabled
                ? IconButton(
                    icon: const Icon(Icons.mail),
                    tooltip: 'SendMail',
                    onPressed: () {
                      Navigator.pushNamed(
                              context,
                              '/entries/createMail?ticketID=' +
                                  globals.currentTicketID.toString())
                          .then((value) => entryViewStateKey.currentState
                              ?.reloadEintraege());
                    },
                  )
                : Container(),
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Share',
              onPressed: () {
                if ((defaultTargetPlatform == TargetPlatform.iOS) ||
                    (defaultTargetPlatform == TargetPlatform.android)) {
                  Share.share(globals.frontendUrl == ""
                      ? "View in App: https://open.skymanager.net?ticketID=" +
                          globals.currentTicketID.toString()
                      : "View in App: https://open.skymanager.net?ticketID=" +
                          globals.currentTicketID.toString() +
                          "\nOpen in Web: " +
                          globals.frontendUrl);
                  // Share.share('Open on IOS: sky://manager?ticketID=' +
                  //     globals.currentTicketID.toString() +
                  //     " \n Open on Android: https://skymanager.page.link?ticketID=" +
                  //     globals.currentTicketID.toString());
                } else {
                  launchShareUrl();
                }
              },
            ),
          ],
        ),
        floatingActionButton: _selectedIndex == 1
            ? FloatingActionButton(
                heroTag: "detailsBtn",
                onPressed: () {
                  Navigator.pushNamed(context, '/entries/create').then(
                      (value) =>
                          entryViewStateKey.currentState?.reloadEintraege());
                },
                child: const Icon(Icons.add),
              )
            : null,
        body: IndexedStack(index: _selectedIndex, children: <Widget>[
          const DetailsView(
            isNewTicket: false,
          ),
          EintraegeView(
            key: entryViewStateKey,
          ),
        ]),
        bottomNavigationBar: ConvexAppBar(
          backgroundColor: Colors.transparent,
          color: isDarkMode ? Colors.white : Colors.black,
          activeColor: isDarkMode ? Colors.white : Colors.black,
          top: -25,
          style: TabStyle.react,
          items: const [
            TabItem(
              icon: Icon(Icons.info),
              title: 'Details',
            ),
            TabItem(
              icon: Icon(Icons.list),
              title: 'Entries',
            ),
          ],
          initialActiveIndex: _selectedIndex,
          onTap: _onItemTapped,
        ));
  }

  launchShareUrl() async {
    final mailtoLink = Mailto(
      // to: [''],
      // cc: [''],
      subject: 'Mail to #' + globals.currentTicketID.toString(),
      body: globals.frontendUrl == ""
          ? '\n\n\n\nOpen in App: https://open.skymanager.net?ticketID=' +
              globals.currentTicketID.toString()
          : '\n\n\n\nOpen in App: https://open.skymanager.net?ticketID=' +
              globals.currentTicketID.toString() +
              "\nOpen in Web: " +
              globals.frontendUrl,

      // '\n\n\n\nOpen on IOS: sky://manager?ticketID=' +
      //     globals.currentTicketID.toString() +
      //     " \nOpen on Android: https://skymanager.page.link?ticketID=" +
      //     globals.currentTicketID.toString(),
    );
    // Convert the Mailto instance into a string.
    // Use either Dart's string interpolation
    // or the toString() method.
    await launch('$mailtoLink');
  }
}
