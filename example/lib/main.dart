import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:secure_enclave/secure_enclave.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _secureEnclavePlugin = SecureEnclave();
  final tag = "TEST_APP_TAG";

  TextEditingController input = TextEditingController();

  Uint8List encrypted = Uint8List(0);
  String decrypted = "";

  @override
  void initState() {
    super.initState();
  }

  void encrypt(String message){
    _secureEnclavePlugin.encrypt(tag, message).then((value) => setState((){
      encrypted = value ?? Uint8List(0);
    }));
  }

  void decrypt(Uint8List message){
    _secureEnclavePlugin.decrypt(tag, message).then((value) => setState((){
      decrypted = value ?? "";
    }));
  }

  void getPublicKey(){
    _secureEnclavePlugin.getPublicKey(tag).then((value) => print("publick key   =   $value"));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            TextField(
              controller: input,
            ),
             TextButton(onPressed: (){
               encrypt(input.text);
               // input.clear();
             }, child: Text("encrypt!")),
             Text(
                 encrypted.toString()
            ),
            TextButton(onPressed: (){
              decrypt(encrypted);
            }, child: Text("decrypt!")),
            Text(
                decrypted
            ),

          ],
        ),
      ),
    );
  }
}
