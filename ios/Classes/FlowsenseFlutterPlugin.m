#import "FlowsenseFlutterPlugin.h"

typedef void (^FSHandleNotificationAction)(NSDictionary * result);

@interface FlowsenseFlutterPlugin ()

@property (strong, nonatomic) FlutterMethodChannel *channel;

@end

@implementation FlowsenseFlutterPlugin

FSHandleNotificationAction handleAction;
static NSDictionary* launchOptions = nil;

+(void)load {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(didFinishLaunching:)
                                               name:UIApplicationDidFinishLaunchingNotification
                                             object:nil];
}

+(void) didFinishLaunching:(NSNotification*)notification {
  
  launchOptions = notification.userInfo;
  if (launchOptions == nil) {
    //launchOptions is nil when not start because of notification or url open
    launchOptions = [NSDictionary dictionary];
  }

  [Service_fs StartFlowsensePushServiceWithLaunchOptions:launchOptions actionBlock:^(NSDictionary *result) {
    NSString *pushToken = [result objectForKey:@"push_token"];
    NSNumber *pushPermission = [result objectForKey:@"push_permission"];
    NSDictionary *pushReceived = [result objectForKey:@"push_received"];
    NSDictionary *pushClicked = [result objectForKey:@"push_clicked"];
    
    if (pushClicked != nil) {
        if (FlowsenseFlutterPlugin.sharedInstance.channel != nil) {
            [FlowsenseFlutterPlugin.sharedInstance.channel invokeMethod:@"FlowsenseSDK#clickedNotification" arguments:pushClicked];
        }
    }
    if (pushReceived != nil) {
        if (FlowsenseFlutterPlugin.sharedInstance.channel != nil) {
            [FlowsenseFlutterPlugin.sharedInstance.channel invokeMethod:@"FlowsenseSDK#receivedNotification" arguments:pushReceived];
        }
    }
    
    if (pushToken != nil) {
        if (FlowsenseFlutterPlugin.sharedInstance.channel != nil) {
            [FlowsenseFlutterPlugin.sharedInstance.channel invokeMethod:@"FlowsenseSDK#pushToken" arguments:pushReceived];
        }
    }

    if (pushPermission != nil) {
        if (FlowsenseFlutterPlugin.sharedInstance.channel != nil) {
            [FlowsenseFlutterPlugin.sharedInstance.channel invokeMethod:@"FlowsenseSDK#pushPermission" arguments:pushReceived];
        }
    }
  }];
  
}

+ (instancetype)sharedInstance
{
    static FlowsenseFlutterPlugin *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [FlowsenseFlutterPlugin new];
    });
    return sharedInstance;
}


+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {

  FlowsenseFlutterPlugin.sharedInstance.channel = [FlutterMethodChannel
      methodChannelWithName:@"FlowsenseSDK"
            binaryMessenger:[registrar messenger]];
  [registrar addMethodCallDelegate:FlowsenseFlutterPlugin.sharedInstance channel:FlowsenseFlutterPlugin.sharedInstance.channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"FlowsenseSDK#startFlowsenseService" isEqualToString:call.method]) {
        [self startFlowsenseService:call withResult:result];
    } else if ([@"FlowsenseSDK#requestAlwaysAuthorization" isEqualToString:call.method]) {
        [self requestAlwaysAuthorization];
    } else if ([@"FlowsenseSDK#requestWhenInUseAuthorization" isEqualToString:call.method]) {
        [self requestWhenInUseAuthorization];
    } else if ([@"FlowsenseSDK#startMonitoringLocation" isEqualToString:call.method]) {
        [self startMonitoringLocation];
    } else if ([@"FlowsenseSDK#updatePartnerUserId" isEqualToString:call.method]) {
        [self updatePartnerUserId:call withResult:result];
    } else if ([@"FlowsenseSDK#setKeyValue" isEqualToString:call.method]) {
        [self setKeyValue:call withResult:result];
    } else if ([@"FlowsenseSDK#commitChanges" isEqualToString:call.method]) {
        [self commitChanges:call withResult:result];
    } else if ([@"FlowsenseSDK#inAppEvent" isEqualToString:call.method]) {
        [self inAppEvent:call withResult:result];
    } else if ([@"FlowsenseSDK#requestPushToken" isEqualToString:call.method]) {
        [self requestPushToken];
    } else if ([@"FlowsenseSDK#pushNotificationsEnabled" isEqualToString:call.method]) {
        [self pushNotificationsEnabled:call withResult:result];
    } else if ([@"FlowsenseSDK#smsEnabled" isEqualToString:call.method]) {
        [self smsEnabled:call withResult:result];
    } else if ([@"FlowsenseSDK#emailEnabled" isEqualToString:call.method]) {
        [self emailEnabled:call withResult:result];
    } else if ([@"FlowsenseSDK#createNotificationChannel" isEqualToString:call.method]) {
        [self createNotificationChannel:call withResult:result];
    } else if ([@"FlowsenseSDK#enableCommChannel" isEqualToString:call.method]) {
        [self enableCommChannel:call withResult:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)startFlowsenseService:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [Service_fs StartFlowsenseService:call.arguments[@"authToken"] :NO];
    result(@[]);
}

- (void)updatePartnerUserId:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [Service_fs updatePartnerUserIdiOS:call.arguments[@"userID"]];
    result(@[]);
}

- (void)requestPushToken {
    [Service_fs requestPushToken];
}

- (void)setKeyValue:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    @try {
        if ([call.arguments[@"keyValues"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *keyValues = call.arguments[@"keyValues"];
            for (NSString *key in keyValues) {
                NSObject *obj = [keyValues objectForKey:key];
                if ([obj isKindOfClass:[NSString class]]) {
                    NSString *value = (NSString *) obj;
                    [KeyValuesManager setKeyValue:key valueString:value];
                } else if ([obj isKindOfClass:[NSNumber class]]) {
                    NSNumber *value = (NSNumber *) obj;
                    if ([key containsString:@"FSDate_"]) {
                        NSString *keyStr = [key stringByReplacingOccurrencesOfString:@"FSDate_" withString:@""];
                        [KeyValuesManager setKeyValue:keyStr valueDate:[NSDate dateWithTimeIntervalSince1970:[value doubleValue]/1000]];
                    } else if ([key containsString:@"FSBool_"]) {
                        NSString *keyStr = [key stringByReplacingOccurrencesOfString:@"FSBool_" withString:@""];
                        [KeyValuesManager setKeyValue:keyStr valueBoolean:[value boolValue]];
                    } else {
                        [KeyValuesManager setKeyValue:key valueDouble:[value doubleValue]];
                    }
                }
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",[NSThread callStackSymbols]);
        NSLog(@"%@", [exception description]);
    } @finally {}
    result(@[]);
}

- (void)commitChanges:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [KeyValuesManager commitChanges];
    result(@[]);
}

- (void)inAppEvent:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *eventName = call.arguments[@"eventName"];
    @try {
        NSMutableDictionary *eMap = [[NSMutableDictionary alloc] init];
        NSDictionary *eventMap = call.arguments[@"eventMap"];
        for (NSString *key in eventMap) {
            if ([key containsString:@"FSDate_"]) {
                [eMap setObject:[eventMap objectForKey:key] forKey:[key stringByReplacingOccurrencesOfString:@"FSDate_" withString:@""]];
            } else if ([key containsString:@"FSBool_"]) {
                [eMap setObject:[eventMap objectForKey:key] forKey:[key stringByReplacingOccurrencesOfString:@"FSBool_" withString:@""]];
            } else {
                [eMap setObject:[eventMap objectForKey:key] forKey:key];
            }
        }
        [InAppEvents sendEventWithName:eventName values:eMap];
    } @catch (NSException *exception) {
        NSLog(@"%@",[NSThread callStackSymbols]);
        NSLog(@"%@", [exception description]);
    } @finally {}
    result(@[]);
}

- (void)requestAlwaysAuthorization {
    [Service_fs requestAlwaysLocation];
}

- (void)requestWhenInUseAuthorization {
    [Service_fs requestWhenInUseLocation];
}

- (void)startMonitoringLocation {
    [Service_fs StartMonitoringLocation];
}

- (void)pushNotificationsEnabled:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [Service_fs pushNotificationsEnabled:[call.arguments[@"enabled"] boolValue]];
    result(@[]);
}

- (void)smsEnabled:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [Service_fs smsEnabled:[call.arguments[@"enabled"] boolValue]];
    result(@[]);
}

- (void)emailEnabled:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [Service_fs emailEnabled:[call.arguments[@"enabled"] boolValue]];
    result(@[]);
}

- (void)createNotificationChannel:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [Service_fs createNotificationChannel:call.arguments[@"channelName"]];
    result(@[]);
}

- (void)enableCommChannel:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [Service_fs enableCommChannel:call.arguments[@"channelName"] enabled:[call.arguments[@"enabled"] boolValue]];
    result(@[]);
}

@end
