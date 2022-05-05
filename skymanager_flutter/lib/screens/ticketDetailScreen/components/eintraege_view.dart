import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:skymanager/models/eintrag.dart';
import 'package:skymanager/services/api_requests.dart' as api;
import '../../../services/globals.dart' as globals; // global variables

class EintraegeView extends StatefulWidget {
  const EintraegeView({Key? key}) : super(key: key);

  @override
  EintraegeViewState createState() => EintraegeViewState();
}

class EintraegeViewState extends State<EintraegeView> {
  var eintraege = <Eintrag>[];
  num gesamtZeit = 0;
  @override
  void initState() {
    super.initState();
  }

  reloadEintraege() {
    setState(() {});
  }

  Future<List<Eintrag>> _loadEintraege() async {
    var eintraegeFromApi = await api.getCurrentEintraege(
        globals.currentTicketID.toString(), context);
    Iterable list = eintraegeFromApi;
    eintraege = list.map((model) => Eintrag.fromJson(model)).toList();
    gesamtZeit = eintraege.fold(
        0, (previousValue, element) => previousValue + element.arbeitszeit);
    return eintraege;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _loadEintraege(),
        // ignore: non_constant_identifier_names
        builder: (context, AsyncSnapshot EintraegeSnapshot) {
          if (EintraegeSnapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (EintraegeSnapshot.hasError) {
            return Center(child: Text('Error: ${EintraegeSnapshot.error}'));
          }

          if (EintraegeSnapshot.hasData) {
            eintraege = EintraegeSnapshot.data;
            return RefreshIndicator(
                onRefresh: () async {
                  reloadEintraege();
                },
                child: Stack(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: eintraege.length,
                      itemBuilder: (context, index) {
                        return Slidable(
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  icon: Icons.delete,
                                  label: 'Delete',
                                  onPressed: (BuildContext context) {
                                    showDeleteDialog(eintraege[index]);
                                  },
                                ),
                              ],
                            ),
                            child: Card(
                                child: InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                              context, "/entries/edit",
                                              arguments: eintraege[index])
                                          .then((value) => reloadEintraege());
                                    },
                                    child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(children: <Widget>[
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(eintraege[index]
                                                  .beschreibung),
                                            ),
                                          ),
                                          Expanded(
                                              child: Align(
                                            alignment: Alignment.center,
                                            child:
                                                Text(eintraege[index].username),
                                          )),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Text(eintraege[index]
                                                      .arbeitszeit
                                                      .toString() +
                                                  'h'),
                                            ),
                                          ),
                                          IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () {
                                                showDeleteDialog(
                                                    eintraege[index]);
                                              }),
                                        ])))));
                      },
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      // Your elements here
                      Center(
                          child: Text(
                        "Time: " + gesamtZeit.toString() + "h",
                        style: const TextStyle(backgroundColor: Colors.blue),
                      ))
                    ],
                  )
                ]));
          } else {
            return const Center(child: Text('No Entries found'));
          }
        });
  }

  showDeleteDialog(Eintrag currentEintrag) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Delete Entry + ' + currentEintrag.beschreibung),
            content: const Text('Are you sure you want to delete this Entry?'),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: const Text('Delete'),
                onPressed: () {
                  Navigator.of(context).pop();
                  api
                      .deleteEntry(currentEintrag.id.toString(), context)
                      .then((value) {
                    reloadEintraege();
                  });
                },
              ),
            ],
          );
        });
  }
}
