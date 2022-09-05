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
        actions: [
          IconButton(
              onPressed: () {
                _secureEnclavePlugin.removeKey(tag.text);
              },
              icon: const Icon(Icons.delete))
        ],
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
                    final bool status =
                        (await _secureEnclavePlugin.isKeyCreated(tag: tag.text))
                                .value ??
                            false;

                    if (status == false) {
                      /// create key on keychain
                      ResultModel res =
                          await _secureEnclavePlugin.generateKeyPair(
                        accessControl: AccessControlModel(
                          options: [
                            AccessControlOption.userPresence,
                            AccessControlOption.privateKeyUsage,
                          ],
                          tag: tag.text,
                        ),
                      );

                      if (res.error != null) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(res.error!.desc.toString())));
                      }
                    }

                    /// encrypt with app password
                    ResultModel cipherUint8List =
                        (await _secureEnclavePlugin.encrypt(
                      message: plainText.text,
                      tag: tag.text,
                    ));
                    if (cipherUint8List.value != null) {
                      cipherText.text =
                          hex.encode(cipherUint8List.value).toString();
                      setState(() {});
                    } else {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text(cipherUint8List.error!.desc.toString())));
                    }
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
                    ResultModel plain = (await _secureEnclavePlugin.decrypt(
                      message: Uint8List.fromList(hex.decode(cipherText.text)),
                      tag: tag.text,
                    ));
                    if (plain.value != null) {
                      plainText2.text = plain.value;
                      setState(() {});
                    } else {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(plain.error!.desc.toString())));
                    }
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
