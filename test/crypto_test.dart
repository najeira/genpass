import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:genpass/domain/hash_algorithm.dart';
import 'package:genpass/service/crypto.dart';

class _CryptoTestCase {
  const _CryptoTestCase({
    this.expected,
    this.masterPassword,
    this.domainSite = "example.com",
    this.hashAlgorithm = HashAlgorithm.md5,
    this.length = 10,
  });

  final String expected;
  final String masterPassword;
  final String domainSite;
  final HashAlgorithm hashAlgorithm;
  final int length;
}

void main() {
  for (final _CryptoTestCase tc in testCases) {
    test("${tc.masterPassword} ${tc.domainSite} ${tc.hashAlgorithm} ${tc.length}", () {
      final String res = Crypto.generatePassword(
        tc.hashAlgorithm,
        tc.domainSite,
        tc.masterPassword,
        tc.length,
      );
      expect(res, tc.expected);
    });
  }
}

const testCases = <_CryptoTestCase>[
  const _CryptoTestCase(
    expected: "w9UbG0NEk7",
    masterPassword: "test",
  ),
  const _CryptoTestCase(
    expected: "sJfoZg3nU8",
    masterPassword: "test",
    domainSite: "example.com",
    hashAlgorithm: HashAlgorithm.sha512,
  ),
  const _CryptoTestCase(
    expected: "aC81",
    masterPassword: "test",
    domainSite: "example.com",
    hashAlgorithm: HashAlgorithm.sha512,
    length: 4,
  ),
  const _CryptoTestCase(
    expected: "vBKDNdjhhL6dBfgDSRxZxAAA",
    masterPassword: "test",
    domainSite: "example.com",
    hashAlgorithm: HashAlgorithm.md5,
    length: 24,
  ),
  const _CryptoTestCase(
    expected: "sJfoZg3nU8y32EyHFRlSY08u",
    masterPassword: "test",
    domainSite: "example.com",
    hashAlgorithm: HashAlgorithm.sha512,
    length: 24,
  ),
  const _CryptoTestCase(
    expected: "aRFG84Gim9",
    masterPassword: "test",
    domainSite: "example.co.uk",
  ),
  const _CryptoTestCase(
    expected: "hSF8nTst4A",
    masterPassword: "test",
    domainSite: "example.gov.ac",
  ),
  const _CryptoTestCase(
    expected: "ft8iv4t5sX",
    masterPassword: "Γαζέες καὶ μυρτιὲς δὲν θὰ βρῶ πιὰ στὸ χρυσαφὶ ξέφωτο",
  ),
  const _CryptoTestCase(
    expected: "o1AWdbILuJ",
    masterPassword: "Benjamín pidió una bebida de kiwi y fresa",
  ),
  const _CryptoTestCase(
    expected: 'iUL7ndPlsD',
    masterPassword: 'Árvíztűrő tükörfúrógép',
  ),
  const _CryptoTestCase(
    expected: 'fDOVXY6AhC',
    masterPassword: 'わかよたれそつねならむ',
  ),
  const _CryptoTestCase(
    expected: 'i4LtmfRGl8',
    masterPassword: 'ウヰノオクヤマ ケフコエテ',
  ),
  const _CryptoTestCase(
    expected: 'wD8T8KozGO',
    masterPassword: 'מצא לו חברה איך הקליטה',
  ),
  const _CryptoTestCase(
    expected: 'jtUcAzTL4l',
    masterPassword: 'В чащах юга жил бы цитрус? Да, но фальшивый экземпляр!',
  ),
  const _CryptoTestCase(
    expected: 'rnXePhv0JG',
    masterPassword: 'จงฝ่าฟันพัฒนาวิชาการ',
  ),
];
