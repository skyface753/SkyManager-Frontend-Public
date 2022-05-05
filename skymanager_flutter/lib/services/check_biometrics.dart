// ignore_for_file: empty_catches

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> checkBiometrics(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool useBiometrics = prefs.getBool('useBiometrics') ?? false;

  if (useBiometrics) {
    try {
      var localAuth = LocalAuthentication();
      bool didAuthenticate = await localAuth.authenticate(
          localizedReason: 'Please authenticate to continue');
      if (didAuthenticate) {
      } else {
        Navigator.pushReplacementNamed(context, '/Login');
      }
    } catch (e) {}
  } else {}
}
