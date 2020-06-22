enum HashAlgorithm {
  md5,
  sha512,
}

extension HashAlgorithmStringer on HashAlgorithm {
  String get name {
    switch (this) {
      case HashAlgorithm.md5:
        return "md5";
      case HashAlgorithm.sha512:
        return "sha512";
    }
    return null;
  }
}

extension HashAlgorithmFactory on HashAlgorithm {
  static HashAlgorithm fromName(String name) {
    switch (name) {
      case "md5":
        return HashAlgorithm.md5;
      case "sha512":
        return HashAlgorithm.sha512;
    }
    return null;
  }
}
