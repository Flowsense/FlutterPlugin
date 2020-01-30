#import <Flutter/Flutter.h>
#import <FlowsenseSDK/Service_fs.h>
#import <FlowsenseSDK/KeyValuesManager.h>
#import <FlowsenseSDK/InAppEvents.h>

@interface FlowsenseFlutterPlugin : NSObject<FlutterPlugin>
+ (instancetype)sharedInstance;
@end
