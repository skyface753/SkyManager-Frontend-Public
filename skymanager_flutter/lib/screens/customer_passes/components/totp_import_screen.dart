import 'dart:async';
import 'dart:io';

import 'package:flash/flash.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:skymanager/services/api_requests.dart' as api;

import 'package:skymanager/services/globals.dart' as globals;

class TOTPImportScreen extends StatefulWidget {
  const TOTPImportScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TOTPImportScreeenState();
}

class _TOTPImportScreeenState extends State<TOTPImportScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool correctData = false;

  String importUrl = "";

  late Timer _everySecond;

  @override
  void initState() {
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
        title: const Text("TOTP Import"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          correctData
              ? ElevatedButton(
                  onPressed: (() {
                    _importTotps();
                  }),
                  child: const Text("Add TOTP Key"))
              : Container(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  _parseURLFromBarcode() {
    if (describeEnum(result!.format) != "qrcode") {
      correctData = false;
      return false;
    }
    try {
      if (result!.code!.startsWith("otpauth-migration://offline?")) {
        importUrl = result!.code!;
        correctData = true;
        return true;
      }
    } catch (e) {
      correctData = false;
      return false;
    }
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

  _importTotps() async {
    if (importUrl == "") {
      return;
    }
    var response = await api.importTotps(
        globals.currentKundeID.toString(), importUrl, context);
    if (response == "Imported") {
      context.showSuccessBar(content: const Text("Import successful"));
      Navigator.pop(context);
      return;
    } else {
      context.showErrorBar(
          content: const Text("Import failed or not fully successful"));
      return;
    }
    // print(response);
  }
}
