// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gravatar/flutter_gravatar.dart';
import 'package:skymanager/models/role.dart';
import 'package:skymanager/models/user.dart';

import 'package:skymanager/services/load_models.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:skymanager/services/api_requests.dart' as api;

class ShowUsersScreen extends StatefulWidget {
  const ShowUsersScreen({Key? key}) : super(key: key);

  @override
  _ShowUsersScreenState createState() => _ShowUsersScreenState();
}

class _ShowUsersScreenState extends State<ShowUsersScreen> {
  var users = <User>[];
  final List<User> _searchUser = <User>[];
  var rollen = <Role>[];

  final TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;
  String searchQuery = "Search query";

  _loadUsers() async {
    loadUserList(context).then((value) => setState(() {
          users = value;
        }));
  }

  @override
  void initState() {
    loadRoleList(context).then((value) => setState(() {
          rollen = value;
        }));
    _loadUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: _isSearching ? _buildSearchField() : const Text('Users'),
          actions: _buildActions(),
          // title: const Text('Users'),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.pushNamed(context, '/users/create').then(
                (value) => {_loadUsers(), FocusScope.of(context).unfocus()});
          },
        ),
        body: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _loadUsers();
              });
            },
            child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: Center(
                    child: _searchUser.isNotEmpty ||
                            _searchQueryController.text.isNotEmpty
                        ? _buildUserListView(_searchUser)
                        : _buildUserListView(users)))));
  }

  Widget _buildUserListView(List<User> userForListView) {
    return ListView.builder(
      itemCount: userForListView.length,
      itemBuilder: (context, index) {
        // ignore: prefer_typing_uninitialized_variables
        var gravatar;
        try {
          if (userForListView[index].email != "") {
            gravatar = Gravatar(userForListView[index].email);
          }
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
        return Slidable(
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  icon: Icons.edit,
                  onPressed: (BuildContext context) {
                    _displayEditOptions(context, userForListView[index]);
                  },
                  label: 'Edit',
                ),
                userForListView[index].isActive == 1
                    ? SlidableAction(
                        icon: Icons.delete,
                        label: 'Disable',
                        onPressed: (BuildContext context) {
                          _displayDisableUserDialog(
                              context, userForListView[index]);
                        },
                      )
                    : SlidableAction(
                        icon: Icons.check,
                        label: 'Enable',
                        onPressed: (BuildContext context) {
                          _displayEnableUserDialog(
                              context, userForListView[index]);
                        },
                      ),
              ],
            ),
            child: Card(
              child: ListTile(
                tileColor: userForListView[index].isActive == 1
                    ? userForListView[index].role_fk == "Admin"
                        ? Colors.green.shade800
                        : null
                    : Colors.redAccent,
                title: Text(userForListView[index].name),
                subtitle: Text(userForListView[index].email),

                leading: gravatar != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(gravatar.imageUrl()),
                      )
                    : null,
                trailing: Text(
                    userForListView[index].LastLogin_Date.substring(0, 10) +
                        "\n" +
                        userForListView[index].LastLogin_Time),
                // onTap: () {
                //   _displayRoleChangeDialog(context, userForListView[index]);
                // },
              ),
            ));
      },
    );
  }

  _displayEditOptions(BuildContext context, User currentUser) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Column(
            children: [
              Expanded(
                child: SimpleDialog(
                  title: const Text('Edit User'),
                  children: [
                    SimpleDialogOption(
                        onPressed: () {
                          _displayPasswordChangeDialog(context, currentUser);
                        },
                        child: Text('Change Passwort')),
                    SimpleDialogOption(
                        onPressed: () {
                          _displayRoleChangeDialog(context, currentUser);
                        },
                        child: Text('Change Role')),
                    SimpleDialogOption(
                        onPressed: () {
                          _displayMailChangeDialog(context, currentUser);
                        },
                        child: Text('Change Mail')),
                  ],
                  elevation: 10,
                  //backgroundColor: Colors.green,
                ),
              ),
              ElevatedButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: "Search Data...",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white30),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchQueryController.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            _clearSearchQuery();
          },
        ),
      ];
    } else {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _startSearch,
        ),
        IconButton(
          //Button to Refresh the Tickets
          icon: const Icon(Icons.refresh),
          onPressed: () {
            _loadUsers();
          },
        ),
      ];
    }
  }

  _displayEnableUserDialog(BuildContext context, User user) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Enable User"),
            content: Text("Do you really want to enable this user?"),
            actions: <Widget>[
              ElevatedButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                child: Text("Enable"),
                onPressed: () {
                  api
                      .enableUser(user.name, context)
                      .then((value) => {Navigator.pop(context), _loadUsers()});
                },
              ),
            ],
          );
        });
  }

  _displayDisableUserDialog(BuildContext context, User user) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Disable User"),
            content: Text("Do you really want to disable this user?"),
            actions: <Widget>[
              ElevatedButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                child: Text("Disable"),
                onPressed: () {
                  api
                      .disableUser(user.name, context)
                      .then((value) => {Navigator.pop(context), _loadUsers()});
                },
              ),
            ],
          );
        });
  }

  _displayRoleChangeDialog(BuildContext context, User currentUser) async {
    var choosenRole = currentUser.role_fk;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Change User Role"),
              content:
                  Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                DropdownButton<String>(
                  hint: Text('Select one role'),
                  value: choosenRole,
                  underline: Container(),
                  items: rollen.map((Role value) {
                    return DropdownMenuItem<String>(
                      value: value.rolename,
                      child: Text(
                        value.rolename,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      choosenRole = value!;
                    });
                  },
                )
              ]),
              actions: <Widget>[
                TextButton(
                    child: Text('Submit'),
                    onPressed: () {
                      api
                          .changeUserRole(
                              currentUser.name, choosenRole, context)
                          .then((value) => {
                                Navigator.pop(context),
                                _loadUsers(),
                              });
                    }),
                // usually buttons at the bottom of the dialog
                TextButton(
                  child: Text("Cancel"),
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

  _displayPasswordChangeDialog(BuildContext context, User currentUser) async {
    TextEditingController _changePasswordController = TextEditingController(),
        _confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Change User Password"),
              content:
                  Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                TextField(
                  controller: _changePasswordController,
                  decoration: InputDecoration(
                    hintText: "Enter new password",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.white30),
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                ),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    hintText: "Confirm new password",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.white30),
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                )
              ]),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                TextButton(
                  child: Text("Submit"),
                  onPressed: () {
                    if (_changePasswordController.text !=
                        _confirmPasswordController.text) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Error"),
                            content: Text("Passwords do not match"),
                            actions: <Widget>[
                              TextButton(
                                child: Text("Ok"),
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
                          .changeUserPassword(currentUser.name,
                              _changePasswordController.text, context)
                          .then((value) => {
                                Navigator.pop(context),
                                _loadUsers(),
                              });
                    }
                  },
                ),
                TextButton(
                  child: Text("Close"),
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

  _displayMailChangeDialog(BuildContext context, User currentUser) async {
    TextEditingController _changeMailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Change User Mail"),
              content:
                  Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                TextField(
                  controller: _changeMailController,
                  decoration: InputDecoration(
                    hintText: "Enter new Mail",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.white30),
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                ),
              ]),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                TextButton(
                  child: Text("Submit"),
                  onPressed: () {
                    api
                        .changeUserMail(currentUser.name,
                            _changeMailController.text, context)
                        .then((value) => {
                              Navigator.pop(context),
                              _loadUsers(),
                            });
                  },
                ),
                TextButton(
                  child: Text("Close"),
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

  void _startSearch() {
    ModalRoute.of(context)!
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      _searchUser.clear();
      _isSearching = true;
    });
  }

  void updateSearchQuery(String newQuery) {
    searchQuery = newQuery;
    _searchUser.clear();
    // ignore: avoid_function_literals_in_foreach_calls
    users.forEach((element) {
      if (element.name.toLowerCase().contains(searchQuery.toLowerCase())) {
        _searchUser.add(element);
      }
    });
    setState(() {});
  }

  void _stopSearching() {
    _clearSearchQuery();

    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery("");
    });
  }
}
