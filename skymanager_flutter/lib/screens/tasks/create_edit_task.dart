// ignore_for_file: empty_catches

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:skymanager/models/task.dart';
import 'package:skymanager/models/ticket.dart';
import 'package:skymanager/models/user.dart';
import 'package:skymanager/services/api_requests.dart' as api;
import 'package:skymanager/services/globals.dart' as globals;
import 'package:add_2_calendar/add_2_calendar.dart';

import 'package:skymanager/services/load_models.dart';

class CreateTaskScreen extends StatefulWidget {
  final int? createWithTicketId;
  final bool isNewTask;
  final int? notNewTaskId;
  const CreateTaskScreen(
      {Key? key,
      this.createWithTicketId,
      required this.isNewTask,
      this.notNewTaskId})
      : super(key: key);

  @override
  _CreateTaskScreenState createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final TextEditingController _titleController = TextEditingController(),
      _descriptionController = TextEditingController(),
      _ticketForTaskController = TextEditingController();

  var tickets = <Ticket>[];
  bool _allTicketsLoaded = false;

  bool withTicket = false;

  getTickets() {
    setState(() {
      tickets = globals.ticketList;
      if (tickets.isEmpty) {
        _ticketForTaskController.text = "";
      } else {
        _ticketForTaskController.text = tickets[0].id.toString();
      }
      _allTicketsLoaded = true;
    });
  }

  bool isnewTask = true;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  Task currentTask =
      Task(0, "", "", DateTime.now().toString(), null, 0, "", []);

  var selectedUsers = <User>[];
  var allUsers = <User>[];
  bool _allUsersLoaded = false;

  @override
  void initState() {
    getTickets();
    _loadUsers();
    // tickets = globals.ticketList;
    super.initState();
    _readTaskFromRoute();
    _readTicketFromRoute();
  }

  _readTaskFromRoute() {
    isnewTask = widget.isNewTask;
    if (isnewTask) {
      if (kDebugMode) {
        print("new task");
      }
      return;
    } else {
      if (widget.notNewTaskId == null) {
        if (kDebugMode) {
          print("no task id in edit Mode - Exit");
        }

        return;
      }
      _loadTaskByID(widget.notNewTaskId!);
    }
  }

  _readTicketFromRoute() {
    withTicket = widget.createWithTicketId != null ? true : false;
    if (withTicket) {
      _ticketForTaskController.text = widget.createWithTicketId.toString();
    } else {
      _ticketForTaskController.text = tickets[0].id.toString();
    }
  }

  _loadUsers() async {
    loadUserList(context).then((value) => setState(() {
          allUsers = value;
          _allUsersLoaded = true;
        }));
  }

  _loadTaskByID(int currentTaskID) async {
    api.getTaskByID(currentTaskID.toString(), context).then((value) {
      //CurrentTask from value["Result"] as JSON
      Iterable list = value["Result"];
      currentTask = Task.fromJson(list.first);
      list = value["Users"];
      List<String> users = list.map((e) => e["User_FK"].toString()).toList();
      currentTask.users = users;
      setState(() {
        selectedUsers = users
            .map((e) => allUsers.firstWhere((element) => element.name == e))
            .toList();
        selectedDate = DateTime.parse(currentTask.datetime);
        selectedTime = TimeOfDay.fromDateTime(selectedDate);
        _titleController.text = currentTask.title;
        _descriptionController.text = currentTask.beschreibung;
        if (currentTask.ticket_fk != null) {
          withTicket = true;
          _ticketForTaskController.text = currentTask.ticket_fk.toString();
        } else {
          withTicket = false;
          _ticketForTaskController.text = tickets[0].id.toString();
        }
      });
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  _selectTime(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (timeOfDay != null && timeOfDay != selectedTime) {
      setState(() {
        selectedTime = timeOfDay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            appBar: AppBar(
                title: isnewTask
                    ? const Text('Create Task')
                    : Row(
                        children: [
                          Text('Task #${currentTask.id} by'),
                          Container(
                            margin: const EdgeInsets.all(15),
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              color: Colors.lightBlue,
                            ),
                            child: Text(
                              currentTask.owner,
                            ),
                          )
                        ],
                      ),
                actions: !kIsWeb
                    ? <Widget>[
                        IconButton(
                          onPressed: (() => _createCalendarEntry()),
                          icon: const Icon(FontAwesomeIcons.calendar),
                        )
                      ]
                    : null),
            body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Center(
                      child: Column(children: <Widget>[
                        TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                          ),
                          textInputAction: TextInputAction.next,
                          autofocus: true,
                        ),
                        TextField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                          ),
                          textInputAction: TextInputAction.next,
                          autofocus: true,
                        ),
                        // Text("${selectedDate.toLocal()}".split(' ')[0]),
                        const SizedBox(
                          height: 20.0,
                        ),
                        _allUsersLoaded == false
                            ? const Center(child: CircularProgressIndicator())
                            : DropdownSearch<User>.multiSelection(
                                mode: Mode.MENU,
                                isFilteredOnline: false,
                                showSelectedItems: true,
                                compareFn: (i, s) => i?.isEqual(s!) ?? false,
                                dropdownSearchDecoration: const InputDecoration(
                                  labelText: "Users",
                                  contentPadding:
                                      EdgeInsets.fromLTRB(12, 12, 0, 0),
                                  border: OutlineInputBorder(),
                                ),
                                onFind: (String? filter) => getUsers(filter!),
                                onChanged: (data) {
                                  setState(() {
                                    selectedUsers = data;
                                  });
                                  // setState(() {
                                  if (kDebugMode) {
                                    print("Users Changed: " +
                                        selectedUsers.toString());
                                  }
                                  // });
                                },
                                selectedItems: selectedUsers,
                              ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => _selectDate(context),
                              child: Text(
                                  "${selectedDate.toLocal()}".split(' ')[0]),
                            ),
                            const SizedBox(
                              width: 20.0,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _selectTime(context);
                              },
                              child: Text(
                                  "${selectedTime.hour}:${selectedTime.minute}"),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        SwitchListTile(
                          title: const Text('With Ticket'),
                          secondary: const Icon(Icons.list),
                          onChanged: (value) {
                            setState(() {
                              withTicket = value;
                            });
                          },
                          value: withTicket,
                        ),
                        withTicket && _allTicketsLoaded && tickets.isNotEmpty
                            ? DropdownSearch<Ticket>(
                                mode: Mode.MENU,
                                isFilteredOnline: false,
                                showSelectedItems: true,
                                compareFn: (i, s) => i?.isEqual(s!) ?? false,
                                dropdownSearchDecoration: const InputDecoration(
                                  labelText: "Ticket",
                                  contentPadding:
                                      EdgeInsets.fromLTRB(12, 12, 0, 0),
                                  border: OutlineInputBorder(),
                                ),
                                onFind: (String? filter) =>
                                    getTicketsSearch(filter),
                                onChanged: (data) {
                                  setState(() {
                                    _ticketForTaskController.text =
                                        data!.id.toString();
                                  });
                                },
                                selectedItem: tickets.firstWhere((element) =>
                                    element.id ==
                                    int.parse(_ticketForTaskController.text)),
                                showSearchBox: true,
                              )
                            : Container(),
                        const SizedBox(
                          height: 10.0,
                        ),
                        ElevatedButton(
                            onPressed: () => {
                                  if (isnewTask)
                                    {
                                      createTask(),
                                    }
                                  else
                                    {
                                      updateTask(),
                                    }
                                },
                            child: const Text("Save")),
                        const SizedBox(
                          height: 10,
                        ),
                      ]),
                    )))));
  }

  _createCalendarEntry() {
    DateTime eventTimeAndDate = DateTime(selectedDate.year, selectedDate.month,
        selectedDate.day, selectedTime.hour, selectedTime.minute);
    final Event event = Event(
      title: _titleController.text,
      description: _descriptionController.text,
      location: "https://open.skymanager.net?taskID=${currentTask.id}",
      startDate: eventTimeAndDate,
      endDate: eventTimeAndDate.add(const Duration(minutes: 30)),
      iosParams: const IOSParams(
        reminder: Duration(
            /* Ex. hours:1 */), // on iOS, you can set alarm notification after your event.
      ),
      androidParams: const AndroidParams(
        emailInvites: [], // on Android, you can add invite emails to your event.
      ),
    );
    Add2Calendar.addEvent2Cal(event);
  }

  Future<List<Ticket>> getTicketsSearch(String? filter) async {
    if (filter == null) {
      return tickets;
    }
    return tickets
        .where((ticket) => ticket.titel.toString().contains(filter))
        .toList();
  }

  Future<List<User>> getUsers(String? filter) async {
    if (filter == null) {
      return allUsers;
    }
    return allUsers
        .where((User user) =>
            user.name.toLowerCase().contains(filter.toLowerCase()))
        .toList();
  }

  createTask() {
    var usersObj = [];
    for (var element in selectedUsers) {
      usersObj.add('"' + element.name + '"');
    }
    api
        .createTask(
            _titleController.text,
            _descriptionController.text,
            DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
                    selectedTime.hour, selectedTime.minute)
                .toString(),
            withTicket ? _ticketForTaskController.text : "",
            usersObj.toString(),
            context)
        .then((value) => {Navigator.pop(context)});
  }

  updateTask() {
    var usersObj = [];
    for (var element in selectedUsers) {
      usersObj.add('"' + element.name + '"');
    }
    api
        .updateTask(
            currentTask.id.toString(),
            _titleController.text,
            _descriptionController.text,
            DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
                    selectedTime.hour, selectedTime.minute)
                .toString(),
            withTicket ? _ticketForTaskController.text : "",
            usersObj.toString(),
            context)
        .then((value) => {Navigator.pop(context)});
  }
}
