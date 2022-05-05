import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:skymanager/services/api_requests.dart' as api;

class NewKundeScreen extends StatefulWidget {
  const NewKundeScreen({Key? key}) : super(key: key);

  @override
  _NewKundeScreenState createState() => _NewKundeScreenState();
}

class _NewKundeScreenState extends State<NewKundeScreen> {
  final TextEditingController _nameController = TextEditingController(),
      _mailController = TextEditingController(),
      _plzController = TextEditingController(),
      _stadtController = TextEditingController(),
      _strasseController = TextEditingController(),
      _hausnummerController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('New Customer'),
        ),
        body: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Center(
                child: Column(
              children: <Widget>[
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                  textInputAction: TextInputAction.next,
                  autofocus: true,
                ),
                TextField(
                  controller: _mailController,
                  decoration: const InputDecoration(
                    labelText: 'Mail',
                  ),
                  textInputAction: TextInputAction.next,
                  autofocus: true,
                ),
                TextField(
                  controller: _plzController,
                  decoration: const InputDecoration(
                    labelText: 'zip code',
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(6),
                  ],
                  textInputAction: TextInputAction.next,
                ),
                TextField(
                  controller: _stadtController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                  ),
                  textInputAction: TextInputAction.next,
                ),
                TextField(
                  controller: _strasseController,
                  decoration: const InputDecoration(
                    labelText: 'Street',
                  ),
                  textInputAction: TextInputAction.next,
                ),
                TextField(
                  controller: _hausnummerController,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(5),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'house number',
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (String value) {
                    _createKunde();
                  },
                ),
                ElevatedButton(
                    child: const Text('Create Customer'),
                    onPressed: () {
                      _createKunde();
                    }),
                //TODO: Implement
                // ElevatedButton(
                //     onPressed: (() {
                //       Navigator.pushNamed(context, '/customers/import');
                //     }),
                //     child: const Text("Import from CSV"))
              ],
            ))));
  }

  _createKunde() {
    if (_nameController.text.isNotEmpty &&
        _mailController.text.isNotEmpty &&
        _plzController.text.isNotEmpty &&
        _stadtController.text.isNotEmpty &&
        _strasseController.text.isNotEmpty &&
        _hausnummerController.text.isNotEmpty) {
      api
          .createCustomer(
              _nameController.text,
              _mailController.text,
              _plzController.text,
              _stadtController.text,
              _strasseController.text,
              _hausnummerController.text,
              context)
          .then((value) {
        if (value == "New Kunde" + _nameController.text) {
          const snackBar = SnackBar(
              content: Text('Customer created successfully'),
              duration: Duration(milliseconds: 300));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          FocusScope.of(context).unfocus();
          Navigator.pop(context);
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
