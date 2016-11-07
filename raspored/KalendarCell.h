//
//  KalendarCell.h
//  raspored
//
//  Created by Anton Orzes on 31/10/2016.
//  Copyright © 2016 Anton Orzes. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface KalendarCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UIView *monthView;

@end
