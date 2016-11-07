//
//  RootViewController.h
//  raspored
//
//  Created by Anton Orzes on 05/11/2016.
//  Copyright © 2016 Anton Orzes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController<UIPageViewControllerDelegate>
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property int startIndex;
@end
