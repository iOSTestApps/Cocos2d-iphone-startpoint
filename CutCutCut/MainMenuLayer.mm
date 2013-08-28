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
	
    }
	return self;
}

-(void)start
{
    [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
}

-(void)challenge
{
    // add multiplayer here
}
@end
