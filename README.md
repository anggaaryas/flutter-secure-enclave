# secure_enclave

Apple Secure Enclave implementaton for Flutter

# How to Use

Encrypt:

```dart
Uint8List encrypted = Uint8List(0);
String tag = "SOME-TAG";
String message = "Hello World";
SecureEnclavePlugin.encrypt(tag, message).then((value) => encrypted = value ?? Uint8List(0));
```

decrypt:

```dart
Uint8List encrypted = ...; // some Unit8
String tag = "SOME-TAG";
String clearText = "";
SecureEnclavePlugin.decrypt(tag, encrypted).then((value) => clearText = value ?? "");
```
