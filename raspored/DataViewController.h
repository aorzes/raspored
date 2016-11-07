//
//  DataViewController.h
//  praznaPageView
//
//  Created by Anton Orzes on 25/10/2016.
//  Copyright © 2016 Anton Orzes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataViewController : UIViewController<UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *dataLabel;
@property (weak, nonatomic) IBOutlet UITextView *dataText;
@property (weak, nonatomic) IBOutlet UIView *viewForRecord;

@property (strong, nonatomic) id dataObject;
@property (strong, nonatomic) id tekstObject;
@property (strong, nonatomic) id pvc;
@end

