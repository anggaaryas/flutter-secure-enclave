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

  group('reset key', () {

    testWidgets('normal key', (widgetTester) async{

      blankApp('Test delete normal key');
      await widgetTester.pumpAndSettle();

      SecureEnclave secureEnclave = SecureEnclave();
      await secureEnclave.removeKey(tagNormal).then((result){

      });
    });

    testWidgets('biometry key', (widgetTester) async{

      blankApp('Test delete biometry key');
      await widgetTester.pumpAndSettle();

      SecureEnclave secureEnclave = SecureEnclave();
      await secureEnclave.removeKey(tagBiometric).then((result){

      });
    });

    testWidgets('password key', (widgetTester) async{

      blankApp('Test delete password key');
      await widgetTester.pumpAndSettle();

      SecureEnclave secureEnclave = SecureEnclave();
      await secureEnclave.removeKey(tagPassword).then((result){

      });
    });

    testWidgets('biometry password key', (widgetTester) async{

      blankApp('Test delete biometry password key');
      await widgetTester.pumpAndSettle();

      SecureEnclave secureEnclave = SecureEnclave();
      await secureEnclave.removeKey(tagPasswordBiometric).then((result){

      });
    });

  });


  group("Create all key", () {

    testWidgets("create Normal Key", (widgetTester) async {

      blankApp("Test create normal key");
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

      blankApp("Test create biometry key");
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

      blankApp("Test create password key");
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

      blankApp("Test create biometry password key");
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

  group('encrypt - decrypt', () {

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
        await secureEnclave.decrypt(message: encrypted!, tag: tagPasswordBiometric, password: appPassword).then((result) {
          checkResult(result: result, onSuccess: (){
            expect(result.value == cleartext, true);
          });
        });
      });

      testWidgets("decrypt wrong password", (widgetTester) async{
        if(encrypted == null || encrypted!.isEmpty){
          throw("Encrypted Text null or empty. abort...");
        }

        blankApp("Test biometry password decrypt...");
        await widgetTester.pumpAndSettle();

        SecureEnclave secureEnclave = SecureEnclave();
        await secureEnclave.decrypt(message: encrypted!, tag: tagPasswordBiometric, password: '9900').then((result) {
          checkResult(result: result, onSuccess: (){
            throw('decrypt should fail...');
          },);
        });
      });

    });

  });

  group("signing - verify", () {

    group('normal signing verify', () {

      const clearText = "Lorem Ipsum";
      String? signature;

      testWidgets('sign', (widgetTester) async{

        blankApp("Test normal signing");
        await widgetTester.pumpAndSettle();

        SecureEnclave secureEnclave = SecureEnclave();
        await secureEnclave.sign(message: Uint8List.fromList(clearText.codeUnits), tag: tagNormal).then((result){
          checkResult(result: result, onSuccess: (){
            signature = result.value;
            expect(signature != null, true);
            expect(signature!.isEmpty, false);
          });
        });
      });

      testWidgets('verify', (widgetTester) async{

        if(signature == null || signature!.isEmpty){
          throw('signature null or empty. abort...');
        }

        blankApp('Test normal verify');
        await widgetTester.pumpAndSettle();

        SecureEnclave secureEnclave = SecureEnclave();
        await secureEnclave.verify(plainText: clearText, signature: signature!, tag: tagNormal).then((result) async{
          checkResult(result: result, onSuccess: (){
            expect(result.value, true);
          });
        });
      });

      testWidgets('verify wrong', (widgetTester) async{

        if(signature == null || signature!.isEmpty){
          throw('signature null or empty. abort...');
        }

        blankApp('Test normal verify wrong');
        await widgetTester.pumpAndSettle();

        SecureEnclave secureEnclave = SecureEnclave();
        await secureEnclave.verify(plainText: 'asdfghjkl', signature: signature!, tag: tagNormal).then((result) async{
          checkResult(result: result, onSuccess: (){
            expect(result.value, false);
          });
        });
      });
    });

    group('biometry signing verify', () {

      const clearText = "Lorem Ipsum";
      String? signature;

      testWidgets('sign', (widgetTester) async{

        blankApp("Test biometry signing");
        await widgetTester.pumpAndSettle();

        SecureEnclave secureEnclave = SecureEnclave();
        await secureEnclave.sign(message: Uint8List.fromList(clearText.codeUnits), tag: tagBiometric).then((result){
          checkResult(result: result, onSuccess: (){
            signature = result.value;
            expect(signature != null, true);
            expect(signature!.isEmpty, false);
          });
        });
      });

      testWidgets('verify', (widgetTester) async{

        if(signature == null || signature!.isEmpty){
          throw('signature null or empty. abort...');
        }

        blankApp('Test biometry verify');
        await widgetTester.pumpAndSettle();

        SecureEnclave secureEnclave = SecureEnclave();
        await secureEnclave.verify(plainText: clearText, signature: signature!, tag: tagBiometric).then((result) async{
          checkResult(result: result, onSuccess: (){
            expect(result.value, true);
          });
        });
      });

      testWidgets('verify wrong', (widgetTester) async{

        if(signature == null || signature!.isEmpty){
          throw('signature null or empty. abort...');
        }

        blankApp('Test biometry verify wrong');
        await widgetTester.pumpAndSettle();

        SecureEnclave secureEnclave = SecureEnclave();
        await secureEnclave.verify(plainText: 'asdfghjkl', signature: signature!, tag: tagBiometric).then((result) async{
          checkResult(result: result, onSuccess: (){
            expect(result.value, false);
          });
        });
      });
    });

    group('password signing verify', () {

      const clearText = "Lorem Ipsum";
      String? signature;

      testWidgets('sign', (widgetTester) async{

        blankApp("Test password signing");
        await widgetTester.pumpAndSettle();

        SecureEnclave secureEnclave = SecureEnclave();
        await secureEnclave.sign(message: Uint8List.fromList(clearText.codeUnits), tag: tagPassword, password: appPassword).then((result){
          checkResult(result: result, onSuccess: (){
            signature = result.value;
            expect(signature != null, true);
            expect(signature!.isEmpty, false);
          });
        });
      });

      testWidgets('sign wrong password', (widgetTester) async{

        blankApp("Test wrong password signing");
        await widgetTester.pumpAndSettle();

        SecureEnclave secureEnclave = SecureEnclave();
        await secureEnclave.sign(message: Uint8List.fromList(clearText.codeUnits), tag: tagPassword, password: '9900').then((result){
          checkResult(result: result, onSuccess: (){
            throw('signing should fail...');
          });
        });
      });

      testWidgets('verify', (widgetTester) async{

        if(signature == null || signature!.isEmpty){
          throw('signature null or empty. abort...');
        }

        blankApp('Test password verify');
        await widgetTester.pumpAndSettle();

        SecureEnclave secureEnclave = SecureEnclave();
        await secureEnclave.verify(plainText: clearText, signature: signature!, tag: tagPassword, ).then((result) async{
          checkResult(result: result, onSuccess: (){
            expect(result.value, true);
          });
        });
      });

      testWidgets('verify wrong', (widgetTester) async{

        if(signature == null || signature!.isEmpty){
          throw('signature null or empty. abort...');
        }

        blankApp('Test password verify wrong');
        await widgetTester.pumpAndSettle();

        SecureEnclave secureEnclave = SecureEnclave();
        await secureEnclave.verify(plainText: 'asdfghjkl', signature: signature!, tag: tagPassword,).then((result) async{
          checkResult(result: result, onSuccess: (){
            expect(result.value, false);
          });
        });
      });
    });

    group('biometry password signing verify', () {

      const clearText = "Lorem Ipsum";
      String? signature;

      testWidgets('sign', (widgetTester) async{

        blankApp("Test biometry password signing");
        await widgetTester.pumpAndSettle();

        SecureEnclave secureEnclave = SecureEnclave();
        await secureEnclave.sign(message: Uint8List.fromList(clearText.codeUnits), tag: tagPasswordBiometric, password: appPassword).then((result){
          checkResult(result: result, onSuccess: (){
            signature = result.value;
            expect(signature != null, true);
            expect(signature!.isEmpty, false);
          });
        });
      });

      testWidgets('sign wrong password', (widgetTester) async{

        blankApp("Test biometry wrong password signing");
        await widgetTester.pumpAndSettle();

        SecureEnclave secureEnclave = SecureEnclave();
        await secureEnclave.sign(message: Uint8List.fromList(clearText.codeUnits), tag: tagPasswordBiometric, password: '9900').then((result){
          checkResult(result: result, onSuccess: (){
            throw('signing should fail...');
          });
        });
      });

      testWidgets('verify', (widgetTester) async{

        if(signature == null || signature!.isEmpty){
          throw('signature null or empty. abort...');
        }

        blankApp('Test biometry password verify');
        await widgetTester.pumpAndSettle();

        SecureEnclave secureEnclave = SecureEnclave();
        await secureEnclave.verify(plainText: clearText, signature: signature!, tag: tagPasswordBiometric,).then((result) async{
          checkResult(result: result, onSuccess: (){
            expect(result.value, true);
          });
        });
      });

      testWidgets('verify wrong', (widgetTester) async{

        if(signature == null || signature!.isEmpty){
          throw('signature null or empty. abort...');
        }

        blankApp('Test biometry password verify wrong');
        await widgetTester.pumpAndSettle();

        SecureEnclave secureEnclave = SecureEnclave();
        await secureEnclave.verify(plainText: 'asdfghjkl', signature: signature!, tag: tagPasswordBiometric).then((result) async{
          checkResult(result: result, onSuccess: (){
            expect(result.value, false);
          });
        });
      });

    });

  });


  group('delete key', () {

    testWidgets('normal key', (widgetTester) async{

      blankApp('Test delete normal key');
      await widgetTester.pumpAndSettle();

      SecureEnclave secureEnclave = SecureEnclave();
      await secureEnclave.removeKey(tagNormal).then((result){
        checkResult(result: result, onSuccess: (){
          expect(result.value, true);
        });
      });
    });

    testWidgets('biometry key', (widgetTester) async{

      blankApp('Test delete biometry key');
      await widgetTester.pumpAndSettle();

      SecureEnclave secureEnclave = SecureEnclave();
      await secureEnclave.removeKey(tagBiometric).then((result){
        checkResult(result: result, onSuccess: (){
          expect(result.value, true);
        });
      });
    });

    testWidgets('password key', (widgetTester) async{

      blankApp('Test delete password key');
      await widgetTester.pumpAndSettle();

      SecureEnclave secureEnclave = SecureEnclave();
      await secureEnclave.removeKey(tagPassword).then((result){
        checkResult(result: result, onSuccess: (){
          expect(result.value, true);
        });
      });
    });

    testWidgets('biometry password key', (widgetTester) async{

      blankApp('Test delete biometry password key');
      await widgetTester.pumpAndSettle();

      SecureEnclave secureEnclave = SecureEnclave();
      await secureEnclave.removeKey(tagPasswordBiometric).then((result){
        checkResult(result: result, onSuccess: (){
          expect(result.value, true);
        });
      });
    });

    testWidgets('unknown key', (widgetTester) async{

      blankApp('Test delete unknown key');
      await widgetTester.pumpAndSettle();

      SecureEnclave secureEnclave = SecureEnclave();
      await secureEnclave.removeKey('adasdasdasdasdas').then((result){
        checkResult(result: result, onSuccess: (){
          expect(result.value, false);
        });
      });
    });

  });
}

void checkResult({required ResultModel result, required Function() onSuccess, Function()? onFail}) {
  if(result.error == null){
    onSuccess();
  } else {
    if(onFail == null) {
      throw(result.error!.desc);
    } else {
      onFail.call();
    }
  }
}

void blankApp(String title){
  runApp(MaterialApp(
    home: Scaffold(
      backgroundColor: Colors.white,
      body:  Center(
        child: Text(title, style: TextStyle(fontSize: 24),),
      ),
    ),
  ));
}