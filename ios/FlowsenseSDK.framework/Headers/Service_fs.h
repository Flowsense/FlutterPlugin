#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import <CoreLocation/CoreLocation.h>

@interface Service_fs : NSObject

NS_ASSUME_NONNULL_BEGIN
+(void) StartFlowsenseService:(NSString *)partnerToken;
+(void) StartFlowsenseService:(NSString *)partnerToken :(BOOL) startNow;
+(void) StartFlowsenseService:(NSString *)partnerToken disableActivityMonitoring:(BOOL) shouldNotMonitor;
+(void) StartFlowsenseService:(NSString *)partnerToken disableActivityMonitoring:(BOOL) shouldNotMonitor startLocationNow:(BOOL) startNow;

//Push Services

// Initializes Push Service
+(void) StartFlowsensePushService:(NSDictionary *) launchOptions;

// Initializes Push Service with action block allowing user to retrieve the push token and push actions: arrival and click
// result is @{@"push_token": "token", @"push_received": <NSDictionary containing payload>, @"push_clicked": <NSDictionary containing payload>}
+(void) StartFlowsensePushServiceWithLaunchOptions:(NSDictionary *) launchOptions actionBlock:(void(^)(NSDictionary *result))completionHandler;

// Displays an image in Push
+(void) includeMediaAttachmentWithRequest:(UNNotificationRequest *)request mutableContent:(UNMutableNotificationContent *)bestAttemptContent contentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler;

// Set a Push callback when push is received and clicked with:
// result is @{@"push_token": "token", @"push_received": <NSDictionary containing payload>, @"push_clicked": <NSDictionary containing payload>}
+(void) setPushCallback:(void(^)(NSDictionary *result))completionHandler;

+(void) setNotificationResponseHandler:(void(^)(UNNotificationResponse *response))completionHandler;

// Open a deeplink with an app URI and, optionally, an Itunes Store link for app installation and the store app ID
+(void) openDeepLinkWithURI:(NSString *)appURI storeLink:(NSString *)itunesLink storeID:(NSNumber *)appID;

// Stops Flowsense Services until StartFlowsenseService is called again with the correct location permissions
+(void) StopFlowsenseService;

+(void) sendPushClickAnalytics:(NSString *)pushUUID;
+(void) sendPushArrivedAnalytics:(NSString *)pushUUID;
+(void) flowsenseHandlePushWithUserInfo:(NSDictionary*) userInfo fetchCompletionHandler:(nullable void (^)(UIBackgroundFetchResult))completionHandler;
+(void) flowsenseHandleResponseWithNotificationResponse:(UNNotificationResponse *)response;

+(void) sendPushToken:(NSData *)token;
+(void) sendFCMPushToken:(NSString *)token;
+(NSDictionary *) getPushExtras;

+(void) StartMonitoringLocation;
+(void) requestLocationAuthorizationStatusAsync:(void(^)(int status)) callback;
+(int) requestLocationAuthorizationStatus;
+(void) requestWhenInUseLocation;
+(void) requestAlwaysLocation;
+(void) requestWhenInUseLocationWithCallback:(void(^)(int status)) callback;
+(void) requestAlwaysLocationWithCallback:(void(^)(int status)) callback;
+(void) updatePartnerUserIdiOS:(NSString *) userId;
+(void) requestPushToken;
+(void) isRegisteredForPush;
+(BOOL) isInsideHome;
+(BOOL) isInsideWork;
+(void) monitorApplicationActivity;

+(void) updateGeofences;
+(NSArray *) getStoredGeofences;
+(NSArray *) getKeyValues;

NS_ASSUME_NONNULL_END

@end
