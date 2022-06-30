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
  final String tag = "keychain-coinbit.privateKey";
  final String tagBiometric = "keychain-coinbit.privateKeyBio";
  bool _isRequiresBiometric = false;

  TextEditingController input = TextEditingController();

  Uint8List encrypted = Uint8List(0);
  String decrypted = "";

  @override
  void initState() {
    super.initState();
  }

  void encrypt(String message){
    _secureEnclavePlugin.encrypt(_isRequiresBiometric ? tagBiometric : tag, message, _isRequiresBiometric).then((value) => setState((){
      encrypted = value ?? Uint8List(0);
    }));
  }

  void decrypt(Uint8List message, bool isRequiresBiometric){
    _secureEnclavePlugin.decrypt(_isRequiresBiometric ? tagBiometric : tag, message, isRequiresBiometric).then((value) => setState((){
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
            Row(
              children: [
                const Text("Biometric"),
                const SizedBox(width: 10,),
                Switch(value: _isRequiresBiometric, onChanged: (value){
                  setState(() {
                    _isRequiresBiometric = value;
                    encrypted = Uint8List(0);
                    decrypted = "";
                  });
                }),
              ],
            ),
             TextButton(onPressed: (){
               encrypt(input.text);
               // input.clear();
             }, child: Text("encrypt!")),
             Text(
                 encrypted.toString()
            ),
            TextButton(onPressed: (){
              decrypt(encrypted, _isRequiresBiometric);
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
