#import <Foundation/Foundation.h>

@interface FSDeviceUID : NSObject
+ (NSString *)uid;
+ (NSString *)appleIFV;
+ (NSString *)randomUUID;
+ (NSString *)appleIFA;
+ (BOOL)addEnabled;

@end
