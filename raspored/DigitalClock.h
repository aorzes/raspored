//
//  DigitalClock.h
//  raspored
//
//  Created by Anton Orzes on 10/10/2016.
//  Copyright © 2016 Anton Orzes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DigitalClock : UIImageView
{
    CGSize sSize;
    CGPoint center;
    NSTimer *timerR;
    NSArray *digits;
}
@property UIColor *dColor;
-(id) initWithPosition:(CGPoint)startPosition andSize:(CGSize)clockSize;
@end
