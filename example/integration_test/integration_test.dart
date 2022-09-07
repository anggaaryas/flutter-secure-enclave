import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:secure_enclave/secure_enclave.dart';

void main(){
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const String tagNormal = "app.privateKey";
  const String tagBiometric = "app.privateKey.biometric";
  const String tagPassword = "app.privateKey.password";
  const String tagPasswordBiometric = "app.privateKey.password.biometric";

  const String appPassword = "1234";


  group("Create all key", () {

    testWidgets("create Normal Key", (widgetTester) async {

      blankApp("Test create key");
      await widgetTester.pumpAndSettle();

      SecureEnclave secureEnclave = SecureEnclave();
      await secureEnclave.generateKeyPair(accessControl: AccessControlModel(tag: tagNormal, options: [AccessControlOption.privateKeyUsage])).then((result){
        checkResult(
            result: result,
            onSuccess: (){
              print('Tag Normal created...');
              expect(result.value, true);
            });
      });
    });

    testWidgets("create Biometry Key", (widgetTester) async {

      blankApp("Test create key");
      await widgetTester.pumpAndSettle();

      SecureEnclave secureEnclave = SecureEnclave();

      await secureEnclave.generateKeyPair(accessControl: AccessControlModel(tag: tagBiometric, options: [AccessControlOption.privateKeyUsage, AccessControlOption.biometryCurrentSet])).then((result){
        checkResult(
            result: result,
            onSuccess: (){
              print('Tag Biometry created...');
              expect(result.value, true);
            });
      });
    });

    testWidgets("create Password Key", (widgetTester) async {

      blankApp("Test create key");
      await widgetTester.pumpAndSettle();

      SecureEnclave secureEnclave = SecureEnclave();

      await secureEnclave.generateKeyPair(accessControl: AccessControlModel(tag: tagPassword, options: [AccessControlOption.privateKeyUsage, AccessControlOption.applicationPassword], password: appPassword)).then((result){
        checkResult(
            result: result,
            onSuccess: (){
              print('Tag Password created...');
              expect(result.value, true);
            });
      });
    });

    testWidgets("create Biometry Password Key", (widgetTester) async {

      blankApp("Test create key");
      await widgetTester.pumpAndSettle();

      SecureEnclave secureEnclave = SecureEnclave();

      await secureEnclave.generateKeyPair(accessControl: AccessControlModel(tag: tagPasswordBiometric, options: [AccessControlOption.privateKeyUsage, AccessControlOption.biometryCurrentSet, AccessControlOption.applicationPassword], password: appPassword)).then((result){
        checkResult(
            result: result,
            onSuccess: (){
              print('Tag Biometry Password created...');
              expect(result.value, true);
            });
      });

    });
  });

  group('Normal Encrypt Decrypt', () {
    const String cleartext = "Lorem Ipsum";
    Uint8List? encrypted;

    testWidgets('encrypt', (widgetTester) async {

      blankApp("Test normal encrypt...");
      await widgetTester.pumpAndSettle();

      SecureEnclave secureEnclave = SecureEnclave();
      await secureEnclave.encrypt(message: cleartext, tag: tagNormal).then((result){
        checkResult(result: result, onSuccess: (){
          encrypted = result.value;

          expect(encrypted != null, true);
          expect(encrypted!.isEmpty, false);
        });
      });
    });


    testWidgets("decrypt", (widgetTester) async{
      if(encrypted == null || encrypted!.isEmpty){
        throw("Encrypted Text null or empty. abort...");
      }

      blankApp("Test normal decrypt...");
      await widgetTester.pumpAndSettle();

      SecureEnclave secureEnclave = SecureEnclave();
      await secureEnclave.decrypt(message: encrypted!, tag: tagNormal).then((result) {
        checkResult(result: result, onSuccess: (){
          expect(result.value == cleartext, true);
        });
      });
    });

  });

  group('Biometry Encrypt Decrypt', () {
    const String cleartext = "Lorem Ipsum";
    Uint8List? encrypted;

    testWidgets('encrypt', (widgetTester) async {

      blankApp("Test biometry encrypt...");
      await widgetTester.pumpAndSettle();

      SecureEnclave secureEnclave = SecureEnclave();
      await secureEnclave.encrypt(message: cleartext, tag: tagBiometric).then((result){
        checkResult(result: result, onSuccess: (){
          encrypted = result.value;

          expect(encrypted != null, true);
          expect(encrypted!.isEmpty, false);
        });
      });
    });

    testWidgets("decrypt", (widgetTester) async{
      if(encrypted == null || encrypted!.isEmpty){
        throw("Encrypted Text null or empty. abort...");
      }

      blankApp("Test biometry decrypt...");
      await widgetTester.pumpAndSettle();

      SecureEnclave secureEnclave = SecureEnclave();
      await secureEnclave.decrypt(message: encrypted!, tag: tagBiometric).then((result) {
        checkResult(result: result, onSuccess: (){
          expect(result.value == cleartext, true);
        });
      });
    });

  });

  group('Password Encrypt Decrypt', () {
    const String cleartext = "Lorem Ipsum";
    Uint8List? encrypted;

    testWidgets('encrypt', (widgetTester) async {

      blankApp("Test password encrypt...");
      await widgetTester.pumpAndSettle();

      SecureEnclave secureEnclave = SecureEnclave();
      await secureEnclave.encrypt(message: cleartext, tag: tagPassword).then((result){
        checkResult(result: result, onSuccess: (){
          encrypted = result.value;

          expect(encrypted != null, true);
          expect(encrypted!.isEmpty, false);
        });
      });
    });


    testWidgets("decrypt", (widgetTester) async{
      if(encrypted == null || encrypted!.isEmpty){
        throw("Encrypted Text null or empty. abort...");
      }

      blankApp("Test password decrypt...");
      await widgetTester.pumpAndSettle();

      SecureEnclave secureEnclave = SecureEnclave();
      await secureEnclave.decrypt(message: encrypted!, tag: tagPassword).then((result) {
        checkResult(result: result, onSuccess: (){
          expect(result.value == cleartext, true);
        });
      });
    });

  });

  group('Biometry Password Encrypt Decrypt', () {
    const String cleartext = "Lorem Ipsum";
    Uint8List? encrypted;

    testWidgets('encrypt', (widgetTester) async {

      blankApp("Test biometry password encrypt...");
      await widgetTester.pumpAndSettle();

      SecureEnclave secureEnclave = SecureEnclave();
      await secureEnclave.encrypt(message: cleartext, tag: tagPasswordBiometric).then((result){
        checkResult(result: result, onSuccess: (){
          encrypted = result.value;

          expect(encrypted != null, true);
          expect(encrypted!.isEmpty, false);
        });
      });
    });


    testWidgets("decrypt", (widgetTester) async{
      if(encrypted == null || encrypted!.isEmpty){
        throw("Encrypted Text null or empty. abort...");
      }

      blankApp("Test biometry password decrypt...");
      await widgetTester.pumpAndSettle();

      SecureEnclave secureEnclave = SecureEnclave();
      await secureEnclave.decrypt(message: encrypted!, tag: tagPasswordBiometric).then((result) {
        checkResult(result: result, onSuccess: (){
          expect(result.value == cleartext, true);
        });
      });
    });

  });
}

void checkResult({required ResultModel result, required Function() onSuccess}) {
  if(result.error == null){
    onSuccess();
  } else {
    throw(result.error!.desc);
  }
}

void blankApp(String title){
  runApp(MaterialApp(
    home: Container(
      color: Colors.white,
      child: Center(
        child: Text(title, style: TextStyle(fontSize: 24),),
      ),
    ),
  ));
}