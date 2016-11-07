//
//  Clock.h
//  raspored
//
//  Created by Anton Orzes on 17/09/16.
//  Copyright © 2016 Anton Orzes. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Clock : UIImageView
{
    CGSize sSize;
    CGPoint center;
    UIImageView *needleH;
    UIImageView *needleM;
    UIImageView *needleS;
    NSTimer *timerR;
    UILabel *dateLabel;
}

-(id) initWithPosition:(CGPoint)startPosition andSize:(CGSize)clockSize;
@end
