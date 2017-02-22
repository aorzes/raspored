//
//  FreeDaysController.m
//  raspored
//
//  Created by Anton Orzes on 31/10/2016.
//  Copyright © 2016 Anton Orzes. All rights reserved.
//

#import "FreeDaysController.h"

@interface FreeDaysController ()
{
    NSMutableArray *calendarDeys;
    NSMutableArray *weekDayArr;
    NSMutableArray *colorDay;
    NSMutableArray *remarkArr;
    NSArray * wDayName;
    NSArray *oldRemark;
    NSArray *oldColor;
    //NSDate *oldDate;
    int startYear;

}
@end

@implementation FreeDaysController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setLocale: [NSLocale currentLocale]];
    wDayName = [df shortWeekdaySymbols];
    // test saved day .
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *s = [prefs stringForKey:@"startYear"];
    if (s.length>0) {
        startYear = (int)[s intValue];
    }else {
        startYear = 2016;
    }
    //oldDate = _mainPicker.date;
    NSData *colorData = [prefs dataForKey:@"colorDay"];
    if (!colorData) {
        [self makeCalendarDays];
    }else {
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
        colorDay = [NSMutableArray arrayWithArray:array];
        
        NSData *weekData = [prefs dataForKey:@"weekDay"];
        array = [NSKeyedUnarchiver unarchiveObjectWithData:weekData];
        weekDayArr = [NSMutableArray arrayWithArray:array];
        
        NSData *calendarData = [prefs dataForKey:@"calendarDay"];
        array = [NSKeyedUnarchiver unarchiveObjectWithData:calendarData];
        calendarDeys = [NSMutableArray arrayWithArray:array];
        
        NSData *remakData = [prefs dataForKey:@"remark"];
        array = [NSKeyedUnarchiver unarchiveObjectWithData:remakData];
        remarkArr = [NSMutableArray arrayWithArray:array];
    }
    
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)makeCalendarDays {
    calendarDeys = [[NSMutableArray alloc]init];
    weekDayArr = [[NSMutableArray alloc]init];
    colorDay = [[NSMutableArray alloc]init];
    remarkArr = [[NSMutableArray alloc]init];
    NSDateComponents *comps = [[NSDateComponents alloc] init];          //start day
    [comps setDay:1];
    [comps setMonth:9];
    int y = startYear;
    [comps setYear:y];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *startDate = [calendar dateFromComponents:comps];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    for (int i=0; i<350; i++) {
        NSString *stringDate = [formatter stringFromDate:startDate];
        [calendarDeys addObject:stringDate];
        [remarkArr addObject:@""];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:startDate];
        [components setDay:components.day +1];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSInteger weekInt = [calendar component:NSCalendarUnitWeekday fromDate:startDate];
        [weekDayArr addObject:[NSNumber numberWithInt:(int) weekInt]];
        if (weekInt == 1 || weekInt == 7) {
            [colorDay addObject:@YES];
        }else {
            [colorDay addObject:@NO];
        }
        startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FreeDayCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FreeDay"];
    BOOL weekColor = [[colorDay objectAtIndex:indexPath.row] boolValue];
    if (weekColor) {
        cell.dateLabel.textColor = [UIColor redColor];
    }else {
        cell.dateLabel.textColor = [UIColor blackColor];
    }
    cell.cellProtocoll = self;
    cell.dateLabel.text = [calendarDeys objectAtIndex:indexPath.row];
    cell.textRemark.delegate = self;
    cell.textRemark.tag = indexPath.row;
    cell.textRemark.placeholder = [wDayName objectAtIndex:[[weekDayArr objectAtIndex:indexPath.row] integerValue]-1];
    cell.textRemark.text = [remarkArr objectAtIndex:indexPath.row];
    return cell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [remarkArr replaceObjectAtIndex:textField.tag withObject:textField.text];
    return YES;
}

-(void)changaColor:(UIButton *)sender {
    NSLog(@"index %ld",(long)sender.tag);

}
-(void) didPressButton:(FreeDayCell *)theCell{
    NSIndexPath *iPath = [self.tablica indexPathForCell:theCell];
    FreeDayCell* cellCheck = [self.tablica cellForRowAtIndexPath:iPath];
    BOOL weekColor = [[colorDay objectAtIndex:iPath.row] boolValue];
    if (weekColor) {
            [colorDay replaceObjectAtIndex:iPath.row withObject:@NO];
            cellCheck.dateLabel.textColor = [UIColor blackColor];
    }else {
            [colorDay replaceObjectAtIndex:iPath.row withObject:@YES];
            cellCheck.dateLabel.textColor = [UIColor redColor];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return calendarDeys.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedString(@"Holidays", nil);
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSData *theData=[NSKeyedArchiver archivedDataWithRootObject:colorDay];
    [prefs setObject:theData forKey:@"colorDay"];
    theData=[NSKeyedArchiver archivedDataWithRootObject:calendarDeys];
    [prefs setObject:theData forKey:@"calendarDay"];
    theData=[NSKeyedArchiver archivedDataWithRootObject:weekDayArr];
    [prefs setObject:theData forKey:@"weekDay"];
    theData=[NSKeyedArchiver archivedDataWithRootObject:remarkArr];
    [prefs setObject:theData forKey:@"remark"];
    [prefs synchronize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
