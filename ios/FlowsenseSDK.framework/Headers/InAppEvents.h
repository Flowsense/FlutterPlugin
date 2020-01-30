#import <Foundation/Foundation.h>

@interface InAppEvents : NSObject

+(void) sendEventWithName:(NSString *)eventName values:(NSDictionary *)map;
+(void) sendGeolocalizedEventWithName:(NSString *)eventName values:(NSDictionary *)map;

@end
