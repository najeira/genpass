import 'package:flutter_test/flutter_test.dart';

import 'package:genpass/domain/hash_algorithm.dart';
import 'package:genpass/domain/settings.dart';

void main() {
  testSettingsEncode();
  testSettingsDecode();
}

void testSettingsEncode() {
  test("Settings encode one", () {
    final Settings ss = Settings(<Setting>[
      Setting(
        passwordLength: 10,
        pinLength: 4,
        hashAlgorithm: HashAlgorithm.md5,
      ),
    ]);
    final String str = Settings.encode(ss);
    expect(str, '[{"passwordLength":10,"pinLength":4,"hashAlgorithm":"md5"}]');
  });
}

void testSettingsDecode() {
  test("Settings decode one", () {
    final Settings ss = Settings.decode('[{"passwordLength":10,"pinLength":4,"hashAlgorithm":"md5"}]');
    expect(ss?.items?.length, 1);
    expect(ss?.items?.first?.passwordLength, 10);
    expect(ss?.items?.first?.pinLength, 4);
    expect(ss?.items?.first?.hashAlgorithm, HashAlgorithm.md5);
  });
  test("Settings decode null", () {
    final Settings ss = Settings.decode(null);
    expect(ss?.items?.length, 1);
  });
  test("Settings decode empty string", () {
    final Settings ss = Settings.decode("");
    expect(ss?.items?.length, 1);
  });
}
