//
//  AppDelegate.h
//  raspored
//
//  Created by Anton Orzes on 28/06/16.
//  Copyright © 2016 Anton Orzes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCMenager.h"

@protocol SaveProtocol
-(void) saveOnClosing;//metode koje su u drugoj klasi
@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MCMenager *mcManager;
@property (weak, nonatomic) id <SaveProtocol> saveDelegate;

@end

