enum HashAlgorithm {
  md5,
  sha1,
  sha256,
}

class Settings {
  final int passwordLength;
  final int pinLength;
  final HashAlgorithm hashAlgorithm;
  
  Settings({
    this.passwordLength: 10,
    this.pinLength: 4,
    this.hashAlgorithm: HashAlgorithm.md5,
  });
}
