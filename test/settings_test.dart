import 'package:flutter_test/flutter_test.dart';

import 'package:genpass/domain/hash_algorithm.dart';
import 'package:genpass/domain/settings.dart';

void main() {
  testSettingsEncode();
  testSettingsDecode();
}

void testSettingsEncode() {
  test("Settings encode one", () {
    final items = <Setting>[
      const Setting(
        passwordLength: 10,
        pinLength: 4,
        hashAlgorithm: HashAlgorithm.md5,
      ),
    ];
    final str = SettingList.encode(items);
    expect(str, '[{"passwordLength":10,"pinLength":4,"hashAlgorithm":"md5"}]');
  });
}

void testSettingsDecode() {
  test("Settings decode one", () {
    final ss = SettingList.decode(
        '[{"passwordLength":10,"pinLength":4,"hashAlgorithm":"md5"}]');
    expect(ss.length, 1);
    expect(ss.first.passwordLength, 10);
    expect(ss.first.pinLength, 4);
    expect(ss.first.hashAlgorithm, HashAlgorithm.md5);
  });
  test("Settings decode null", () {
    final ss = SettingList.decode(null);
    expect(ss.length, 1);
  });
  test("Settings decode empty string", () {
    final ss = SettingList.decode("");
    expect(ss.length, 1);
  });
}
