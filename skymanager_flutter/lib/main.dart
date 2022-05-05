// ignore_for_file: deprecated_member_use, prefer_const_constructors, unnecessary_new

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:skymanager/custom_feedback.dart';
import 'package:skymanager/helpers/read_write_datas.dart';
import 'package:skymanager/screens/loginScreen/login_screen.dart';
import 'package:skymanager/screens/tasks/create_edit_task.dart';
import 'package:skymanager/screens/ticketDetailScreen/send_mail_screen.dart';
import 'package:skymanager/screens/tickets_customers/tickets_customers_screen.dart';
import 'package:skymanager/theme/style.dart';
import 'package:skymanager/routes.dart';
import 'package:feedback/feedback.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:url_strategy/url_strategy.dart';

import 'package:skymanager/services/api_requests.dart' as api;
import 'package:skymanager/services/globals.dart'
    as globals; // global variables

Future<void> main() async {
  try {
    SecurityContext.defaultContext
        .setTrustedCertificatesBytes(ascii.encode(isrgx1));
  } catch (e) {
    // ignore errors here, maybe it's already trusted
  }
  setPathUrlStrategy();

  WidgetsFlutterBinding.ensureInitialized();
  await ReadWriteDatas().readDatas();
  bool checkLoginToken = false;

  if (api.serverUrl != "") {
    checkLoginToken = await api
        .checkLoginToken()
        .timeout(const Duration(seconds: 3), onTimeout: () {
      return false;
    });
  }

  if (checkLoginToken) {
    globals.isLoggedIn = true;
  } else {
    await ReadWriteDatas().clearDatas();
  }

  // Entry point for the application.
  if (kDebugMode) {
    runApp(SkyManager(
      isLoggedIn: checkLoginToken,
    ));
  } else {
    runApp(BetterFeedback(
      feedbackBuilder: (context, onSubmit, scrollController) =>
          CustomFeedbackForm(
        onSubmit: onSubmit,
        scrollController: scrollController,
      ),
      child: SkyManager(
        isLoggedIn: checkLoginToken,
      ),
      localeOverride: const Locale('en'),
    ));
  }
}

const String isrgx1 = """-----BEGIN CERTIFICATE-----
MIIFazCCA1OgAwIBAgIRAIIQz7DSQONZRGPgu2OCiwAwDQYJKoZIhvcNAQELBQAw
TzELMAkGA1UEBhMCVVMxKTAnBgNVBAoTIEludGVybmV0IFNlY3VyaXR5IFJlc2Vh
cmNoIEdyb3VwMRUwEwYDVQQDEwxJU1JHIFJvb3QgWDEwHhcNMTUwNjA0MTEwNDM4
WhcNMzUwNjA0MTEwNDM4WjBPMQswCQYDVQQGEwJVUzEpMCcGA1UEChMgSW50ZXJu
ZXQgU2VjdXJpdHkgUmVzZWFyY2ggR3JvdXAxFTATBgNVBAMTDElTUkcgUm9vdCBY
MTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAK3oJHP0FDfzm54rVygc
h77ct984kIxuPOZXoHj3dcKi/vVqbvYATyjb3miGbESTtrFj/RQSa78f0uoxmyF+
0TM8ukj13Xnfs7j/EvEhmkvBioZxaUpmZmyPfjxwv60pIgbz5MDmgK7iS4+3mX6U
A5/TR5d8mUgjU+g4rk8Kb4Mu0UlXjIB0ttov0DiNewNwIRt18jA8+o+u3dpjq+sW
T8KOEUt+zwvo/7V3LvSye0rgTBIlDHCNAymg4VMk7BPZ7hm/ELNKjD+Jo2FR3qyH
B5T0Y3HsLuJvW5iB4YlcNHlsdu87kGJ55tukmi8mxdAQ4Q7e2RCOFvu396j3x+UC
B5iPNgiV5+I3lg02dZ77DnKxHZu8A/lJBdiB3QW0KtZB6awBdpUKD9jf1b0SHzUv
KBds0pjBqAlkd25HN7rOrFleaJ1/ctaJxQZBKT5ZPt0m9STJEadao0xAH0ahmbWn
OlFuhjuefXKnEgV4We0+UXgVCwOPjdAvBbI+e0ocS3MFEvzG6uBQE3xDk3SzynTn
jh8BCNAw1FtxNrQHusEwMFxIt4I7mKZ9YIqioymCzLq9gwQbooMDQaHWBfEbwrbw
qHyGO0aoSCqI3Haadr8faqU9GY/rOPNk3sgrDQoo//fb4hVC1CLQJ13hef4Y53CI
rU7m2Ys6xt0nUW7/vGT1M0NPAgMBAAGjQjBAMA4GA1UdDwEB/wQEAwIBBjAPBgNV
HRMBAf8EBTADAQH/MB0GA1UdDgQWBBR5tFnme7bl5AFzgAiIyBpY9umbbjANBgkq
hkiG9w0BAQsFAAOCAgEAVR9YqbyyqFDQDLHYGmkgJykIrGF1XIpu+ILlaS/V9lZL
ubhzEFnTIZd+50xx+7LSYK05qAvqFyFWhfFQDlnrzuBZ6brJFe+GnY+EgPbk6ZGQ
3BebYhtF8GaV0nxvwuo77x/Py9auJ/GpsMiu/X1+mvoiBOv/2X/qkSsisRcOj/KK
NFtY2PwByVS5uCbMiogziUwthDyC3+6WVwW6LLv3xLfHTjuCvjHIInNzktHCgKQ5
ORAzI4JMPJ+GslWYHb4phowim57iaztXOoJwTdwJx4nLCgdNbOhdjsnvzqvHu7Ur
TkXWStAmzOVyyghqpZXjFaH3pO3JLF+l+/+sKAIuvtd7u+Nxe5AW0wdeRlN8NwdC
jNPElpzVmbUq4JUagEiuTDkHzsxHpFKVK7q4+63SM1N95R1NbdWhscdCb+ZAJzVc
oyi3B43njTOQ5yOf+1CceWxG1bQVs5ZufpsMljq4Ui0/1lvh+wjChP4kqKOJ2qxq
4RgqsahDYVvTH9w7jXbyLeiNdd8XM2w9U/t7y0Ff/9yi0GE44Za4rF2LN9d11TPA
mRGunUHBcnWEvgJBQl9nJEiU0Zsnvgc/ubhPgXRR4Xq37Z0j4r7g1SgEEzwxA57d
emyPxgcYxn/eR44/KJ4EBs+lVDR3veyJm+kXQ99b21/+jh5Xos1AnX5iItreGCc=
-----END CERTIFICATE-----""";

class SkyManager extends StatelessWidget {
  final bool isLoggedIn;
  const SkyManager({Key? key, required this.isLoggedIn}) : super(key: key);

  // First widget
  // No AppBar, because AppBar in the screens
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: MaterialApp
      // (
      debugShowCheckedModeBanner: false,
      title: 'SkyManager', // Not visible
      theme: appTheme(), //Load AppTheme
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      initialRoute: isLoggedIn ? '/Home' : '/Login', // Initial route
      // home:
      //     isLoggedIn ? TicketCustomersScreen() : LoginScreen(), // Home or Login
      onGenerateRoute: (settings) {
        if (settings.name == '/Home' || settings.name == '/') {
          _launchDefault();
        }
        if (settings.name!.contains('?')) {
          try {
            int questionMarkIndex = settings.name!.indexOf('?');
            switch (settings.name!.substring(0, questionMarkIndex)) {
              // Create Mail Screen
              case '/entries/createMail':
                final ticketID =
                    Uri.parse(settings.name!).queryParameters['ticketID'];
                return MaterialPageRoute(
                    builder: (context) =>
                        SendMailEntryScreen(currentTicketID: ticketID!),
                    settings: RouteSettings(name: settings.name));
              // Create new Task
              case '/tasks/create':
                final ticketID =
                    Uri.parse(settings.name!).queryParameters['ticketID'];
                if (kDebugMode) {
                  print("TicketID for Create Tasks: $ticketID");
                }
                return MaterialPageRoute(
                    builder: (context) => CreateTaskScreen(
                        createWithTicketId: int.tryParse(ticketID ?? ""),
                        isNewTask: true),
                    settings: RouteSettings(name: settings.name));

              case '/tasks/edit':
                final taskID =
                    Uri.parse(settings.name!).queryParameters['taskID'];
                if (kDebugMode) {
                  print("TaskID for Edit Tasks: $taskID");
                }
                return MaterialPageRoute(
                    builder: (context) => CreateTaskScreen(
                        notNewTaskId: int.tryParse(taskID ?? ""),
                        isNewTask: false),
                    settings: RouteSettings(name: settings.name));
              default:
              // _launchDefault();
            }
          } catch (e) {
            _launchDefault();
          }
        }
        _launchDefault();
        return null;
      },
      routes: routes,
    )
        // )
        ;
  }

  _launchDefault() {
    if (isLoggedIn) {
      return MaterialPageRoute(builder: (context) => TicketCustomersScreen());
    } else {
      return MaterialPageRoute(builder: (context) => LoginScreen());
    }
  }
}
