// ID, secret, issuer, algorithm, digits, period, customer_fk
import 'package:otp/otp.dart';

class Totp {
  int id;
  String secret;
  String issuer;
  Algorithm algorithm;
  int digits;
  int period;
  int customerfk;

  Totp(this.id, this.secret, this.issuer, this.algorithm, this.digits,
      this.period, this.customerfk);

  Totp.fromJson(Map json)
      : id = json['ID'],
        secret = json['secret'],
        issuer = json['issuer'],
        algorithm = json['algorithm'] == 'SHA1'
            ? Algorithm.SHA1
            : json['algorithm'] == 'SHA256'
                ? Algorithm.SHA256
                : json['algorithm'] == 'SHA512'
                    ? Algorithm.SHA512
                    : Algorithm.SHA1,
        digits = json['digits'],
        period = json['period'],
        customerfk = json['customer_fk'];

  Map toJson() {
    return {
      'ID': id,
      'secret': secret,
      'issuer': issuer,
      'algorithm': algorithm == Algorithm.SHA1
          ? 'SHA1'
          : algorithm == Algorithm.SHA256
              ? 'SHA256'
              : algorithm == Algorithm.SHA512
                  ? 'SHA512'
                  : 'SHA1',
      'digits': digits,
      'period': period,
      'customer_fk': customerfk
    };
  }
}
