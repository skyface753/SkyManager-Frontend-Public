import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:skymanager/screens/customer_passes/components/customer_info_view.dart';
import 'package:skymanager/screens/customer_passes/components/passeslist_view.dart';
import 'package:skymanager/screens/customer_file/customer_file_view.dart';
import 'package:skymanager/screens/customer_passes/components/totp_view.dart';
import '../../../services/globals.dart' as globals; // global variables

class CustomerPassesScreen extends StatefulWidget {
  const CustomerPassesScreen({Key? key}) : super(key: key);

  @override
  _CustomerPassesScreenState createState() => _CustomerPassesScreenState();
}

class _CustomerPassesScreenState extends State<CustomerPassesScreen> {
  GlobalKey<PassesListScreenState> passeslistKey =
      GlobalKey<PassesListScreenState>();
  GlobalKey<TotpViewState> tasksListKey = GlobalKey<TotpViewState>();
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = SchedulerBinding.instance!.window.platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              heroTag: "passesBtn",
              onPressed: () {
                Navigator.pushNamed(context, '/customers/passes/create').then(
                    (value) =>
                        passeslistKey.currentState?.getPassesForCustomer());
              },
              tooltip: 'Add Pass',
              child: const Icon(Icons.add),
            )
          : _selectedIndex == 3
              ? FloatingActionButton(
                  onPressed: () {
                    _showModalActionSheet();
                  },
                  heroTag: "totpCreateBtn",
                  tooltip: "Add Totp",
                  child: const Icon(Icons.add))
              : null,
      body: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[
          PassesListScreen(
            key: passeslistKey,
          ),
          const CustomerInfoScreen(),
          CustomerFileView(
            customerID: globals.currentKundeID,
          ),
          TotpView(
            key: tasksListKey,
          ),
        ],
      ),
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Colors.transparent,
        color: isDarkMode ? Colors.white : Colors.black,
        activeColor: isDarkMode ? Colors.white : Colors.black,
        top: -25,
        style: TabStyle.react,
        items: const [
          TabItem(icon: Icons.list, title: 'Passes'),
          TabItem(icon: Icons.info, title: 'Info'),
          TabItem(icon: Icons.cloud_upload, title: 'Upload'),
          TabItem(icon: Icons.vpn_key, title: 'TOTP'),
        ],
        onTap: _onItemTapped,
        initialActiveIndex: _selectedIndex,
      ),
    );
  }

  //Alert Dialog choosing import or Add
  // _showTotpAddAlert() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text("Add TOTP"),
  //         content: const Text(
  //             "Do you want to add an single TOTP or import a bunch from Google-Authenticator-Export?"),
  //         actions: <Widget>[
  //           ElevatedButton(
  //             child: const Text("Import from Google-Authenticator"),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               Navigator.pushNamed(context, '/customers/totp/import').then(
  //                   (value) =>
  //                       tasksListKey.currentState?.getTotpsForCustomer());
  //             },
  //           ),
  //           ElevatedButton(
  //             child: const Text("Add Single"),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               Navigator.pushNamed(context, '/customers/totp/create').then(
  //                   (value) =>
  //                       tasksListKey.currentState?.getTotpsForCustomer());
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  //Show ModalActionSheet
  _showModalActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text("Add from QR-Code or Manual"),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/customers/totp/create').then(
                    (value) =>
                        tasksListKey.currentState?.getTotpsForCustomer());
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud_upload),
              title: const Text("Import from Google Authenticator"),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/customers/totp/import').then(
                    (value) =>
                        tasksListKey.currentState?.getTotpsForCustomer());
              },
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}
