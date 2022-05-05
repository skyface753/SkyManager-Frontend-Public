import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otp/otp.dart';
import 'package:skymanager/models/totp.dart';
import 'package:skymanager/services/api_requests.dart' as api;

import 'package:skymanager/services/globals.dart' as globals;

class TotpView extends StatefulWidget {
  const TotpView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TotpViewState();
}

class TotpViewState extends State<TotpView> {
  int customerID = globals.currentKundeID;

  List<Totp> totps = [];

  getTotpsForCustomer() async {
    var response = await api.getTotpPerCustomer(customerID.toString(), context);
    if (response == null) {
      return;
    }
    Iterable list = response;
    setState(() {
      totps = list.map((model) => Totp.fromJson(model)).toList();
    });
  }

  late Timer _everySecond;

  @override
  void initState() {
    super.initState();
    getTotpsForCustomer();
    _everySecond = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _everySecond.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('TOTP'),
          actions: [
            IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  getTotpsForCustomer();
                }),
          ],
        ),
        body: Center(
            child: RefreshIndicator(
                onRefresh: () async {
                  getTotpsForCustomer();
                },
                child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: totps.isEmpty
                        ? const Text("No TOTP found")
                        : ListView.builder(
                            itemCount: totps.length,
                            itemBuilder: (context, index) {
                              var currentTOTPCode = OTP.generateTOTPCodeString(
                                  totps[index].secret,
                                  DateTime.now().millisecondsSinceEpoch,
                                  length: totps[index].digits,
                                  interval: totps[index].period,
                                  algorithm: totps[index].algorithm);

                              return Card(
                                child: ListTile(
                                  textColor: OTP.remainingSeconds(
                                              interval: totps[index].period) <=
                                          5
                                      ? Colors.red
                                      : null,
                                  leading: CircularProgressIndicator(
                                      value: OTP
                                              .remainingSeconds(
                                                  interval: totps[index].period)
                                              .toDouble() /
                                          totps[index].period.toDouble()),
                                  title: Text(currentTOTPCode,
                                      style: const TextStyle(fontSize: 20)),
                                  subtitle: Text(totps[index].issuer),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      _showTotpDeleteAlert(totps[index]);
                                    },
                                  ),
                                  onTap: () {
                                    //Copy to Clipboard
                                    Clipboard.setData(
                                        ClipboardData(text: currentTOTPCode));
                                  },
                                ),
                              );
                            },
                          )))));
  }

  _showTotpDeleteAlert(Totp currentTotp) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete TOTP: " + currentTotp.issuer),
          content: const Text("Do you really want to delete this TOTP?"),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text("Yes"),
              onPressed: () async {
                await api.deleteTotp(currentTotp.id.toString(), context);
                setState(() {
                  getTotpsForCustomer();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
