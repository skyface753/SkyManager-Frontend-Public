import 'dart:async';
import 'dart:io';

import 'package:flash/flash.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otp/otp.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:skymanager/services/api_requests.dart' as api;

import 'package:skymanager/services/globals.dart' as globals;

class TOTPCreateScreeen extends StatefulWidget {
  const TOTPCreateScreeen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TOTPCreateScreeenState();
}

class _TOTPCreateScreeenState extends State<TOTPCreateScreeen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  // late Timer _everySecond;

  String? secret, issuer;
  String currentKey = "";
  int digits = 6, period = 30;
  Algorithm _algorithm = Algorithm.SHA1;

  bool correctData = false;

  late Timer _everySecond;

  bool showCamera = kIsWeb ? false : true;

  final TextEditingController _issuerController = TextEditingController(),
      _secretController = TextEditingController();

  @override
  void initState() {
    _issuerController.text = "";
    super.initState();
    _everySecond = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {});
    });
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: (() => setState(() {
                      showCamera = !showCamera;
                    })),
                icon: const Icon(Icons.camera_alt)),
          ],
          title: const Text('Add TOTP'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: showCamera
                    ? QRView(
                        key: qrKey,
                        onQRViewCreated: _onQRViewCreated,
                      )
                    : Container(),
              ),
              TextField(
                controller: _issuerController,
                decoration: const InputDecoration(
                  labelText: "Accountname",
                  hintText: "Username@Microsoft",
                ),
              ),
              TextField(
                controller: _secretController,
                decoration: const InputDecoration(
                  labelText: "Key",
                  hintText: "Key",
                ),
              ),
              Text("Algorithm: " + _algorithm.toString()),
              Text("digits: " + digits.toString()),
              Text("Period: " + period.toString()),
              Text("Current TOTP: " + _getTOTPKey()),
              correctData
                  ? ElevatedButton(
                      onPressed: (() {
                        _addTOTPKey();
                      }),
                      child: const Text("Add TOTP Key"))
                  : Container(),
              const SizedBox(height: 20),
            ],
          ),
        ));
  }

  _parseURLFromBarcode() {
    if (describeEnum(result!.format) != "qrcode") {
      correctData = false;
      return false;
    }
    try {
      Uri barcodeUri = Uri.parse(result!.code!);
      secret = barcodeUri.queryParameters['secret'];
      _secretController.text = secret ?? "";

      issuer = barcodeUri.queryParameters['issuer'];
      String primaryIssuer = barcodeUri.pathSegments.first;
      if (primaryIssuer != "") {
        primaryIssuer = primaryIssuer.replaceAll(":", ' (');
        primaryIssuer = primaryIssuer + ')';
      }
      if (primaryIssuer != "") {
        _issuerController.text = primaryIssuer;
      } else {
        _issuerController.text = issuer ?? "";
      }
      // _issuerController.text = primaryIssuer ?? "";
      var currentAlgorithm = barcodeUri.queryParameters['algorithm'];
      switch (currentAlgorithm) {
        case "SHA1":
          _algorithm = Algorithm.SHA1;
          break;
        case "SHA256":
          _algorithm = Algorithm.SHA256;
          break;
        case "SHA512":
          _algorithm = Algorithm.SHA512;
          break;
        default:
          _algorithm = Algorithm.SHA1;
      }
      digits = int.tryParse(barcodeUri.queryParameters['digits']!) ?? 6;
      period = int.tryParse(barcodeUri.queryParameters['period']!) ?? 30;
      correctData = true;
    } catch (e) {
      correctData = false;
    }
  }

  String _getTOTPKey() {
    try {
      if (_secretController.text == "" || _issuerController.text == "") {
        correctData = false;
        return "No Data";
      }
      currentKey = OTP.generateTOTPCodeString(
          _secretController.text, DateTime.now().millisecondsSinceEpoch,
          length: digits, interval: period, algorithm: _algorithm);
      if (currentKey != "") {
        correctData = true;
      } else {
        correctData = false;
      }
    } catch (e) {
      correctData = false;
    }

    return currentKey;
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        _parseURLFromBarcode();
        //otpauth://totp/ACME%20Co:john.doe@email.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=SHA1&digits=6&period=30
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    _everySecond.cancel();
    super.dispose();
  }

  _addTOTPKey() async {
    var currentAlgorithm = "SHA1";
    switch (_algorithm) {
      case Algorithm.SHA1:
        currentAlgorithm = "SHA1";
        break;
      case Algorithm.SHA256:
        currentAlgorithm = "SHA256";
        break;
      case Algorithm.SHA512:
        currentAlgorithm = "SHA512";
        break;
    }
    if (kDebugMode) {
      print("Secret: " + _secretController.text);
      print("Issuer: " + _issuerController.text);
      print("Digits: " + digits.toString());
      print("Period: " + period.toString());
      print("Algorithm: " + currentAlgorithm);
    }
    var responseAddTotp = await api.createTotp(
        _secretController.text,
        _issuerController.text,
        currentAlgorithm,
        digits.toString(),
        period.toString(),
        globals.currentKundeID.toString(),
        context);
    if (responseAddTotp == "Created") {
      Navigator.pop(context);
    } else {
      context.showErrorBar(content: const Text("Error in Backend"));
    }
  }
}
