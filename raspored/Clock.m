//
//  Clock.m
//  raspored
//
//  Created by Anton Orzes on 17/09/16.
//  Copyright © 2016 Anton Orzes. All rights reserved.
//

#import "Clock.h"

@implementation Clock
- (id)initWithPosition:(CGPoint)startPosition andSize:(CGSize)clockSize {
    self = [super init];
    if (self) {
        sSize = clockSize;
        self.frame = CGRectMake(startPosition.x, startPosition.y, clockSize.width, clockSize.height);
        center = CGPointMake(sSize.width/2, sSize.height/2);
        [self clockFace];
        [self makeNeedles];
        timerR = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                target:self
                                            selector:@selector(rotation)
                                            userInfo:nil
                                            repeats:YES];
    }
    return self;
}

- (void)clockFace {
    double r = sSize.width/2.4;
    double angle = M_PI / 6 - M_PI_2;
    for (int i=0; i<12; i++) {
        UILabel *number = [[UILabel alloc]init];
        number.frame = CGRectMake(0, 0, sSize.width/8, sSize.width/10);
        number.center = CGPointMake(center.x+cos(angle)*r, center.y+sin(angle)*r);
        number.textAlignment = NSTextAlignmentCenter;
        number.adjustsFontSizeToFitWidth = YES;
        number.text = [NSString stringWithFormat:@"%i", i+1];
        number.textColor = [UIColor whiteColor];
        number.shadowColor = [UIColor blackColor];
        number.shadowOffset = CGSizeMake(3, 1);
        [number setFont: [UIFont fontWithName:@"Arial" size:11.0]];
        number.layer.masksToBounds = NO;
        [self addSubview:number];
        angle +=  M_PI / 6;
    }
    dateLabel = [[UILabel alloc]init];
    dateLabel.frame = CGRectMake(0, 3*sSize.width/4, sSize.width/4, sSize.width/6);
    dateLabel.center = CGPointMake(sSize.width/2, 3*sSize.width/4);
    dateLabel.textAlignment = NSTextAlignmentCenter;
    dateLabel.textColor = [UIColor whiteColor];
    dateLabel.shadowColor = [UIColor blackColor];
    dateLabel.shadowOffset = CGSizeMake(3, 1);
    dateLabel.layer.masksToBounds = NO;
    dateLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:dateLabel];
}

- (void)makeNeedles {
    needleH = [self addNeedle:CGSizeMake(10, sSize.width/4) color:[UIColor redColor]];
    needleM = [self addNeedle:CGSizeMake(6, sSize.width/3) color:[UIColor blueColor]];
    needleS = [self addNeedle:CGSizeMake(4, sSize.width/2.5) color:[UIColor greenColor]];
    [self addAxle];
}

- (UIImageView *)addNeedle:(CGSize)size color:(UIColor *)color {
    UIImageView *image = [[UIImageView alloc]init];
    image.frame = CGRectMake(0, 0, size.width, size.height);
    image.layer.anchorPoint = CGPointMake(0.5,1);
    image.center = center;
    image.backgroundColor = color;
    [self addSubview:image];
    [self addShadow:image];
    return image;
}

- (void)addShadow:(UIImageView *)image{
    image.layer.shadowColor = [UIColor blackColor].CGColor;
    image.layer.shadowOffset = CGSizeMake(5, 2);
    image.layer.shadowRadius = 2;
    image.layer.shadowOpacity = 0.5;
    image.clipsToBounds = NO;
    [self addBorder:image];
}

- (void)addAxle{
    UIImageView *axle = [[UIImageView alloc]init];
    axle.frame = CGRectMake(0,0,14, 14);
    axle.center = center;
    axle.layer.backgroundColor = [UIColor redColor].CGColor;
    axle.layer.borderColor = [UIColor whiteColor].CGColor;
    axle.layer.borderWidth = 0.5;
    axle.layer.cornerRadius = 7;
    [self addSubview:axle];

}

- (void)addBorder:(UIImageView *)image{
    image.layer.borderWidth = 1;
    image.layer.borderColor = [UIColor grayColor].CGColor;
    image.layer.cornerRadius = image.frame.size.width/2;
}

- (void)rotation{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:
                                    (NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond)
                                               fromDate:now];
    NSInteger month = components.month;
    NSInteger day = components.day;
    NSInteger hour = components.hour;
    NSInteger minute = components.minute;
    NSInteger second = components.second;
    double hourAngle = (double)hour*M_PI/6.0+minute*M_PI/30.0/12.0;
    needleH.transform = CGAffineTransformMakeRotation(hourAngle);
    double minuteAngle = minute*M_PI/30.0+second*M_PI/1800;
    needleM.transform = CGAffineTransformMakeRotation(minuteAngle);
    double secondAngle = second*M_PI/30;
    needleS.transform = CGAffineTransformMakeRotation(secondAngle);
    dateLabel.text = [NSString stringWithFormat:@"%li.%li.",(long)day,(long)month];
}


@end
