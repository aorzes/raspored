//
//  KalendarCell.m
//  raspored
//
//  Created by Anton Orzes on 31/10/2016.
//  Copyright © 2016 Anton Orzes. All rights reserved.
//

#import "KalendarCell.h"

@implementation KalendarCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
   // _monthView.frame = CGRectMake(0, 0, 250, 350);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
