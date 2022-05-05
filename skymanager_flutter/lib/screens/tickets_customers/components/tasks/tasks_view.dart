// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:skymanager/components/drawer.dart';
import 'package:skymanager/models/task.dart';
import 'package:skymanager/services/api_requests.dart' as api;
import 'package:skymanager/services/globals.dart'
    as globals; // global variables

class TasksView extends StatefulWidget {
  const TasksView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TasksViewState();
}

class TasksViewState extends State<TasksView> {
  var tasks = <Task>[];

  List<Task> completedTasks = <Task>[];
  List<Task> ownTasks = <Task>[];
  List<Task> assignedTasks = <Task>[];

  @override
  void initState() {
    super.initState();
  }

  reloadTasks() {
    setState(() {});
  }

  Future<List<Task>?> _getTaskSnapshot() async {
    var listOfTasks = await api.getActiveUserTasks(context);
    if (listOfTasks != null) {
      Iterable list = listOfTasks;
      tasks = list.map((model) => Task.fromJson(model)).toList();
      globals.currentTasks = tasks;
      _createSeperateTaskLists(tasks);
      return tasks;
    }
    return null;
  }

  _createSeperateTaskLists(List<Task> tempTasks) {
    completedTasks.clear();
    ownTasks.clear();
    assignedTasks.clear();
    for (var currentTask in tempTasks) {
      if (currentTask.isCompleted == 1) {
        completedTasks.add(currentTask);
      } else if (currentTask.owner == globals.ownUsername) {
        ownTasks.add(currentTask);
      } else {
        assignedTasks.add(currentTask);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // getTasks();
              setState(() {});
            },
          ),
        ],
      ),
      drawer: const SkyManagerDrawer(),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.pushNamed(context, '/tasks/create');
      //   },
      //   child: const Icon(Icons.add),
      // ),
      body: FutureBuilder(
          future: _getTaskSnapshot(),
          builder: (context, AsyncSnapshot TasksSnapshot) {
            if (TasksSnapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (TasksSnapshot.hasError) {
              return Center(child: Text('Error: ${TasksSnapshot.error}'));
            }

            if (TasksSnapshot.hasData) {
              tasks = TasksSnapshot.data;
              if (tasks.isEmpty) {
                return const Center(child: Text('No tasks to show'));
              }
              return RefreshIndicator(
                  onRefresh: () async {
                    // getTasks();
                    setState(() {});
                  },
                  child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                          child: Center(
                              child: Column(
                            children: [
                              ownTasks.isEmpty
                                  ? Container()
                                  : _createTitleOverListViews("Own Tasks"),
                              ownTasks.isEmpty
                                  ? Container()
                                  : _createTaskListView(ownTasks),
                              assignedTasks.isEmpty
                                  ? Container()
                                  : _createTitleOverListViews("Assigned Tasks"),
                              assignedTasks.isEmpty
                                  ? Container()
                                  : _createTaskListView(assignedTasks),
                              completedTasks.isEmpty
                                  ? Container()
                                  : _createTitleOverListViews(
                                      "Completed Tasks"),
                              completedTasks.isEmpty
                                  ? Container()
                                  : _createTaskListView(completedTasks),
                            ],
                          )))));
            } else {
              return const Center(child: Text('No Data'));
            }
          }),
    );
  }

  Widget _createTitleOverListViews(String text) {
    return Row(children: <Widget>[
      const Expanded(child: Divider()),
      Text(text),
      const Expanded(child: Divider()),
    ]);
  }

  Widget _createTaskListView(List<Task> tasksForListView) {
    return ListView.builder(
      itemCount: tasksForListView.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      primary: false,
      itemBuilder: (context, index) {
        return Slidable(
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                tasksForListView[index].isCompleted == 0
                    ? SlidableAction(
                        icon: Icons.delete,
                        label: 'Complete',
                        onPressed: (BuildContext context) {
                          api
                              .completeTask(
                                  tasksForListView[index].id.toString(),
                                  context)
                              .then((value) => setState(() {})
                                  // getTasks()
                                  );
                        },
                      )
                    : SlidableAction(
                        icon: Icons.check,
                        label: 'Reopen',
                        onPressed: (BuildContext context) {
                          api
                              .reopenTask(tasksForListView[index].id.toString(),
                                  context)
                              .then((value) => setState(() {})
                                  // getTasks()
                                  );
                        },
                      ),
                SlidableAction(
                  icon: Icons.delete,
                  label: 'Delete',
                  onPressed: (BuildContext context) {
                    api
                        .deleteTask(
                            tasksForListView[index].id.toString(), context)
                        .then((value) => setState(() {})
                            // getTasks()
                            );
                  },
                ),
              ],
            ),
            child: Card(
                color: tasksForListView[index].isCompleted == 0
                    ? null
                    : Colors.lightGreen,
                child: InkWell(
                    onTap: () {
                      globals.currentTaskID = 0;
                      Navigator.pushNamed(
                              context,
                              '/tasks/edit?taskID=' +
                                  tasksForListView[index].id.toString())
                          .then((value) => setState(() {})
                              // getTasks()
                              );
                    },
                    child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(children: <Widget>[
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "#" +
                                    tasksForListView[index].id.toString() +
                                    " " +
                                    tasksForListView[index].title,
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                tasksForListView[index].beschreibung,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          )),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              tasksForListView[index].ticket_fk == null
                                  ? const Text("")
                                  : Text(
                                      tasksForListView[index]
                                          .ticket_fk
                                          .toString(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                            ],
                          )),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                tasksForListView[index]
                                    .datetime
                                    .substring(0, 9),
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                tasksForListView[index]
                                    .datetime
                                    .substring(11, 16),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          )),
                        ])))));
      },
    );
  }
}
