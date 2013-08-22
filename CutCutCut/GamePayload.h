#import <Foundation/Foundation.h>

@interface GamePayload : NSObject {
    NSString *tournID;
    NSString *matchID;
    NSDictionary *params;
    long score;
    BOOL completeFlag;
    BOOL activeFlag;
}

@property (nonatomic,strong) NSString *tournID;
@property (nonatomic,strong) NSString *matchID;
@property (nonatomic,strong) NSDictionary *params;
@property (nonatomic,assign) long score;
@property (nonatomic,assign) BOOL completeFlag;
@property (nonatomic,assign) BOOL activeFlag;

// Returns an instance of this class as a Singleton
+ (GamePayload *)instance;

- (void)clear;
- (void)store;

@end