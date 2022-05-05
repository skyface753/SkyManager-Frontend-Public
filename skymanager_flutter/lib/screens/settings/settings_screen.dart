import 'package:flash/flash.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';
import 'package:skymanager/services/globals.dart'
    as globals; // global variables
import 'package:skymanager/services/api_requests.dart' as api;
import 'package:url_launcher/url_launcher.dart';
import 'package:skymanager/fixed_values.dart' as fixed_values;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool useBiometrics = false;
  bool twofaEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      useBiometrics = prefs.getBool('useBiometrics') ?? false;
      twofaEnabled = globals.twofaEnabled;
    });
  }

  void saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('useBiometrics', useBiometrics);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: Column(
          children: [
            SwitchListTile(
              title: const Text('Biometric Authentication'),
              secondary: const Icon(Icons.security),
              onChanged: (value) {
                _tryBiometricLock(value);
              },
              value: useBiometrics,
            ),
            SwitchListTile(
              title: const Text('Enable 2FA'),
              secondary: const Icon(Icons.lock),
              onChanged: (value) {
                if (value) {
                  Navigator.pushNamed(context, "/users/Enable2FA")
                      .then((value) => setState(() {
                            twofaEnabled = globals.twofaEnabled;
                          }));
                } else {
                  _disable2FA();
                }
              },
              value: twofaEnabled,
            ),
            const Divider(),
            // Privacy Policy
            ListTile(
              title: const Center(child: Text('Privacy Policy')),
              onTap: () async {
                if (await canLaunch(fixed_values.privacyUrl)) {
                  await launch(fixed_values.privacyUrl);
                }
              },
            ),
            const Divider(),
            // Show globals.averageTime
            ListTile(
              title: const Text('Average Api-Time in ms'),
              trailing:
                  Text('${globals.getAverageTimeRoundedInMillisecounds()} ms'),
            ),
            const Divider(),
          ],
        ));
  }

  _tryBiometricLock(value) async {
    try {
      var localAuth = LocalAuthentication();
      bool didAuthenticate = await localAuth.authenticate(
          localizedReason: 'Please authenticate to unlock');
      if (didAuthenticate) {
        // print('SettingsAuthenticated');
        setState(() {
          useBiometrics = value;
          saveSettings();
        });
      } else {
        // print('SettingsNot Authenticated');
      }
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
        // Handle this exception here.
      }
    }
  }

  final TextEditingController _controllerTOTP = TextEditingController();

  // Disabke 2FA alert dialog
  void _disable2FA() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: const Text("Disable 2FA"),
          content: const Text("Are you sure you want to disable 2FA?"),
          actions: <Widget>[
            TextField(
                controller: _controllerTOTP,
                autofillHints: const [AutofillHints.oneTimeCode],
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ], // Only numbers
                decoration: const InputDecoration(hintText: 'TOTP Code'),
                autocorrect: false,
                enableSuggestions: false,
                onSubmitted: (value) {
                  _submitDisableTOTP(context);
                }),

            // usually buttons at the bottom of the dialog
            ElevatedButton(
              child: const Text("Yes"),
              onPressed: () {
                _submitDisableTOTP(context);
              },
            ),
            ElevatedButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _submitDisableTOTP(BuildContext context) async {
    var response = await api.disableTOTP(_controllerTOTP.text, context);
    if (response == "Disabled") {
      context.showSuccessBar(content: const Text("2FA Disabled"));
      Navigator.of(context).pop();
      setState(() {
        twofaEnabled = false;
      });
    } else {
      context.showErrorBar(content: Text(response));
    }
  }
}
