import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skymanager/models/eintrag.dart';

import 'package:skymanager/services/api_requests.dart' as api;
import '../../../services/globals.dart' as globals; // global variables

class NewEintragScreen extends StatefulWidget {
  final bool isNewEntry;

  const NewEintragScreen({Key? key, required this.isNewEntry})
      : super(key: key);

  @override
  _NewEintragScreenState createState() => _NewEintragScreenState();
}

class _NewEintragScreenState extends State<NewEintragScreen> {
  late final TextEditingController _controllerEintragText =
      TextEditingController();
  late final TextEditingController _controllerZeitText =
      TextEditingController();
  // ignore: avoid_init_to_null
  Eintrag? currentEntry = null;

  bool isNewEntry = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isNewEntry) {
      isNewEntry = false;
      currentEntry = ModalRoute.of(context)!.settings.arguments as Eintrag;
      _controllerEintragText.text = currentEntry!.beschreibung;
      _controllerZeitText.text = currentEntry!.arbeitszeit.toString();
    }
    return GestureDetector(
        // return Scaffold(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              // automaticallyImplyLeading: false,
              title: isNewEntry
                  ? const Text('New Entry')
                  : Text('Edit Entry #' + currentEntry!.id.toString()),
            ),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _controllerEintragText,
                    decoration: const InputDecoration(
                      hintText: 'Entry',
                    ),
                    textInputAction: TextInputAction.next,
                    autofocus: true,
                  ),
                  TextField(
                    controller: _controllerZeitText,
                    decoration: const InputDecoration(hintText: 'Time'),
                    onSubmitted: (String value) {
                      _submitEntry();
                    },
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: false),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        try {
                          final text = newValue.text;
                          if (text.isNotEmpty) double.parse(text);
                          return newValue;
                          // ignore: empty_catches
                        } catch (e) {}
                        return oldValue;
                      }),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton.icon(
                      onPressed: () {
                        _submitEntry();
                      },
                      icon: const Icon(Icons.save),
                      label: const Text("Save")),
                ],
              ),
            )));
  }

  @override
  void dispose() {
    _controllerEintragText.dispose();
    _controllerZeitText.dispose();
    super.dispose();
  }

  _submitEntry() {
    if (isNewEntry) {
      _createNewEintrag();
    } else {
      _updateEintrag();
    }
  }

  _updateEintrag() async {
    await api.updateEntry(currentEntry!.id.toString(),
        _controllerEintragText.text, _controllerZeitText.text, context);
    Navigator.pop(context);
  }

  _createNewEintrag() {
    if (_controllerEintragText.text.isNotEmpty &&
        _controllerZeitText.text.isNotEmpty) {
      api
          .createEntry(globals.currentTicketID.toString(),
              _controllerEintragText.text, _controllerZeitText.text, context)
          .then((response) {
        Navigator.pop(context);
      });
    } else {
      const snackBar = SnackBar(
          content: Text('Please fill out all fields.'),
          duration: Duration(milliseconds: 300));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
