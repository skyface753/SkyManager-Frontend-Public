import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skymanager/models/kunde.dart';
import 'package:skymanager/services/api_requests.dart' as api;
import '../../../services/globals.dart' as globals; // global variables
import 'package:maps_launcher/maps_launcher.dart';

class CustomerInfoScreen extends StatefulWidget {
  const CustomerInfoScreen({Key? key}) : super(key: key);

  @override
  _CustomerInfoScreenState createState() => _CustomerInfoScreenState();
}

class _CustomerInfoScreenState extends State<CustomerInfoScreen> {
  // var currKundeList = <CurrKunde>[];
  Kunde currKunde = globals.currentKunde;
  final TextEditingController _idController = TextEditingController(),
      _nameController = TextEditingController(),
      _mailController = TextEditingController(),
      _plzController = TextEditingController(),
      _stadtController = TextEditingController(),
      _strasseController = TextEditingController(),
      _hausnummerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:
              Text("#" + currKunde.id.toString() + " " + _nameController.text),
          actions: [
            IconButton(
              onPressed: () {
                MapsLauncher.launchQuery(currKunde.strasse +
                    " " +
                    currKunde.hausnummer +
                    ", " +
                    currKunde.plz +
                    " " +
                    currKunde.stadt);
              },
              icon: const Icon(Icons.map),
            ),
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                TextField(
                  controller: _mailController,
                  decoration: const InputDecoration(
                    labelText: 'Mail',
                  ),
                ),
                TextField(
                  controller: _plzController,
                  decoration: const InputDecoration(
                    labelText: 'Zip Code',
                  ),
                ),
                TextField(
                  controller: _stadtController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                  ),
                ),
                TextField(
                  controller: _strasseController,
                  decoration: const InputDecoration(
                    labelText: 'Street',
                  ),
                ),
                TextField(
                  controller: _hausnummerController,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'House number',
                  ),
                ),
                ElevatedButton(
                    child: const Text('Save'),
                    onPressed: () {
                      api
                          .updateCustomer(
                              currKunde.id.toString(),
                              _nameController.text,
                              _mailController.text,
                              _plzController.text,
                              _stadtController.text,
                              _strasseController.text,
                              _hausnummerController.text,
                              context)
                          .then((value) => {
                                Navigator.pop(context),
                              });
                    }),
              ],
            )));
  }

  @override
  void initState() {
    _idController.text = currKunde.id.toString();
    _nameController.text = currKunde.name;
    _mailController.text = currKunde.mail;
    _plzController.text = currKunde.plz;
    _stadtController.text = currKunde.stadt;
    _strasseController.text = currKunde.strasse;
    _hausnummerController.text = currKunde.hausnummer;
    super.initState();
  }

  // _currKundeList(){
  //   BackendApi('', jsonEncodedBody, context)
  // }
}
