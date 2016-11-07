//
//  FreeDayCell.h
//  raspored
//
//  Created by Anton Orzes on 01/11/2016.
//  Copyright © 2016 Anton Orzes. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyTableCellProtocoll <NSObject>   /*protokol određuje koje metode mogu iz druge instance klase
                                             on se delegira u drugoj klasi*/
-(void) didPressButton:self;                //ovo je ta metoda
@end


@interface FreeDayCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITextField *textRemark;
@property (weak, nonatomic) IBOutlet UIButton *colorButton;
@property (weak, nonatomic) id<MyTableCellProtocoll> cellProtocoll;

@end
