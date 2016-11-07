//
//  FreeDayCell.m
//  raspored
//
//  Created by Anton Orzes on 01/11/2016.
//  Copyright © 2016 Anton Orzes. All rights reserved.
//

#import "FreeDayCell.h"

@implementation FreeDayCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)press:(id)sender {
    [self.cellProtocoll didPressButton:self];
}

@end
