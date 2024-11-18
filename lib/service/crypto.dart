import 'dart:convert' show base64, utf8;
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;

import '../domain/hash_algorithm.dart';

class Crypto {
  factory Crypto._() {
    throw UnsupportedError("Not supported");
  }

  // Super Gen Pass Algorithm
  static String generatePassword(HashAlgorithm algo, String domain, String password, int length) {
    var hash = crypto.md5;
    switch (algo) {
      case HashAlgorithm.md5:
        hash = crypto.md5;
      case HashAlgorithm.sha512:
        hash = crypto.sha512;
    }
    const secret = "";
    final targetText = "${password}${secret}:${domain}";
    final generated = _hashRound(targetText, length, hash, 10);
    return generated;
  }

  static String _hashRound(String input, int length, crypto.Hash hash, int round) {
    var generated = input;
    while (round > 0 || !_validatePassword(generated, length)) {
      // ignore: parameter_assignments
      round--;
      generated = _hashPassword(generated, hash);
    }
    return generated.substring(0, length);
  }

  static String _hashPassword(String input, crypto.Hash hash) {
    final bytes = utf8.encode(input);
    final digest = hash.convert(bytes);
    var output = base64.encode(digest.bytes);
    output = output.replaceAll(r"+", r"9");
    output = output.replaceAll(r"/", r"8");
    output = output.replaceAll(r"=", r"A");
    return output;
  }

  static bool _validatePassword(String value, int length) {
    final substr = value.substring(0, length);
    if (!substr.startsWith(RegExp(r"[a-z]"))) {
      return false;
    } else if (!substr.contains(RegExp(r"[A-Z]"))) {
      return false;
    } else if (!substr.contains(RegExp(r"[0-9]"))) {
      return false;
    }
    return true;
  }

  static String generatePin(String domain, String password, int length) {
    var pin = _generateOtp(domain, password, length);
    var suffix = 0;
    var loopOverrun = 0;
    while (!_validatePin(pin)) {
      final suffixedDomain = "${domain} ${suffix.toString()}";
      pin = _generateOtp(suffixedDomain, password, length);
      loopOverrun++;
      suffix++;
      if (loopOverrun > 100) {
        return "";
      }
    }
    return pin;
  }

  // OATH HOTP Algorithm
  static String _generateOtp(String domain, String secret, int length) {
    final hmac = crypto.Hmac(crypto.sha1, secret.codeUnits);
    final digest = hmac.convert(domain.codeUnits);
    final hash = digest.bytes;
    final offset = hash[hash.length - 1] & 0xf;
    final binary = ((hash[offset] & 0x7f) << 24) |
        ((hash[offset + 1] & 0xff) << 16) |
        ((hash[offset + 2] & 0xff) << 8) |
        (hash[offset + 3] & 0xff);
    final otp = binary % _digitsPower[length];
    var result = otp.toString();
    while (result.length < length) {
      // ignore: prefer_interpolation_to_compose_strings
      result = "0" + result;
    }
    return result;
  }

  static bool _validatePin(String pin) {
    if (pin.length == 4) {
      final start = int.parse(pin.substring(0, 2));
      final end = int.parse(pin.substring(2, 4));
      if (start == 19 || (start == 20 && end < 30)) {
        // 19xx pins look like years, so might as well ditch them.
        return false;
      } else if (start == end) {
        return false;
      }
    }

    if (pin.length % 2 == 0) {
      var paired = true;
      for (var i = 0; i < pin.length - 1; i += 2) {
        if (pin.codeUnitAt(i) != pin.codeUnitAt(i + 1)) {
          paired = false;
        }
      }
      if (paired) {
        return false;
      }
    }

    if (_isNumericalRun(pin)) {
      return false;
    } else if (_isIncompleteNumericalRun(pin)) {
      return false;
    } else if (_blacklistedPins.contains(pin)) {
      return false;
    }
    return true;
  }

  static bool _isNumericalRun(String pin) {
    var prevDigit = int.parse(pin[0]);
    var prevDiff = 0x7FFFFFFF;
    var isRun = true; // assume it's true...
    for (var i = 1; isRun && i < pin.length; i++) {
      final digit = int.parse(pin[i]);
      final diff = digit - prevDigit;
      if (prevDiff != 0x7FFFFFFF && diff != prevDiff) {
        isRun = false; // ... and prove it's false
      }
      prevDiff = diff;
      prevDigit = digit;
    }
    return isRun;
  }

  static bool _isIncompleteNumericalRun(String pin) {
    var consecutive = 0;
    var last = pin.codeUnitAt(0);
    for (var i = 1; i < pin.length; i++) {
      final c = pin.codeUnitAt(i);
      if (last == c) {
        consecutive++;
      } else {
        consecutive = 0;
      }
      last = c;
      if (consecutive >= 2) {
        return true;
      }
    }
    return false;
  }

  static const List<int> _digitsPower = [
    1,
    10,
    100,
    1000,
    10000,
    100000,
    1000000,
    10000000,
    100000000,
    1000000000,
    10000000000
  ];

  static const List<String> _blacklistedPins = <String>[
    "90210", "8675309" /* Jenny */, "1004" /* 10-4 */,
    // in this document http://www.datagenetics.com/blog/september32012/index.html
    // these were shown to be the least commonly used. Now they won't be used at all.
    "8068", "8093", "9629", "6835", "7637", "0738", "8398",
    "6793", "9480", "8957", "0859", "7394", "6827", "6093",
    "7063", "8196", "9539", "0439", "8438", "9047", "8557",
  ];

  static int checksum(String password) {
    final bytes = utf8.encode(password);
    final result = _number(bytes);
    return result;
  }

  /// Gets unsiged integer of [bitLength]-bit from the message digest.
  static int _number(Uint8List bytes) {
    const bitLength = 64 >>> 3;
    int result = 0;
    int n = bytes.length;
    for (int i = n > bitLength ? n - bitLength : 0; i < n; i++) {
      result <<= 8;
      result |= bytes[i];
    }
    return result;
  }
}
