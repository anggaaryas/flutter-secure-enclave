# secure_enclave

Apple Secure Enclave implementaton for Flutter

# How to Use

Encrypt:

```dart
Uint8List encrypted = Uint8List(0);  

void encrypt(String message, bool isRequiresBiometric) {
  _secureEnclavePlugin
      .encrypt(
      message: message,
      accessControl: AccessControl(
        options: isRequiresBiometric
            ? SecureEnclave.defaultRequiredAuthForAccessControlOption
            : SecureEnclave.defaulAccessControlOption,
        tag: _isRequiresBiometric ? tagBiometric : tag,
      ))
      .then((result) => setState(() {
    if (result.error == null) {
      encrypted = result.value ?? Uint8List(0);
    } else {
      final error = result.error!;
      _messangerKey.currentState?.showSnackBar(SnackBar(
          content:
          Text('code = ${error.code}  |  desc = ${error.desc}')));
    }
  }));
}
```

decrypt:

```dart
String decrypted = "";

void decrypt(Uint8List message, bool isRequiresBiometric) {
  _secureEnclavePlugin.decrypt(
      message: message,
      accessControl: AccessControl(
        options: isRequiresBiometric
            ? SecureEnclave.defaultRequiredAuthForAccessControlOption
            : SecureEnclave.defaulAccessControlOption,
        tag: _isRequiresBiometric ? tagBiometric : tag,
      ))
      .then((result) => setState(() {
    if (result.error == null) {
      decrypted = result.value ?? "";
    } else {
      final error = result.error!;
      _messangerKey.currentState?.showSnackBar(SnackBar(
          content:
          Text('code = ${error.code}  |  desc = ${error.desc}')));
    }
  }));
}
```

get base64EncodedString public Key:

```dart
  String publicKey = "";

  void getPublicKey() {
    _secureEnclavePlugin.getPublicKey(
        accessControl: AccessControl(
            options: _isRequiresBiometric
                        ? SecureEnclave.defaultRequiredAuthForAccessControlOption
                        : SecureEnclave.defaulAccessControlOption,
            tag: _isRequiresBiometric ? tagBiometric : tag,
    )).then((result) {
      if (result.error == null) {
        publicKey = result.value ?? "";
      } else {
        final error = result.error!;
        _messangerKey.currentState?.showSnackBar(SnackBar(
            content: Text('code = ${error.code}  |  desc = ${error.desc}')));
      }
    });
  }
```

Encrypt and use custom base64EncodedString public Key:

be aware that the tag and the required public key is valid. Otherwise, it will throw error. For safety, use encrypt function without custom public key

```dart
  Uint8List encryptedWithPublicKey = Uint8List(0);

  void encryptWithPublicKey(String message, String publicKey) {
    _secureEnclavePlugin
        .encryptWithPublicKey(
            message: message,
            publicKeyString: publicKey
    ).then((result) => setState(() {
              if (result.error == null) {
                encryptedWithPublicKey = result.value ?? Uint8List(0);
              } else {
                final error = result.error!;
                _messangerKey.currentState?.showSnackBar(SnackBar(
                    content:
                        Text('code = ${error.code}  |  desc = ${error.desc}')));
              }
            }));
  }
```