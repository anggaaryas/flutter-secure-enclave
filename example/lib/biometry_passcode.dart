import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:secure_enclave/secure_enclave.dart';
import 'package:convert/convert.dart';

class BiometryPasscode extends StatefulWidget {
  const BiometryPasscode({Key? key}) : super(key: key);

  @override
  State<BiometryPasscode> createState() => _BiometryPasscodeState();
}

class _BiometryPasscodeState extends State<BiometryPasscode> {
  TextEditingController tag = TextEditingController();
  TextEditingController plainText = TextEditingController();
  TextEditingController plainText2 = TextEditingController();
  TextEditingController cipherText = TextEditingController();

  final _secureEnclavePlugin = SecureEnclave();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometry / Passcode'),
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
            ElevatedButton(
              onPressed: () async {
                if (tag.text.isNotEmpty && plainText.text.isNotEmpty) {
                  try {
                    /// check if tag already on keychain
                    final bool status = (await _secureEnclavePlugin
                                .getStatusSecKey(tag: tag.text))
                            .value ??
                        false;

                    if (status == false) {
                      /// create key on keychain
                      await _secureEnclavePlugin.generateKeyPair(
                        accessControl: AccessControlModel(
                          options: [
                            AccessControlOption.userPresence,
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
                            ))
                                .value ??
                            Uint8List.fromList([]);
                    cipherText.text = hex.encode(cipherUint8List).toString();
                    setState(() {});
                  } catch (e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(e.toString())));
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
                        ))
                            .value ??
                        '';
                    plainText2.text = plain;
                    setState(() {});
                  } catch (e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(e.toString())));
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
