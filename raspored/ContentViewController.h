//
//  ContentViewController.h
//  praznaPageView
//
//  Created by Anton Orzes on 31/10/2016.
//  Copyright © 2016 Anton Orzes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "ContentTableViewCell.h"
#import "RootViewController.h"
#import "sqlite3.h"

@interface ContentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tablica;

@end
