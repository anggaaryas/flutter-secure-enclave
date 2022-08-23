import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:secure_enclave/secure_enclave.dart';
import 'package:convert/convert.dart';

class AppPassword extends StatefulWidget {
  const AppPassword({Key? key}) : super(key: key);

  @override
  State<AppPassword> createState() => _AppPasswordState();
}

class _AppPasswordState extends State<AppPassword> {
  TextEditingController tag = TextEditingController();
  TextEditingController plainText = TextEditingController();
  TextEditingController plainText2 = TextEditingController();
  TextEditingController appPassword = TextEditingController();
  TextEditingController cipherText = TextEditingController();

  final _secureEnclavePlugin = SecureEnclave();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tag'),
                const SizedBox(
                  height: 5,
                ),
                TextField(
                  controller: tag,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Plain Text'),
                const SizedBox(
                  height: 5,
                ),
                TextField(
                  controller: plainText,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Password'),
                const SizedBox(
                  height: 5,
                ),
                TextField(
                  controller: appPassword,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                if (tag.text.isNotEmpty &&
                    plainText.text.isNotEmpty &&
                    appPassword.text.isNotEmpty) {
                  try {
                    /// check if tag already on keychain
                    final bool status = (await _secureEnclavePlugin
                                .getStatusSecKey(tag: tag.text))
                            .value ??
                        false;

                    if (status == false) {
                      /// create key on keychain
                      await _secureEnclavePlugin.createKey(
                        accessControl: AppPasswordAccessControl(
                          password: appPassword.text,
                          options: [
                            AccessControlOption.applicationPassword,
                            AccessControlOption.privateKeyUsage,
                          ],
                          tag: tag.text,
                        ),
                      );
                    }

                    /// encrypt with app password
                    Uint8List cipherUint8List =
                        (await _secureEnclavePlugin.encrypt(
                              message: plainText.text,
                              tag: tag.text,
                              password: appPassword.text,
                            ))
                                .value ??
                            Uint8List.fromList([]);
                    cipherText.text = hex.encode(cipherUint8List).toString();
                    setState(() {});
                  } catch (e) {
                    log(e.toString());
                  }
                }
              },
              child: const Text('Encrypt'),
            ),
            const SizedBox(
              height: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cipher Text (Hex)'),
                const SizedBox(
                  height: 5,
                ),
                TextField(
                  controller: cipherText,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                if (cipherText.text.isNotEmpty) {
                  try {
                    /// decrypt with app password
                    String plain = (await _secureEnclavePlugin.decrypt(
                          message:
                              Uint8List.fromList(hex.decode(cipherText.text)),
                          tag: tag.text,
                          password: appPassword.text,
                        ))
                            .value ??
                        '';
                    plainText2.text = plain;
                    setState(() {});
                  } catch (e) {
                    log(e.toString());
                  }
                }
              },
              child: const Text('Decrypt'),
            ),
            const SizedBox(
              height: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Plain Text'),
                const SizedBox(
                  height: 5,
                ),
                TextField(
                  controller: plainText2,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
