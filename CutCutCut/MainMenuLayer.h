//
//  MainMenuLayer.h
//  CutCutCut
//
//  Created by Alan Price on 13-02-07.
//
//

#import "cocos2d.h"

#import "PropellerSDK.h"
#import "GamePayload.h"

@interface MainMenuLayer : CCLayer <PropellerSDKDelegate>
{
    CCLabelTTF *_countsLabel;
}
// returns a CCScene that contains the MainMenuLayer as the only child
+(CCScene *) scene;

@end
