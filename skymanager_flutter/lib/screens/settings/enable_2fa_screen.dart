import 'package:flash/flash.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skymanager/services/api_requests.dart' as api;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:skymanager/services/globals.dart'
    as globals; // global variables

class Enable2FA extends StatefulWidget {
  const Enable2FA({Key? key}) : super(key: key);

  @override
  _Enable2FAState createState() => _Enable2FAState();
}

class _Enable2FAState extends State<Enable2FA> {
  final TextEditingController _controllerTOTPText = TextEditingController();
  String totpUrl = "";
  String secretKey = "";

  generateFirstTOTP() async {
    totpUrl = await api.generateFirstTOTP(context);
    setState(() {
      totpUrl = totpUrl;
      Uri settingsUri = Uri.parse(totpUrl);
      secretKey = settingsUri.queryParameters['secret']!;
    });
  }

  @override
  void initState() {
    super.initState();
    generateFirstTOTP();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Enable MFA'),
        ),
        body: SingleChildScrollView(
            child: GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: !kIsWeb
                              ? () async {
                                  if (await canLaunch(totpUrl)) {
                                    await launch(totpUrl);
                                  } else {
                                    throw 'Could not launch $totpUrl';
                                  }
                                }
                              : null,
                          child: Column(
                            children: [
                              const Text(
                                  "Scan the QR-Code or click here to open in your Authenticator App"),
                              const SizedBox(height: 20),
                              QrImage(
                                data: totpUrl,
                                version: QrVersions.auto,
                                size: 200.0,
                                backgroundColor: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                            onPressed: () => Clipboard.setData(
                                ClipboardData(text: secretKey)),
                            child: Text("Copy the secret key '" +
                                secretKey +
                                "' to clipboard")),
                        Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            const Text(
                              "Enter the code from your Authenticator\nto verify and enable the 2FA",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                            TextField(
                                controller: _controllerTOTPText,
                                autofillHints: const [
                                  AutofillHints.oneTimeCode
                                ],
                                autofocus: true,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ], // Only numbers
                                decoration: const InputDecoration(
                                    hintText: 'TOTP Code'),
                                autocorrect: false,
                                enableSuggestions: false,
                                onSubmitted: (value) {
                                  _tryVerification();
                                }),
                            const SizedBox(
                              height: 20,
                            ),
                            ElevatedButton(
                                onPressed: () => _tryVerification(),
                                child: const Text("Verify"))
                          ],
                        )
                      ],
                    )))));
  }

  _tryVerification() {
    if (_controllerTOTPText.text.isNotEmpty) {
      api.verifyFirstTOTP(_controllerTOTPText.text, context).then((value) {
        if (value == "Verified") {
          // context.showSuccessBar(content: Text(value));
          context.showSuccessBar(content: const Text("2FA Enabled"));
          globals.twofaEnabled = true;
          Navigator.pop(context);
        } else {
          context.showErrorBar(content: Text(value));
        }
      });
    } else {
      context.showErrorBar(content: const Text("Please enter a valid code"));
    }
  }
}
