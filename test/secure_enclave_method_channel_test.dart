// import 'package:flutter/services.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:secure_enclave/backup/secure_enclave.dart';
// import 'package:secure_enclave/src/secure_enclave_method_channel.dart';

// void main() {
//   MethodChannelSecureEnclave platform = MethodChannelSecureEnclave();
//   const MethodChannel channel = MethodChannel('secure_enclave');

//   TestWidgetsFlutterBinding.ensureInitialized();

//   setUp(() {
//     channel.setMockMethodCallHandler((MethodCall methodCall) async {
//       return '42';
//     });
//   });

//   tearDown(() {
//     channel.setMockMethodCallHandler(null);
//   });

//   test('test AppPassword', () async {
//     AccessControl accessControl =  AppPasswordAccessControl(
//       password: "aaaa",
//       options: [],
//       tag: "coba"
//     );

//     print(accessControl.toJson());
//     expect(accessControl.tag, "coba");
//   });
// }
