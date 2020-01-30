#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationShareModel.h"
#import <UIKit/UIKit.h>
#import "DBGeofences.h"
#import <AWSCore/AWSCore.h>
#import <AWSKinesis/AWSKinesis.h>

@interface LocationTracker : NSObject <CLLocationManagerDelegate>

@property (nonatomic) CLLocationCoordinate2D myLastLocation;

@property (strong,nonatomic) LocationShareModel * shareModel;
@property (strong,nonatomic) NSMutableArray * checkInTimers;
@property (strong,nonatomic) NSTimer * timer;
@property (strong,nonatomic) AWSFirehoseRecorder *firehoseRecorder;

@property (nonatomic) NSDate* distPast;
@property (nonatomic) NSDate* distFuture;

+ (LocationTracker *)sharedInstance;
+ (CLLocationManager *)sharedLocationManager;

- (void) startLocationTracking;
- (void) stopLocationTracking;
- (void) restartUpdates;
- (void) PostJsonLocation:(NSString *)latitude :(NSString *)longitude :(NSDate *)date_arr :(NSDate *)date_dep :(double)accuracy;
- (void) sendEvent:(NSString *)latitude :(NSString *)longitude :(NSString *)dateArr :(NSString *)dateDep :(NSString *)duration :(double)accuracy :(int)points;
- (void) sendCheckin:(NSMutableDictionary *) dict;
- (void) sendDeparture:(NSDictionary *) dict;
- (void) monitorRegionsWithLocation:(CLLocation *) location;
//- (void) monitorRegionWithName:(NSString *)name latitude:(double)latitude longitude:(double)longitude radius:(double)radius;
- (void) monitorNearestRegionsWithLocation:(CLLocation *)location previousLocation:(CLLocation *)oldLocation;
- (void) stopMonitoringAllRegions;
- (NSArray*) getMonitoredRegions;
- (void) sendCheckInAfterTimer:(NSTimer *)timer;
- (void) startSignificantLocationChanges;
- (void) sendEventForce;
- (void) setAuthorizationCallback:(void(^)(int status)) completionHandler;
- (void) checkLocationServices;
- (int) checkLocationServicesInstantly;
- (void) requestLocationForInAppEvent;
- (void) setLocationCallback:(void(^)(CLLocation *location)) completionHandler;
//- (void) sendCheckInForce;

@end
