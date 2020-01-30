#import <Foundation/Foundation.h>

#import <sqlite3.h>

@interface DB_Mgr : NSObject

@property (nonatomic, strong) NSMutableArray *arrColumnNames;
@property (nonatomic) int affectedRows;
@property (nonatomic) long long lastInsertedRowID;


+(DB_Mgr *) getSharedInstance;

-(void) initDB;
-(void) copyDatabaseIntoDocumentsDirectory;
-(BOOL) saveData:(NSString*)latitude longitude:(NSString*)longitude dateArrival:(NSString*)dateArrival dateDeparture:(NSString*)dateDeparture accuracy:(double)accuracy;
-(NSArray *) getLast;
-(void) removeFirst:(NSInteger)idLoc;

@end
