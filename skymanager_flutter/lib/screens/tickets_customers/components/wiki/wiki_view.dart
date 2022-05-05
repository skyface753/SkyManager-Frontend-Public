import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:skymanager/components/drawer.dart';
import 'package:skymanager/models/wiki.dart';
import 'package:skymanager/services/api_requests.dart' as api;
import 'package:skymanager/services/globals.dart'
    as globals; // global variables

class WikiView extends StatefulWidget {
  const WikiView({Key? key}) : super(key: key);
  @override
  WikiViewState createState() => WikiViewState();
}

class WikiViewState extends State<WikiView> {
  // var wikis = <Wiki>[];

  @override
  void initState() {
    // getWikis();
    super.initState();
  }

  // getWikis() async {
  //   api.getWiki(context).then((value) {
  //     setState(() {
  //       if (value != null) {
  //         Iterable list = value;
  //         wikis = list.map((model) => Wiki.fromJson(model)).toList();
  //         globals.wikiList = wikis;
  //       }
  //     });
  //   });
  // }

  Future<List<Wiki>?> _getWikiList() async {
    var value = await api.getWiki(context);
    Iterable list = value;
    List<Wiki> wikis = list.map((model) => Wiki.fromJson(model)).toList();
    globals.wikiList = wikis;
    return wikis;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wiki'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      drawer: const SkyManagerDrawer(),
      body: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: FutureBuilder(
                  future: _getWikiList(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.data == null) {
                      return const Center(child: Text('No wikis found'));
                    } else if (snapshot.hasError) {
                      return const Center(child: Text('Error'));
                    } else if (snapshot.hasData) {
                      List<Wiki> wikis = snapshot.data;
                      if (wikis.isEmpty) {
                        return const Center(child: Text('No wikis found'));
                      }
                      return ListView.builder(
                        itemCount: wikis.length,
                        itemBuilder: (context, index) {
                          return Slidable(
                            child: Card(
                              child: ListTile(
                                  title: Text(wikis[index].Titel),
                                  subtitle: wikis[index].Text.length > 50
                                      ? Text(wikis[index]
                                              .Text
                                              .substring(0, 50)
                                              .replaceAll("\n", " ") +
                                          '...')
                                      : Text(wikis[index]
                                          .Text
                                          .replaceAll("\n", " ")),
                                  onTap: () => {
                                        globals.currentWiki = wikis[index],
                                        Navigator.pushNamed(context, '/wikis',
                                                arguments: wikis[index])
                                            .then(
                                          (value) => setState((() {})),
                                        )
                                      }),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(child: Text('No wikis found'));
                    }
                  }))),
    );
  }
}
