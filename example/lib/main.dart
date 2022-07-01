import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:secure_enclave/secure_enclave.dart';

final _messangerKey = GlobalKey<ScaffoldMessengerState>();

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
  final String tagBiometric = "keychain-coinbit.privateKeyPresence";
  bool _isRequiresBiometric = false;

  TextEditingController input = TextEditingController();

  Uint8List encrypted = Uint8List(0);
  String decrypted = "";

  @override
  void initState() {
    super.initState();
  }

  void encrypt(String message){
    _secureEnclavePlugin.encrypt(_isRequiresBiometric ? tagBiometric : tag, message, _isRequiresBiometric).then((result) => setState((){
      if(result.error == null){
        encrypted = result.value ?? Uint8List(0);
      } else {
        final error = result.error!;
        _messangerKey.currentState?.showSnackBar(SnackBar(content: Text('code = ${error.code}  |  desc = ${error.desc}')));
      }
    }));
  }

  void decrypt(Uint8List message, bool isRequiresBiometric){
    _secureEnclavePlugin.decrypt(_isRequiresBiometric ? tagBiometric : tag, message, isRequiresBiometric).then((result) => setState((){
      if(result.error == null){
        decrypted = result.value ?? "";
      } else {
        final error = result.error!;
        _messangerKey.currentState?.showSnackBar(SnackBar(content: Text('code = ${error.code}  |  desc = ${error.desc}')));
      }
    }));
  }

  void getPublicKey(bool isRequiresBiometric){
    _secureEnclavePlugin.getPublicKey(tag, isRequiresBiometric).then((result){
      if(result.error == null){
        decrypted = result.value ?? "";
      } else {
        final error = result.error!;
        _messangerKey.currentState?.showSnackBar(SnackBar(content: Text('code = ${error.code}  |  desc = ${error.desc}')));
      }
    });
  }

  Future<void> removeKey() async {
    await _secureEnclavePlugin.removeKey(tag).then((result){
      print("delete $tag = ${result.value}");
    });
    await _secureEnclavePlugin.removeKey(tagBiometric).then((result){
      print("delete $tagBiometric = ${result.value}");
    });
  }

  void cobaError(){
    _secureEnclavePlugin.cobaError().then((result){
      if(result.error == null){
        print("Kok Sukses???");
      } else {
        final error = result.error!;
        _messangerKey.currentState?.showSnackBar(SnackBar(content: Text('code = ${error.code}  |  desc = ${error.desc}')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _messangerKey,
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
            TextButton(onPressed: (){
              removeKey();
            }, child: Text("reset key")),
            TextButton(onPressed: (){
              cobaError();
            }, child: Text("coba Error")),
          ],
        ),
      ),
    );
  }
}
