import 'package:flash/flash.dart';
import 'package:flutter/material.dart';

import 'package:skymanager/services/api_requests.dart' as api;
import '../../../services/globals.dart' as globals;

class NewPassScreen extends StatefulWidget {
  const NewPassScreen({Key? key}) : super(key: key);

  @override
  _NewPassScreenState createState() => _NewPassScreenState();
}

class _NewPassScreenState extends State<NewPassScreen> {
  var currKunde = globals.currentKunde;

  final TextEditingController _titelController = TextEditingController(),
      _benutzerController = TextEditingController(),
      _passwortController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Password for: ' +
              currKunde.name +
              ' #' +
              currKunde.id.toString()),
        ),
        body: Padding(
            padding: const EdgeInsets.all(8),
            child: Center(
                child: Column(
              children: <Widget>[
                TextField(
                  controller: _titelController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                  ),
                  textInputAction: TextInputAction.next,
                  autofocus: true,
                ),
                TextField(
                  controller: _benutzerController,
                  decoration: const InputDecoration(
                    labelText: 'User',
                  ),
                  textInputAction: TextInputAction.next,
                ),
                TextField(
                  controller: _passwortController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                  onSubmitted: (String value) {
                    _createPasswort();
                    // Process data.
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                    child: const Text('New Password'),
                    onPressed: () {
                      _createPasswort();
                    }),
              ],
            ))));
  }

  _createPasswort() {
    if (_titelController.text.isNotEmpty &&
        _benutzerController.text.isNotEmpty &&
        _passwortController.text.isNotEmpty) {
      api
          .createCustomerPass(currKunde.id.toString(), _titelController.text,
              _benutzerController.text, _passwortController.text, context)
          .then((value) {
        if (value == "New Kundenpass: " + _titelController.text) {
          context.showSuccessBar(
              content: const Text("Successfully created new pass"));
          _titelController.text = "";
          _benutzerController.text = "";
          _passwortController.text = "";
        }
      });
    } else {
      const snackBar = SnackBar(
          content: Text('Please fill in all fields'),
          duration: Duration(milliseconds: 300));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
