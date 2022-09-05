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
                      final bool status = (await _secureEnclavePlugin
                                  .isKeyCreated(tag: '${tag.text}.AppPassword'))
                              .value ??
                          false;

                      if (status == false) {
                        /// create key on keychain
                        ResultModel res =
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
                        tag: '${tag.text}.AppPassword',
                        password: appPassword.text,
                      ));
                      if (cipherUint8List.value != null) {
                        cipherTextAppPassword.text =
                            hex.encode(cipherUint8List.value).toString();
                        appPassword.clear();
                        if (!mounted) return;
                        Navigator.pop(context);
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
                      ResultModel cipherText =
                          (await _secureEnclavePlugin.decrypt(
                        message: Uint8List.fromList(
                            hex.decode(cipherTextAppPassword.text)),
                        tag: '${tag.text}.AppPassword',
                        password: appPassword.text,
                      ));
                      if (cipherText.value != null) {
                        plainTextAppPassword.text = cipherText.value;
                        appPassword.clear();
                        if (!mounted) return;
                        Navigator.pop(context);
                        setState(() {});
                      } else {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(cipherText.error!.desc.toString())));
                      }
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
        actions: [
          IconButton(
              onPressed: () {
                _secureEnclavePlugin.removeKey('${tag.text}.AppPassword');
                _secureEnclavePlugin.removeKey('${tag.text}.Biometry');
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
                                .isKeyCreated(tag: '${tag.text}.Biometry'))
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
                          tag: '${tag.text}.Biometry',
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
                      tag: '${tag.text}.Biometry',
                    ));
                    if (cipherUint8List.value != null) {
                      cipherTextBiometry.text =
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
                    ResultModel plain = (await _secureEnclavePlugin.decrypt(
                      message: Uint8List.fromList(
                          hex.decode(cipherTextBiometry.text)),
                      tag: '${tag.text}.Biometry',
                    ));
                    if (plain.value != null) {
                      plainTextBiometry.text = plain.value;
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
