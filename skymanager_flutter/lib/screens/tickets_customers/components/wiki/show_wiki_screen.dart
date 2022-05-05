import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:skymanager/models/wiki.dart';
import 'package:skymanager/services/globals.dart' as globals;
import 'package:skymanager/services/api_requests.dart' as api;

class ShowWikiScreen extends StatefulWidget {
  const ShowWikiScreen({Key? key}) : super(key: key);

  @override
  _ShowWikiScreenState createState() => _ShowWikiScreenState();
}

class _ShowWikiScreenState extends State<ShowWikiScreen> {
  String _loadedWikiTextForChange = "", _loadedWikiTitleForChange = "";
  bool _wasEdited = false;

  bool isNewWiki = false;
  late Wiki currentWiki;
  bool editWiki = false;
  final TextEditingController _wikiTextController = TextEditingController(),
      _wikiTitleController = TextEditingController();

  @override
  void initState() {
    loadCurrentWiki();
    super.initState();
  }

  _checkIfWikiChanged() {
    if (_loadedWikiTextForChange != _wikiTextController.text ||
        _loadedWikiTitleForChange != _wikiTitleController.text) {
      setState(() {
        _wasEdited = true;
      });
    } else {
      setState(() {
        _wasEdited = false;
      });
    }
    // return false;
  }

  loadCurrentWiki() {
    setState(() {
      if (globals.currentWiki == null) {
        isNewWiki = true;
        editWiki = true;
        currentWiki = Wiki(0, "", "");
      } else {
        currentWiki = globals.currentWiki;
      }
      _wikiTextController.text = currentWiki.Text;
      _wikiTitleController.text = currentWiki.Titel;
      _loadedWikiTextForChange = currentWiki.Text;
      _loadedWikiTitleForChange = currentWiki.Titel;
    });
  }

  Future<String> loadWikiText() async {
    return currentWiki.Text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isNewWiki
            ? const Text("Create Wiki")
            : Text("Wiki #" + currentWiki.ID.toString()),
        actions: [
          editWiki
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      currentWiki.Text = _wikiTextController.text;
                      editWiki = false;
                    });
                  },
                  icon: const Icon(Icons.visibility))
              : IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      editWiki = true;
                    });
                  },
                ),
        ],
      ),
      body: FutureBuilder(
          future: loadWikiText(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              if (editWiki) {
                return SingleChildScrollView(
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 8.0,
                            ),
                            TextField(
                              controller: _wikiTitleController,
                              maxLines: null,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Wiki Title",
                              ),
                              onChanged: (value) => _checkIfWikiChanged(),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _wikiTextController,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Wiki Text",
                              ),
                              onChanged: (value) => _checkIfWikiChanged(),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            _wasEdited
                                ? ElevatedButton(
                                    child: const Text("Save"),
                                    onPressed: () {
                                      _saveOrNewWiki();
                                    },
                                  )
                                : Container(),
                          ],
                        )));
              } else {
                return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(_wikiTitleController.text,
                            style: const TextStyle(fontSize: 20)),
                        Expanded(
                            child: Markdown(
                          data: snapshot.data!,
                          onTapLink:
                              (String? url, String? title, String? content) {},
                          styleSheet: MarkdownStyleSheet(
                              tableBorder: TableBorder.all()),
                        )),
                        _wasEdited
                            ? ElevatedButton(
                                child: const Text("Save"),
                                onPressed: () {
                                  _saveOrNewWiki();
                                },
                              )
                            : Container(),
                        const SizedBox(height: 10),
                      ],
                    ));
              }
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }

  _saveOrNewWiki() {
    if (isNewWiki) {
      api
          .createWiki(
              _wikiTitleController.text, _wikiTextController.text, context)
          .then((value) => Navigator.pop(context));
    } else {
      api
          .updateWiki(currentWiki.ID.toString(), _wikiTitleController.text,
              _wikiTextController.text, context)
          .then((value) => Navigator.pop(context));
    }
  }
}
