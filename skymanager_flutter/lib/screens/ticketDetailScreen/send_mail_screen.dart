import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skymanager/models/user.dart';
import '../../../services/globals.dart' as globals; // global variables
import 'package:skymanager/services/api_requests.dart' as api;

class SendMailEntryScreen extends StatefulWidget {
  final String currentTicketID;
  const SendMailEntryScreen({Key? key, required this.currentTicketID})
      : super(key: key);

  @override
  _SendMailEntryScreenState createState() => _SendMailEntryScreenState();
}

class _SendMailEntryScreenState extends State<SendMailEntryScreen> {
  late final TextEditingController _controllerEintragText =
      TextEditingController();
  late final TextEditingController _controllerZeitText =
      TextEditingController();
  late final TextEditingController _controllerMailRecipient =
      TextEditingController();

  bool showUserDropdown = false;

  List<User> zustaendige = [];
  @override
  Widget build(BuildContext context) {
    zustaendige = globals.zustaendige;
    return GestureDetector(
        // return Scaffold(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              // automaticallyImplyLeading: false,
              title: Text('#${widget.currentTicketID} Send Mail'),
            ),
            body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controllerMailRecipient,
                              decoration: const InputDecoration(
                                hintText: 'Recipient',
                                border: OutlineInputBorder(),
                              ),
                              textInputAction: TextInputAction.next,
                              autofocus: true,
                            ),
                          ),
                          const SizedBox(width: 5),
                          IconButton(
                            icon: const Icon(Icons.book),
                            onPressed: () {
                              setState(() {
                                showUserDropdown = !showUserDropdown;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      showUserDropdown
                          ? Column(children: [
                              DropdownSearch<User>(
                                mode: Mode.MENU,
                                isFilteredOnline: true,
                                showSelectedItems: false,
                                compareFn: (i, s) => i?.isEqual(s!) ?? false,
                                dropdownSearchDecoration: const InputDecoration(
                                  labelText: "User",
                                  contentPadding:
                                      EdgeInsets.fromLTRB(12, 12, 0, 0),
                                  border: OutlineInputBorder(),
                                ),
                                onFind: (String? filter) => getUser(filter),
                                onChanged: (data) {
                                  setState(() {
                                    if (_controllerMailRecipient.text
                                        .contains(data!.email)) {
                                      return;
                                    }
                                    if (_controllerMailRecipient.text.isEmpty) {
                                      _controllerMailRecipient.text =
                                          data.email;
                                    } else {
                                      _controllerMailRecipient.text +=
                                          "; " + data.email;
                                    }
                                  });
                                },
                                selectedItem: null,
                                showSearchBox: true,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                            ])
                          : Container(),
                      TextField(
                        controller: _controllerEintragText,
                        decoration: const InputDecoration(
                          hintText: 'Mail Text',
                          border: OutlineInputBorder(),
                        ),
                        minLines: 3,
                        maxLines: 10,
                        textInputAction: TextInputAction.next,
                        autofocus: true,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: _controllerZeitText,
                        decoration: const InputDecoration(
                          hintText: 'Time',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (String value) {
                          _createNewEintrag();
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
                            _createNewEintrag();
                          },
                          icon: const Icon(Icons.mail),
                          label: const Text("Send Mail")),
                    ],
                  ),
                ))));
  }

  Future<List<User>> getUser(String? filter) async {
    if (filter == null) {
      return zustaendige;
    }
    var searchedUser = <User>[];
    for (var user in zustaendige) {
      if (user.name.toLowerCase().contains(filter.toLowerCase()) ||
          user.email.contains(filter)) {
        searchedUser.add(user);
      }
    }
    return searchedUser;
  }

  @override
  void dispose() {
    _controllerEintragText.dispose();
    _controllerZeitText.dispose();
    super.dispose();
  }

  _createNewEintrag() {
    if (_controllerEintragText.text.isNotEmpty &&
        _controllerZeitText.text.isNotEmpty &&
        _controllerMailRecipient.text.isNotEmpty) {
      api
          .createEntryWithSendMail(
              widget.currentTicketID,
              _controllerEintragText.text,
              _controllerZeitText.text,
              _controllerMailRecipient.text,
              context)
          .then((value) => Navigator.pop(context));
    } else {
      const snackBar = SnackBar(
          content: Text('Please fill out all fields!'),
          duration: Duration(milliseconds: 300));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
