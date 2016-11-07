//
//  ConectionView.h
//  raspored
//
//  Created by Anton Orzes on 17/09/16.
//  Copyright © 2016 Anton Orzes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "AppDelegate.h"
#import "ViewController.h"
#import <MessageUI/MessageUI.h>

@interface ConectionView : UIViewController<MCBrowserViewControllerDelegate,UITextFieldDelegate,MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (weak, nonatomic) IBOutlet UISwitch *isVisibleSwitch;
@property (weak, nonatomic) IBOutlet UITextField *myName;

@property NSData *toSend;
@property NSData *receivedData;

@end
