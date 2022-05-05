import 'package:flutter/material.dart';
import 'package:flutter_gravatar/flutter_gravatar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:skymanager/components/tickets_view.dart';
import 'package:skymanager/models/ticket.dart';
import '../../../services/globals.dart' as globals; // global variables
import 'package:skymanager/services/api_requests.dart' as api;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Ticket> ticketsFromToday = [];

  List<int> latestTickets = [];

  loadTicketsFromToday() async {
    api.getTicketsFromUserForToday(context).then((response) => {
          setState(() {
            Iterable list = response;
            ticketsFromToday =
                list.map((model) => Ticket.fromJson(model)).toList();
          })
        });
  }

  _loadLatestTickets() async {
    await getLatestTickets(context).then((value) {
      setState(() {
        latestTickets = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    loadTicketsFromToday();
    _loadLatestTickets();
  }

  @override
  Widget build(BuildContext context) {
    var gravatar = Gravatar(globals.ownEMail);
    var username = globals.ownUsername;
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Colors.greenAccent,
      ),
      body: SingleChildScrollView(
          child: Column(children: [
        Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                  // Colors.pinkAccent,
                  Colors.greenAccent,
                  Colors.blueAccent,
                ])),
            child: SizedBox(
              width: double.infinity,
              height: 200.0,
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: NetworkImage(gravatar.imageUrl()),
                      radius: 50.0,
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 22.0,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                  ],
                ),
              ),
            )),
        Padding(
          padding: const EdgeInsets.all(10),
          child: ListTile(
            leading: const Icon(
              Icons.lock,
              color: Colors.redAccent,
            ),
            title: const Text(
              "Change Password",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              _displayPasswordChangeDialog(context);
            },
          ),
        ),
        const Text(
          "Latest Tickets",
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: ListView.builder(
              itemCount: latestTickets.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: const Icon(
                      FontAwesomeIcons.hashtag,
                      color: Colors.redAccent,
                    ),
                    title: Text(
                      latestTickets[index].toString(),
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      globals.currentTicketID = latestTickets[index];
                      Navigator.pushNamed(context, '/tickets/details')
                          .then((value) {
                        _loadLatestTickets();
                        FocusScope.of(context).unfocus();
                      });
                    },
                  ),
                );
              }),
        ),
        const Text(
          "Today",
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: ListView.builder(
              itemCount: ticketsFromToday.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return TicketView(
                  tickets: ticketsFromToday,
                  index: index,
                  afterOnClick: () => setState(() {
                    loadTicketsFromToday();
                  }),
                );
              }),
        ),
      ])),
    );
  }

  _displayPasswordChangeDialog(BuildContext scafContext) async {
    TextEditingController _changePasswordController = TextEditingController(),
        _confirmPasswordController = TextEditingController();

    showDialog(
      context: scafContext,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Change " + globals.ownUsername + " Password"),
              content:
                  Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                TextField(
                  controller: _changePasswordController,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    hintText: "Enter new password",
                    border: InputBorder.none,
                  ),
                ),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    hintText: "Confirm new password",
                    border: InputBorder.none,
                  ),
                )
              ]),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                TextButton(
                  child: const Text("Submit"),
                  onPressed: () {
                    if (_changePasswordController.text !=
                        _confirmPasswordController.text) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Error"),
                            content: const Text("Passwords do not match"),
                            actions: <Widget>[
                              TextButton(
                                child: const Text("Ok"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      api
                          .changeUserPassword(globals.ownUsername,
                              _changePasswordController.text, context)
                          .then((value) => {
                                if (value ==
                                    "Changed Password: " + globals.ownUsername)
                                  {
                                    Navigator.of(context).pop(),
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Success"),
                                          content:
                                              const Text("Password changed"),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text("Ok"),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    )
                                  }
                                else
                                  {
                                    // Navigator.of(context).pop(),
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Error"),
                                          content: Text(value),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text("Ok"),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    )
                                  }
                              });
                    }
                  },
                ),
                TextButton(
                  child: const Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
