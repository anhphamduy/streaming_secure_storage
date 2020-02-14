#import "StreamingSecureStoragePlugin.h"
#if __has_include(<streaming_secure_storage/streaming_secure_storage-Swift.h>)
#import <streaming_secure_storage/streaming_secure_storage-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "streaming_secure_storage-Swift.h"
#endif

@implementation StreamingSecureStoragePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftStreamingSecureStoragePlugin registerWithRegistrar:registrar];
}
@end
