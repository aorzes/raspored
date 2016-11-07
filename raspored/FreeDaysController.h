//
//  FreeDaysController.h
//  raspored
//
//  Created by Anton Orzes on 31/10/2016.
//  Copyright © 2016 Anton Orzes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FreeDayCell.h"

@interface FreeDaysController : UIViewController<UITextFieldDelegate,MyTableCellProtocoll>

@property (weak, nonatomic) IBOutlet UITableView *tablica;


@end
