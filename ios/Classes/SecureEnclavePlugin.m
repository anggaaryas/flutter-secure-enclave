#import "SecureEnclavePlugin.h"
#if __has_include(<secure_enclave/secure_enclave-Swift.h>)
#import <secure_enclave/secure_enclave-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "secure_enclave-Swift.h"
#endif

@implementation SecureEnclavePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSecureEnclavePlugin registerWithRegistrar:registrar];
}
@end
