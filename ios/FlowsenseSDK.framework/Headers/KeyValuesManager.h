#import <UIKit/UIKit.h>

@interface KeyValuesManager : NSObject

+ (void) setKeyValue:(NSString *)key valueString:(NSString *)value;
+ (void) setKeyValue:(NSString *)key valueDate:(NSDate *)value;
+ (void) setKeyValue:(NSString *)key valueBoolean:(BOOL)value;
+ (void) setKeyValue:(NSString *)key valueDouble:(double)value;

+ (void) updateServer:(NSDictionary *)keyValue;
+ (void) commitChanges;


@end
