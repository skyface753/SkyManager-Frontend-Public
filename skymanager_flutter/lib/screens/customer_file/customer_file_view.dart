// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
// import 'dart:ffi';
import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:async';
import 'package:async/async.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../../../services/globals.dart' as globals; // global variables
import 'package:skymanager/services/api_requests.dart' as api;
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as httpweb;
import 'package:universal_html/html.dart' as html;
import 'package:skymanager/models/serverfile.dart';

typedef VoidCallback = void Function();

class CustomerFileView extends StatefulWidget {
  final int customerID;
  const CustomerFileView({Key? key, required this.customerID})
      : super(key: key);

  @override
  _CustomerFileState createState() => _CustomerFileState();
}

class _CustomerFileState extends State<CustomerFileView> {
  late File file;
  int customerID = 0;
  //Create List of files
  List<ServerFile> serverFiles = [];

  bool _isDownload = false;

  bool _isSearching = false;
  final TextEditingController _searchQueryController = TextEditingController();
  String searchQuery = "Search query";
  final List<ServerFile> _searchFilesList = <ServerFile>[];

  double progressMobileDownload = 0.0;

  bool isloaded = false;
  bool uploadOrDownloadInProgress = false;

  // ignore: avoid_init_to_null
  PlatformFile? objFile = null;

  Future<void> getFile() async {
    if (kIsWeb) {
      var result = await FilePicker.platform.pickFiles(
        withReadStream:
            true, // this will return PlatformFile object with read stream
      );
      if (result != null) {
        setState(() {
          uploadOrDownloadInProgress = true;
          objFile = result.files.single;
          uploadFileWeb();
        });
      }
    } else {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        setState(() {
          uploadOrDownloadInProgress = true;
        });
        file = File(result.files.single.path!);
        uploadFile(file, null);
      } else {
        // User canceled the picker
      }
    }
  }

  uploadFileWeb() async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse(api.serverUrl + "/upload"),
    );
    request.headers['Authorization'] = api.token;
    request.fields['customer_fk'] = customerID.toString();

    request.files.add(http.MultipartFile(
        "myFile", objFile!.readStream!, objFile!.size,
        filename: objFile!.name));

    var resp = await request.send();

    //------Read response
    String result = await resp.stream.bytesToString();
    if (kDebugMode) {
      print(result);
    }
    setState(() {
      uploadOrDownloadInProgress = false;
      isloaded = false;
    });
  }

  uploadFile(File fileForUpload, String? filename) async {
    var stream =
        // ignore: deprecated_member_use
        http.ByteStream(DelegatingStream.typed(fileForUpload.openRead()));
    var length = await fileForUpload.length();
    var uri = Uri.parse(api.serverUrl + "/upload");
    var request = http.MultipartRequest("POST", uri);
    var fileNameforRequest = "";
    if (filename != null) {
      fileNameforRequest = filename;
    } else {
      fileNameforRequest = path.basename(fileForUpload.path);
    }
    var multipartFile = http.MultipartFile('myFile', stream, length,
        filename: fileNameforRequest);
    request.files.add(multipartFile);

    request.headers['Authorization'] = api.token;
    request.fields['customer_fk'] = customerID.toString();
    var response = await request.send();
    response.stream.transform(utf8.decoder).listen((value) {
      setState(() {
        uploadOrDownloadInProgress = false;
        isloaded = false;
      });
    });
  }

  fetchDocuments() async {
    if (isloaded) {
      return;
    }
    try {
      var response = await http.post(
        Uri.parse(api.serverUrl + '/docs'),
        headers: {
          'Authorization': api.token,
        },
        body: {
          'customer_fk': customerID.toString(),
        },
      );
      Iterable list = jsonDecode(response.body);
      serverFiles = list.map((model) => ServerFile.fromJson(model)).toList();

      setState(() {
        isloaded = true;
      });
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    customerID = globals.currentKundeID;
    fetchDocuments();
    return Scaffold(
        appBar: AppBar(
          title: _isSearching ? _buildSearchField() : const Text('Files'),
          actions: _buildActions(context),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await getFile();
          },
          child: const Icon(Icons.upload),
        ),
        body: Stack(
          children: [
            isloaded
                ? _isSearching && _searchQueryController.text.isNotEmpty
                    ? _buildFileListView(_searchFilesList)
                    : _buildFileListView(serverFiles)
                : const Center(child: CircularProgressIndicator()),
            uploadOrDownloadInProgress
                ? kIsWeb
                    ? const Center(child: CircularProgressIndicator())
                    : _isDownload
                        ? Center(
                            child: LinearProgressIndicator(
                            value: progressMobileDownload,
                          ))
                        : const Center(child: CircularProgressIndicator())

                // CircularProgressIndicator()

                : Container(),
          ],
          // ),
        ));
  }

  Widget _buildFileListView(List<ServerFile> FilesForListview) {
    return ListView.builder(
      itemCount: FilesForListview.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(FilesForListview[index].name),
          subtitle: Text(FilesForListview[index].path),
          onTap: () {
            _openFile(FilesForListview[index]);
          },
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              deleteFile(FilesForListview[index], context);
            },
          ),
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade200,
            child: Text(FilesForListview[index]
                .name
                .substring(FilesForListview[index].name.lastIndexOf('.') + 1)),
          ),
        );
      },
    );
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

  List<Widget> _buildActions(BuildContext scaffoldContext) {
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
          //Button to Refresh the Files
          icon: const Icon(Icons.refresh),
          onPressed: () {
            setState(() {
              isloaded = false;
            });
          },
        ),
      ];
    }
  }

  void _startSearch() {
    ModalRoute.of(context)!
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      _searchFilesList.clear();
      _isSearching = true;
    });
  }

  void updateSearchQuery(String newQuery) {
    searchQuery = newQuery;
    _searchFilesList.clear();
    // ignore: avoid_function_literals_in_foreach_calls
    for (var file in serverFiles) {
      if (file.name.toLowerCase().contains(searchQuery.toLowerCase())) {
        _searchFilesList.add(file);
      }
    }
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

  deleteFile(ServerFile file, BuildContext context) async {
    // show dialog to confirm delete
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete file"),
          content:
              Text("Are you sure you want to delete ${file.name} this file?"),
          actions: [
            ElevatedButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text("Delete"),
              onPressed: () async {
                setState(() {
                  uploadOrDownloadInProgress = true;
                });
                Navigator.of(context).pop();
                await api.deleteDocu(file.id.toString(), context).then((value) {
                  if (value == "File Deleted") {
                    setState(() {
                      isloaded = false;
                      uploadOrDownloadInProgress = false;
                    });
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  _openFile(ServerFile currFile) async {
    if (kIsWeb) {
      _startDownloadOrUpload();
      var headers = {
        'Content-Type': 'application/octet-stream',
        'Accept': 'application/octet-stream',
        'Authorization': api.token,
      };
      String fileurl = api.serverUrl + '/' + currFile.path;
      Uri uri = Uri.parse(fileurl);
      httpweb.Response res = await httpweb.get(uri, headers: headers);

      if (res.statusCode == 200) {
        final blob = html.Blob([res.bodyBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..style.display = 'none'
          ..download = currFile.name;
        html.document.body?.children.add(anchor);

        anchor.click();

        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
      }
      _endDownloadOrUpload();
    } else {
      _isDownload = true;
      _startDownloadOrUpload();
      String fileurl = api.serverUrl + '/' + currFile.path;
      String savePath = (await getTemporaryDirectory()).path;

      try {
        await Dio().download(fileurl, savePath + '/' + currFile.name,
            options: Options(headers: {'Authorization': api.token}),
            onReceiveProgress: (received, total) {
          if (total != -1) {
            //you can build progressbar feature too
            setState(() {
              progressMobileDownload = received / total;
            });
          }
        });
        _endDownloadOrUpload();
        OpenFile.open(savePath + '/' + currFile.name);
      } catch (error) {
        if (kDebugMode) {
          print(error);
        }

        _endDownloadOrUpload();
      }
    }
  }

  _startDownloadOrUpload() {
    setState(() {
      uploadOrDownloadInProgress = true;
    });
  }

  _endDownloadOrUpload() {
    setState(() {
      _isDownload = false;
      uploadOrDownloadInProgress = false;
    });
  }
}
