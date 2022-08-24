import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:secure_enclave/secure_enclave.dart';
import 'package:convert/convert.dart';

class AppPasswordBiometry extends StatefulWidget {
  const AppPasswordBiometry({Key? key}) : super(key: key);

  @override
  State<AppPasswordBiometry> createState() => _AppPasswordBiometryState();
}

class _AppPasswordBiometryState extends State<AppPasswordBiometry> {
  TextEditingController tag = TextEditingController();
  TextEditingController plainText = TextEditingController();
  TextEditingController plainTextAppPassword = TextEditingController();
  TextEditingController plainTextBiometry = TextEditingController();
  TextEditingController appPassword = TextEditingController();
  TextEditingController cipherTextAppPassword = TextEditingController();
  TextEditingController cipherTextBiometry = TextEditingController();

  final _secureEnclavePlugin = SecureEnclave();

  void encrypt() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
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
                      final bool status =
                          (await _secureEnclavePlugin.getStatusSecKey(
                                      tag: '${tag.text}.AppPassword'))
                                  .value ??
                              false;

                      if (status == false) {
                        /// create key on keychain
                        await _secureEnclavePlugin.generateKeyPair(
                          accessControl: AccessControlModel(
                            password: appPassword.text,
                            options: [
                              AccessControlOption.applicationPassword,
                              AccessControlOption.privateKeyUsage,
                            ],
                            tag: '${tag.text}.AppPassword',
                          ),
                        );
                      }

                      /// encrypt with app password
                      Uint8List cipherUint8List =
                          (await _secureEnclavePlugin.encrypt(
                                message: plainText.text,
                                tag: '${tag.text}.AppPassword',
                                password: appPassword.text,
                              ))
                                  .value ??
                              Uint8List.fromList([]);
                      cipherTextAppPassword.text =
                          hex.encode(cipherUint8List).toString();
                      appPassword.clear();
                      Navigator.pop(context);
                      setState(() {});
                    } catch (e) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(e.toString())));
                      log(e.toString());
                    }
                  }
                },
                child: const Text('Encrypt with App Password'),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        );
      },
    );
  }

  void decrypt() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
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
                  if (cipherTextAppPassword.text.isNotEmpty) {
                    try {
                      /// decrypt with app password
                      String plain = (await _secureEnclavePlugin.decrypt(
                            message: Uint8List.fromList(
                                hex.decode(cipherTextAppPassword.text)),
                            tag: '${tag.text}.AppPassword',
                            password: appPassword.text,
                          ))
                              .value ??
                          '';
                      plainTextAppPassword.text = plain;
                      appPassword.clear();
                      Navigator.pop(context);
                      setState(() {});
                    } catch (e) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(e.toString())));
                      log(e.toString());
                    }
                  }
                },
                child: const Text('Decrypt with App Password'),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        );
      },
    );
  }

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
            ElevatedButton(
              onPressed: () {
                encrypt();
              },
              child: const Text('Encrypt with App Password'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (tag.text.isNotEmpty && plainText.text.isNotEmpty) {
                  try {
                    /// check if tag already on keychain
                    final bool status = (await _secureEnclavePlugin
                                .getStatusSecKey(tag: '${tag.text}.Biometry'))
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
                          tag: '${tag.text}.Biometry',
                        ),
                      );
                    }

                    /// encrypt with app password
                    Uint8List cipherUint8List =
                        (await _secureEnclavePlugin.encrypt(
                              message: plainText.text,
                              tag: '${tag.text}.Biometry',
                            ))
                                .value ??
                            Uint8List.fromList([]);
                    cipherTextBiometry.text =
                        hex.encode(cipherUint8List).toString();
                    setState(() {});
                  } catch (e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(e.toString())));
                    log(e.toString());
                  }
                }
              },
              child: const Text('Encrypt with Biometry'),
            ),
            const SizedBox(
              height: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cipher Text (Hex)\ntag : ${tag.text}.AppPassword'),
                const SizedBox(
                  height: 5,
                ),
                TextField(
                  controller: cipherTextAppPassword,
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
                Text('Cipher Text (Hex)\ntag : ${tag.text}.Biometry'),
                const SizedBox(
                  height: 5,
                ),
                TextField(
                  controller: cipherTextBiometry,
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
              onPressed: () {
                decrypt();
              },
              child: const Text('Decrypt with App Password'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (cipherTextBiometry.text.isNotEmpty) {
                  try {
                    /// decrypt with app password
                    String plain = (await _secureEnclavePlugin.decrypt(
                          message: Uint8List.fromList(
                              hex.decode(cipherTextBiometry.text)),
                          tag: '${tag.text}.Biometry',
                        ))
                            .value ??
                        '';
                    plainTextBiometry.text = plain;
                    setState(() {});
                  } catch (e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(e.toString())));
                    log(e.toString());
                  }
                }
              },
              child: const Text('Decrypt with Biometry'),
            ),
            const SizedBox(
              height: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Plain Text\ntag : ${tag.text}.AppPassword'),
                const SizedBox(
                  height: 5,
                ),
                TextField(
                  controller: plainTextAppPassword,
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
                Text('Plain Text\ntag : ${tag.text}.Biometry'),
                const SizedBox(
                  height: 5,
                ),
                TextField(
                  controller: plainTextBiometry,
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
