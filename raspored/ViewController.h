//
//  ViewController.h
//  raspored
//
//  Created by Anton Orzes on 28/06/16.
//  Copyright © 2016 Anton Orzes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Clock.h"
#import "DigitalClock.h"
#import "ConectionView.h"
#import "KalendarController.h"
#import "ContentViewController.h"

@interface ViewController : UIViewController <UITextFieldDelegate,
                                                UIImagePickerControllerDelegate,
                                                UINavigationControllerDelegate,
                                                SaveProtocol>//delegiram @protocol iz AppDelegate
@property NSDictionary *receivedData2;
@property BOOL acceptedData;
@property BOOL resetImage;
@property float lessonLength;
@property float statHour;
@property float startMinute;
@property float bigBreak;
@property float litleBreak;
@property int bigBreak1After;
@property int bigBreak2After;
@end

