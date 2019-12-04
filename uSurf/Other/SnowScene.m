//
//  SnowScene.m
//  uSurf
//
//  Created by Matthew Jagiela on 11/22/15.
//  Copyright © 2015 Matthew Jagiela. All rights reserved.
//

#import "SnowScene.h"


@implementation SnowScene
-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor clearColor];
        NSString *emitterPath = [[NSBundle mainBundle] pathForResource:@"Snow" ofType:@"sks"];
        SKEmitterNode *snow = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
        snow.position = CGPointMake(CGRectGetMidX(self.frame), self.size.height);
        //snow.name = @"particleBokeh";
        snow.targetNode = self.scene;
        [self addChild:snow];
        
    }
    return self;
}

@end
