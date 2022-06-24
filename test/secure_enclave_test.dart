import 'package:flutter_test/flutter_test.dart';
import 'package:secure_enclave/secure_enclave.dart';
import 'package:secure_enclave/secure_enclave_platform_interface.dart';
import 'package:secure_enclave/secure_enclave_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSecureEnclavePlatform 
    with MockPlatformInterfaceMixin
    implements SecureEnclavePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SecureEnclavePlatform initialPlatform = SecureEnclavePlatform.instance;

  test('$MethodChannelSecureEnclave is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSecureEnclave>());
  });

  test('getPlatformVersion', () async {
    SecureEnclave secureEnclavePlugin = SecureEnclave();
    MockSecureEnclavePlatform fakePlatform = MockSecureEnclavePlatform();
    SecureEnclavePlatform.instance = fakePlatform;
  
    expect(await secureEnclavePlugin.getPlatformVersion(), '42');
  });
}
