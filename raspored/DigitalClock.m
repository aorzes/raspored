//
//  DigitalClock.m
//  raspored
//
//  Created by Anton Orzes on 10/10/2016.
//  Copyright © 2016 Anton Orzes. All rights reserved.
//

#import "DigitalClock.h"

@implementation DigitalClock
- (id)initWithPosition:(CGPoint)startPosition andSize:(CGSize)clockSize {
    self = [super init];
    if (self) {
        sSize = clockSize;
        self.frame = CGRectMake(startPosition.x, startPosition.y, clockSize.width, clockSize.height);
        center = CGPointMake(sSize.width/2, sSize.height/2);
        _dColor = [UIColor yellowColor];
        [self clockFace];
        [self makePixel];
        timerR = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(time)
                                                userInfo:nil
                                                 repeats:YES];
    }
    return self;
}

- (void)clockFace {
    NSArray *n0=@[@"111",
                  @"1.1",
                  @"1.1",
                  @"1.1",
                  @"111"];
    NSArray *n1=@[@".1.",
                  @"11.",
                  @".1.",
                  @".1.",
                  @"111"];
    NSArray *n2=@[@"111",
                  @"..1",
                  @".1.",
                  @"1..",
                  @"111"];
    NSArray *n3=@[@"111",
                  @"..1",
                  @"111",
                  @"..1",
                  @"111"];
    NSArray *n4=@[@"1..",
                  @"1..",
                  @"111",
                  @"..1",
                  @"..1"];
    NSArray *n5=@[@"111",
                  @"1..",
                  @"111",
                  @"..1",
                  @"111"];
    NSArray *n6=@[@"111",
                  @"1..",
                  @"111",
                  @"1.1",
                  @"111"];
    NSArray *n7=@[@"111",
                  @"..1",
                  @"..1",
                  @"..1",
                  @"..1"];
    NSArray *n8=@[@"111",
                  @"1.1",
                  @"111",
                  @"1.1",
                  @"111"];
    NSArray *n9=@[@"111",
                  @"1.1",
                  @"111",
                  @"..1",
                  @"111"];
    NSArray *n10=@[@"...",
                   @".1.",
                   @"...",
                   @".1.",
                   @"..."];
    digits = [NSArray arrayWithObjects:n0,n1,n2,n3,n4,n5,n6,n7,n8,n9,n10, nil];
}

- (void)time {
    NSDate *now = [NSDate date];
    NSDateFormatter *dateformater = [[NSDateFormatter alloc]init];
    [dateformater setDateFormat:@"HH:mm:ss"];
    NSString *strFromDate =[dateformater stringFromDate:now];
    for (int i=0; i<strFromDate.length;i++) {
        int digit=[strFromDate characterAtIndex:i]-48;
        [self makeNumber:digit onPos:i];
    }
    // NSLog(@"%@",strFromDate);
}

- (void)makeNumber:(int)num onPos:(int)pos {
    pos*=15;
    NSArray *digit = [digits objectAtIndex:num];
    for (NSString *row in digit) {
        for (int i=0; i<3; i++) {
            char oneBit=[row characterAtIndex:i];
            for (UIImageView *bit in self.subviews) {
                if (bit.tag==pos+1){
                    pos++;
                    if (oneBit=='1') {
                        bit.backgroundColor = _dColor;
                    }
                    else{
                        bit.backgroundColor = [UIColor clearColor];
                    }
                    break;
                }
            }
        }
    }
}

- (void)makePixel {
    int x = 0;
    int y = 0;
    int n = 1;
    int pixelSize = sSize.width/30;
    for (int i=0; i<8; i++) {
        x += pixelSize * 3 + 2;
        y=50;
        for (int j=1; j<=15; j++) {
            CGRect rect = CGRectMake(x, y, 6, 11);
            UIImageView * imageRect = [[UIImageView alloc]initWithFrame:rect];
            imageRect.backgroundColor = [UIColor clearColor];
            imageRect.tag = n++;
            [self addSubview:imageRect];
            x+=pixelSize;
            if (j%3==0) {
                x-=pixelSize * 3;
                y+=12;
            }
        }
    }
    
}

@end
