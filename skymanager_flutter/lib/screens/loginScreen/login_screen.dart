import 'package:flash/flash.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skymanager/services/api_requests.dart' as api;
import 'package:introduction_screen/introduction_screen.dart';
import 'package:flutter_linkify/flutter_linkify.dart';

import 'package:skymanager/services/globals.dart'
    as globals; // global variables
import 'package:url_launcher/url_launcher.dart';

//Entry point for the loginscreen
class LoginScreen extends StatefulWidget {
  // final String? ticketID;
  const LoginScreen({
    Key? key,
    // this.ticketID
  }) : super(key: key);
  @override
  _LoginScreen createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  late TextEditingController _controllerUsernameText;
  late TextEditingController _controllerPasswordText;
  late TextEditingController _controllerURLText;
  late TextEditingController _controllerTOTPText;
  bool checkedValue = false;
  bool showIntroducion = false;
  bool isBrowserFrontend = false;
  String urlForBrowserFrontend = "";
  bool loginProcess = false;

  bool totpRequired = false;

  @override
  void initState() {
    _controllerURLText = TextEditingController();
    _controllerUsernameText = TextEditingController();
    _controllerPasswordText = TextEditingController();
    _controllerTOTPText = TextEditingController();
    getLocalData();
    super.initState();
  }

  checkIfIsBrowserFrontend() {
    urlForBrowserFrontend = const String.fromEnvironment('BACKEND_URL');
    if (urlForBrowserFrontend != "") {
      setState(() {
        isBrowserFrontend = true;
        _controllerURLText.text = urlForBrowserFrontend;
      });
    }
  }

  void getLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    final urlSaved = prefs.getString('serverUrl') ?? '';

    setState(() {
      showIntroducion = prefs.getBool('showIntroducion') ?? true;
    });
    checkIfIsBrowserFrontend();
    if (urlSaved.isNotEmpty && !isBrowserFrontend) {
      _controllerURLText.text = urlSaved;
    }
  }

  @override
  void dispose() {
    _controllerUsernameText.dispose();
    _controllerPasswordText.dispose();
    _controllerURLText.dispose();
    super.dispose();
  }

  completeIntroducion() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('showIntroducion', false);
    setState(() {
      showIntroducion = false;
    });
  }

  List<PageViewModel> getPages() {
    return [
      PageViewModel(
          // image: Image.asset("images/livedemo.png"),
          title: "Introductions",
          body:
              "Welcome to SkyManager\n\nSkyManager is an Open Source Ticket, Tasks, Passwords, Docs and Wiki Manager",
          footer: Linkify(
            onOpen: (link) async {
              if (kDebugMode) {
                print("Linkify link = ${link.url}");
              }
              if (await canLaunch(link.url)) {
                await launch(link.url);
              } else {
                throw 'Could not launch ${link.url}';
              }
            },
            text:
                "Setup your own SkyManager Instance \n\n View on Github -   https://github.com/skyface753/SkyManager",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
            linkStyle: const TextStyle(color: Colors.white),
          ),
          decoration: const PageDecoration(
            pageColor: Colors.blue,
          )),
      PageViewModel(
          // image: Image.asset("images/demo4.png"),
          title: "Customers",
          body: "View and manage your customers",
          footer: const Text(
            "Create new customers\n\nView all customers\n\nCreate passwords and upload files",
            textAlign: TextAlign.center,
          ),
          decoration: const PageDecoration(
            pageColor: Colors.blue,
          )),
      PageViewModel(
          // image: Image.asset("images/visueldemo.png"),
          title: "Tickets",
          body: "View and manage your tickets",
          footer: const Text(
            "Create Entries and send them as a Mail",
            textAlign: TextAlign.center,
          ),
          decoration: const PageDecoration(
            pageColor: Colors.blue,
          )),
      PageViewModel(
          // image: Image.asset("images/demo3.png"),
          title: "Tasks",
          body: "View and manage your tasks",
          footer: const Text(
            "Create Tasks, assign them to a ticket and add to your calendar",
            textAlign: TextAlign.center,
          ),
          decoration: const PageDecoration(
            pageColor: Colors.blue,
          )),
      PageViewModel(
          // image: Image.asset("images/demo4.png"),
          title: "Wiki",
          body: "View and manage your wiki",
          footer: const Text(
            "Create and edit wiki pages\n\nPreview with the integrated Markdown Editor",
            textAlign: TextAlign.center,
          ),
          decoration: const PageDecoration(
            pageColor: Colors.blue,
          )),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        // return Scaffold(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text('SkyManager Login' +
                  (isBrowserFrontend
                      ? " (" + urlForBrowserFrontend + ")"
                      : "")),
              actions: <Widget>[
                IconButton(
                    onPressed: () {
                      setState(() {
                        showIntroducion = true;
                      });
                    },
                    icon: const Icon(Icons.help)),
              ],
            ),
            body: showIntroducion
                ? IntroductionScreen(
                    globalBackgroundColor: Colors.white,
                    pages: getPages(),
                    showNextButton: true,
                    showSkipButton: true,
                    skip: const Text("Skip"),
                    next: const Text("Next"),
                    done: const Text("Done"),
                    onDone: () {
                      completeIntroducion();
                    },
                    onSkip: () {
                      completeIntroducion();
                    },
                    onChange: (int current) {},
                  )
                : Stack(
                    children: [
                      loginProcess
                          ? const Center(child: CircularProgressIndicator())
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: Column(
                          children: <Widget>[
                            isBrowserFrontend
                                ? Container()
                                : TextFormField(
                                    controller: _controllerURLText,
                                    autofocus: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Instance URL',
                                      hintText:
                                          'https://skymanager.example.com',
                                    ),
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.url,
                                    autofillHints: const [
                                      AutofillHints.url,
                                    ],
                                    enabled: isBrowserFrontend ? false : true,
                                    autocorrect: false,
                                  ),
                            Column(
                              children: [
                                TextFormField(
                                    controller: _controllerUsernameText,
                                    decoration: const InputDecoration(
                                        hintText: 'Username'),
                                    autocorrect: false,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter your name';
                                      }
                                      return null;
                                    },
                                    enableSuggestions: false,
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.text,
                                    autofillHints: const [
                                      AutofillHints.username
                                    ]),
                                TextFormField(
                                  controller: _controllerPasswordText,
                                  autofillHints: const [AutofillHints.password],
                                  decoration: const InputDecoration(
                                      hintText: 'Password'),
                                  obscureText: true,
                                  enableSuggestions: false,
                                  validator: (value) => value!.isEmpty
                                      ? 'Please enter your password'
                                      : null,
                                  autocorrect: false,
                                  onFieldSubmitted: (value) {
                                    totpRequired
                                        ? TextInputAction.next
                                        : login();
                                  },
                                ),
                              ],
                            ),
                            totpRequired
                                ? Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Text(
                                        "2FA Required",
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextField(
                                        controller: _controllerTOTPText,
                                        autofillHints: const [
                                          AutofillHints.oneTimeCode
                                        ],
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.digitsOnly
                                        ], // Only numbers
                                        decoration: const InputDecoration(
                                            hintText: 'TOTP Code'),
                                        autocorrect: false,
                                        autofocus: true,
                                        enableSuggestions: false,
                                        onSubmitted: (value) => login(),
                                      )
                                    ],
                                  )
                                : Container(),
                            CheckboxListTile(
                              value: checkedValue,
                              onChanged: (newValue) {
                                setState(() {
                                  checkedValue = newValue!;
                                });
                              },
                              title: const Text('Remember me'),
                            ),
                            ElevatedButton.icon(
                                onPressed: () {
                                  login();
                                },
                                icon: const Icon(Icons.login),
                                label: const Text("Login")),
                          ],
                        ),
                      )
                    ],
                  )));
  }

  void login() {
    setState(() {
      loginProcess = true;
    });
    _controllerURLText.text =
        _controllerURLText.text.trim().replaceAll(" ", "");
    _controllerUsernameText.text =
        _controllerUsernameText.text.trim().replaceAll(" ", "");
    _controllerPasswordText.text =
        _controllerPasswordText.text.trim().replaceAll(" ", "");
    if (_controllerURLText.text.isEmpty) {
      if (kDebugMode) {
        _controllerURLText.text = "http://localhost:8451";
      }
    }
    if (_controllerUsernameText.text.isEmpty && kDebugMode) {
      _controllerUsernameText.text = "Admin";
      _controllerPasswordText.text = "SkyManager";
      log("Replaces Login Data for Test");
    }
    if (!_controllerURLText.text.startsWith("http")) {
      _controllerURLText.text = "https://" + _controllerURLText.text;
    }
    api.serverUrl = _controllerURLText.text;
    api
        .login(_controllerUsernameText.text, _controllerPasswordText.text,
            _controllerTOTPText.text, true, context, checkedValue)
        .then((value) {
      setState(() {
        loginProcess = false;
      });
      if (value != false) {
        if (value == "TOTP") {
          setState(() {
            totpRequired = true;
          });
          return null;
        }

        globals.twofaEnabled = totpRequired;
        TextInput.finishAutofillContext;
        Navigator.pushReplacementNamed(context, '/Home');
      } else {
        context.showErrorBar(content: const Text("Login failed"));
      }
    });
  }
}
