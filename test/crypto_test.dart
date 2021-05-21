import 'package:flutter_test/flutter_test.dart';

import 'package:genpass/domain/hash_algorithm.dart';
import 'package:genpass/service/crypto.dart';

class _CryptoTestCase {
  const _CryptoTestCase({
    required this.expected,
    required this.masterPassword,
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
  for (final tc in testCases) {
    test(
        "${tc.masterPassword} ${tc.domainSite} ${tc.hashAlgorithm} ${tc.length}",
        () {
      final res = Crypto.generatePassword(
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
  _CryptoTestCase(
    expected: "w9UbG0NEk7",
    masterPassword: "test",
  ),
  _CryptoTestCase(
    expected: "sJfoZg3nU8",
    masterPassword: "test",
    domainSite: "example.com",
    hashAlgorithm: HashAlgorithm.sha512,
  ),
  _CryptoTestCase(
    expected: "aC81",
    masterPassword: "test",
    domainSite: "example.com",
    hashAlgorithm: HashAlgorithm.sha512,
    length: 4,
  ),
  _CryptoTestCase(
    expected: "vBKDNdjhhL6dBfgDSRxZxAAA",
    masterPassword: "test",
    domainSite: "example.com",
    hashAlgorithm: HashAlgorithm.md5,
    length: 24,
  ),
  _CryptoTestCase(
    expected: "sJfoZg3nU8y32EyHFRlSY08u",
    masterPassword: "test",
    domainSite: "example.com",
    hashAlgorithm: HashAlgorithm.sha512,
    length: 24,
  ),
  _CryptoTestCase(
    expected: "aRFG84Gim9",
    masterPassword: "test",
    domainSite: "example.co.uk",
  ),
  _CryptoTestCase(
    expected: "hSF8nTst4A",
    masterPassword: "test",
    domainSite: "example.gov.ac",
  ),
  _CryptoTestCase(
    expected: "ft8iv4t5sX",
    masterPassword: "Γαζέες καὶ μυρτιὲς δὲν θὰ βρῶ πιὰ στὸ χρυσαφὶ ξέφωτο",
  ),
  _CryptoTestCase(
    expected: "o1AWdbILuJ",
    masterPassword: "Benjamín pidió una bebida de kiwi y fresa",
  ),
  _CryptoTestCase(
    expected: 'iUL7ndPlsD',
    masterPassword: 'Árvíztűrő tükörfúrógép',
  ),
  _CryptoTestCase(
    expected: 'fDOVXY6AhC',
    masterPassword: 'わかよたれそつねならむ',
  ),
  _CryptoTestCase(
    expected: 'i4LtmfRGl8',
    masterPassword: 'ウヰノオクヤマ ケフコエテ',
  ),
  _CryptoTestCase(
    expected: 'wD8T8KozGO',
    masterPassword: 'מצא לו חברה איך הקליטה',
  ),
  _CryptoTestCase(
    expected: 'jtUcAzTL4l',
    masterPassword: 'В чащах юга жил бы цитрус? Да, но фальшивый экземпляр!',
  ),
  _CryptoTestCase(
    expected: 'rnXePhv0JG',
    masterPassword: 'จงฝ่าฟันพัฒนาวิชาการ',
  ),
];
