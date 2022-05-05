import 'package:flutter/material.dart';
import 'package:flutter_gravatar/flutter_gravatar.dart';
import 'package:skymanager/helpers/read_write_datas.dart';
import 'package:skymanager/services/notification_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/globals.dart' as globals; // global variables
import 'package:skymanager/services/api_requests.dart' as api;
import 'package:feedback_sentry/feedback_sentry.dart';
// Import foundation
import 'package:flutter/foundation.dart';

class SkyManagerDrawer extends StatefulWidget {
  const SkyManagerDrawer({Key? key}) : super(key: key);

  @override
  _SkyManagerDrawerState createState() => _SkyManagerDrawerState();
}

class _SkyManagerDrawerState extends State<SkyManagerDrawer> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    _notificationService.init();
  }

  @override
  Widget build(BuildContext context) {
    var currentUserRole = globals.ownRoleFK;

    var gravatar = Gravatar(globals.ownEMail);
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: [
        SafeArea(
          child: ListTile(
              leading: const Icon(Icons.cloud),
              title: const Text('SkyManager'),
              subtitle: Text(api.serverUrl),
              trailing: globals.frontendUrl != ""
                  ? IconButton(
                      icon: const Icon(Icons.open_in_browser),
                      onPressed: () async {
                        var url = globals.frontendUrl;
                        if (!url.startsWith("http")) {
                          url = "https://" + url;
                        }
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                    )
                  : null),
        ),
        const Divider(),
        ListTile(
          leading: globals.ownEMail == ""
              ? null
              : CircleAvatar(
                  backgroundImage: NetworkImage(gravatar.imageUrl()),
                ),
          title: Text(globals.ownUsername),
          subtitle: Text(globals.ownRoleFK),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/users/profile');
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('Home'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, '/Home');
          },
        ),
        // ListTile(
        //   leading: const Icon(Icons.home),
        //   title: const Text('Notify'),
        //   onTap: () async {
        //     await _notificationService.showNotifications();
        //   },
        // ),
        currentUserRole == "Admin"
            ? ListTile(
                leading: const Icon(Icons.portrait),
                title: const Text("Users"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/users');
                },
              )
            : Container(),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/Settings');
          },
        ),
        ListTile(
          leading: const Icon(Icons.help),
          title: const Text('Feedback'),
          onTap: () {
            Navigator.pop(context);
            BetterFeedback.of(context).showAndUploadToSentry(
              name: kIsWeb ? "Web" : "Mobile",
            );
          },
        ),
        ListTile(
          title: const Text("Contact"),
          onTap: () async {
            if (await canLaunch("mailto:kontakt@skymanager.net")) {
              await launch("mailto:kontakt@skymanager.net");
            }
          },
          leading: const Icon(Icons.email),
        ),

        const Divider(),
        ListTile(
          leading: const Icon(Icons.exit_to_app),
          title: const Text('Logout'),
          onTap: () {
            _logoutUser(context);
          },
        ),
      ],
    ));
  }

  void _logoutUser(BuildContext context) async {
    ReadWriteDatas().clearDatas();
    globals.isLoggedIn = false;
    Navigator.pushReplacementNamed(context, '/Login');
  }
}
