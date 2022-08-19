# secure_enclave

Apple Secure Enclave implementaton for Flutter

# How to Use

Create Key:

```dart
  void createKey(AccessControl accessControl ){
    _secureEnclavePlugin.createKey(
        accessControl: accessControl
    ).then((result){
      if(result.error == null){
        // success
      } else {
        showError(result);
      }
    });
  }
```

Check Key:

```dart
  void checkKey(String tag){
    _secureEnclavePlugin.checkKey(tag).then((value){
      // value is true or false...
    });
  }
```

Encrypt:

```dart
Uint8List encrypted = Uint8List(0);

void encrypt(String message, String tag) {
  _secureEnclavePlugin.encrypt(
      message: message,
      tag: tag).then((result) => setState(() {
    if (result.error == null) {
      encrypted = result.value ?? Uint8List(0);
    } else {
      showError(result);
    }
  }));
}
```

decrypt:

```dart
String decrypted = "";

void decrypt(Uint8List message, String tag, String? password) {
  _secureEnclavePlugin.decrypt(
      message: message,
      tag: tag,
      password: password).then((result) => setState(() {
    if (result.error == null) {
      decrypted = result.value ?? "";
    } else {
      showError(result);
    }
  }));
}
```

get base64EncodedString public Key:

```dart
  String publicKey = "";

void getPublicKey(String tag) {
  _secureEnclavePlugin.getPublicKey(tag: tag).then((result) {
    if (result.error == null) {
      publicKey = result.value ?? "";
    } else {
      showError(result);
    }
  });
}
```

Encrypt and use custom base64EncodedString public Key:

be aware that the tag and the required public key is valid. Otherwise, it will throw error. For safety, use encrypt function without custom public key

```dart
  Uint8List encryptedWithPublicKey = Uint8List(0);

void encryptWithPublicKey(String message) {
  _secureEnclavePlugin.encryptWithPublicKey(
      message: message,
      publicKeyString: publicKey).then((result) => setState(() {
    if (result.error == null) {
      encryptedWithPublicKey = result.value ?? Uint8List(0);
    } else {
      showError(result);
    }
  }));
}
```