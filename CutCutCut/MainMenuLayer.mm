//
//  MainMenuLayer.m
//  CutCutCut
//
//  Created by Alan Price on 13-02-07.
//
//

#import "HelloWorldLayer.h"
#import "MainMenuLayer.h"

@implementation MainMenuLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainMenuLayer *layer = [MainMenuLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

/*
 * The main init method
 */
-(id) init
{
	if( (self=[super init])) {
		// enable events
		self.isTouchEnabled = YES;
        CGSize screen = [[CCDirector sharedDirector] winSize];
        
        // add the background image
        CCSprite *background = [CCSprite spriteWithFile:@"bg.png"];
        background.position = ccp(screen.width/2,screen.height/2);
        [self addChild:background z:0];
        
        // add the particle effect
        CCParticleSystemQuad *sunPollen = [CCParticleSystemQuad particleWithFile:@"sun_pollen.plist"];
        [self addChild:sunPollen];

        CCMenuItemLabel *label = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"START"fontName:@"Helvetica Neue"fontSize:50] target:self selector:@selector(start)];
        CCMenuItemLabel *label2 = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"CHALLENGE"fontName:@"Helvetica Neue"fontSize:50] target:self selector:@selector(challenge)];
        CCMenu *menu = [CCMenu menuWithItems:label, label2, nil];
        [menu alignItemsVertically];
        [menu setPosition:ccp(screen.width/2, screen.height/2)];
        [self addChild:menu z:4];
        
        _countsLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Helvetica Neue" fontSize:30];
        _countsLabel.anchorPoint = ccp(0, 0.5);
        _countsLabel.position = ccp(screen.width/2 + 160, screen.height/2 - 15);
        _countsLabel.visible = false;
        [self addChild:_countsLabel z:4];
        
        // register an observer with the notification
        // center for challenge count updates
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveChallengeCount:)
                                                     name:@"PropellerSDKChallengeCountChanged" object:nil];
    }
	return self;
}

- (void)dealloc
{
    // unregister the observer from the notification
    // center for challenge count updates
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

- (void)onEnter
{
    [super onEnter];
    
    if (![self submitMatchResult]) {
        [self updateChallengeCount];
    }
    
    // periodically request a challenge count every 15 seconds
    [self schedule:@selector(updateChallengeCount) interval:15];
}

-(void)start
{
    [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
}

-(void)challenge
{
    [[PropellerSDK instance] launch:self];
}

- (void)sdkCompletedWithExit
{
    // sdk completed gracefully with no further action
}

- (void)sdkCompletedWithMatch:(NSDictionary *)match
{
    // sdk completed with a match
    
    // extract the match data
    NSString *tournID = [match objectForKey:PSDK_MATCH_RESULT_TOURNAMENT_KEY];
    NSString *matchID = [match objectForKey:PSDK_MATCH_RESULT_MATCH_KEY];
    NSDictionary *params = [match objectForKey:PSDK_MATCH_RESULT_PARAMS_KEY];
    
    // extract the params data
    //long seed = [[params objectForKey:@"seed"] longValue];
    //int round = [[params objectForKey:@"round"] integerValue];
    
    GamePayload *payLoad = [GamePayload instance];
    
    // validate the payload state
    if (payLoad) {
        // update the game payload
        payLoad.tournID = tournID;
        payLoad.matchID = matchID;
        payLoad.params = params;
        payLoad.activeFlag = true;
        payLoad.completeFlag = false;
        
        
        // play the game for the given match data
        [self start];
    }
}

- (void)sdkFailed:(NSDictionary *)result
{
    //sdk failed with an unrecoverable error
    // (alert box will have been displayed)
}

- (BOOL)sdkSocialLogin:(BOOL)allowCache
{
    NSString *result = nil;
    BOOL succeeded = false;

    // handle social login

    if (succeeded) {
        NSString *provider = @"";
        NSString *email = @"";
        NSString *id = @"";
        NSString *nickname = @"";
        NSString *token = @"";

        // retrieve social login data

        NSDictionary *json = [NSDictionary dictionaryWithObjectsAndKeys:
                              provider, @"provider",
                              email, @"email",
                              id, @"id",
                              nickname, @"nickname",
                              token, @"token",
                              nil];

        NSError *error;

        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json
                                                           options:nil error:&error];

        if (jsonData != nil) {
            result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    }

    [[PropellerSDK instance] sdkSocialLoginCompleted:result];

    return YES;
}

- (BOOL)sdkSocialInvite:(NSString*)subject longMessage:(NSString *)longMessage shortMessage:(NSString *)shortMessage linkUrl:(NSString *)linkUrl
{
    // handle social invite

    [[PropellerSDK instance] sdkSocialInviteCompleted];

    return YES;
}

- (BOOL)sdkSocialShare:(NSString*)subject longMessage:(NSString *)longMessage shortMessage:(NSString *)shortMessage linkUrl:(NSString *)linkUrl
{
    // handle social share

    [[PropellerSDK instance] sdkSocialShareCompleted];

    return YES;
}

- (void)launchPropeller
{
    [[PropellerSDK instance] launch:self];
}

- (BOOL)submitMatchResult
{
    BOOL sentResult = NO;
    
    GamePayload *payLoad = [GamePayload instance];
    
    // validate the payload state
    if (payLoad && payLoad.activeFlag && payLoad.completeFlag) {
        // construct match results dictionary
        NSDictionary *matchResult = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     payLoad.tournID, PSDK_MATCH_POST_TOURNAMENT_KEY,
                                     payLoad.matchID, PSDK_MATCH_RESULT_MATCH_KEY,
                                     [NSNumber numberWithLong:payLoad.score], PSDK_MATCH_POST_SCORE_KEY,
                                     nil];
        
        // relaunch Propeller SDK with match results
        PropellerSDK *propellerSDK = [PropellerSDK instance];
        [propellerSDK launchWithMatchResult:matchResult delegate:self];
        
        [matchResult release];
        
        // reset the payload state and data
        // in memory and persistent storage
        [payLoad clear];
        
        sentResult = YES;
    }
    
    return sentResult;
}

- (void)receiveChallengeCount:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:@"PropellerSDKChallengeCountChanged"]) {
        NSDictionary *userInfo = notification.userInfo;
        int count = [[userInfo objectForKey:@"count"] integerValue];
        
        // update the UI with the new challenge count
        if (count > 0) {
            [_countsLabel setString:[NSString stringWithFormat:@"%d", count]];
            _countsLabel.visible = true;
        } else {
            _countsLabel.visible = false;
        }
    }
}

- (void)updateChallengeCount
{
    [[PropellerSDK instance] syncChallengeCounts];
}

@end
