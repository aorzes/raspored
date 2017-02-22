//
//  KalendarController.m
//  raspored
//
//  Created by Anton Orzes on 31/10/2016.
//  Copyright © 2016 Anton Orzes. All rights reserved.
//

#import "KalendarController.h"

@interface KalendarController ()
{
    NSMutableArray *month;
    NSMutableArray *monthNum;
    NSMutableArray *monthViewArr;
    NSMutableArray *colorDay;
    NSMutableArray *workWeekNumbers;
    BOOL colorExist;
    BOOL weekExist;
    int workWeek;
    int dayNum;
    int nowDay;
    int nowMonth;
    NSString *oldStartYear;
    __weak IBOutlet UITableView *tablica;
    __weak IBOutlet UITextField *startYear;
    //database
    sqlite3 *zapisi;
    NSString *databasePath;
    NSMutableArray *someDate;
    
}
@end

@implementation KalendarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    someDate = [[NSMutableArray alloc]init];
    workWeekNumbers = [[NSMutableArray alloc]init];
    startYear.delegate = self;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *s = [prefs stringForKey:@"startYear"];
    if (s.length>0) {
        startYear.text = s;
    }else {
        startYear.text = @"2016";
    }
    NSData *weekData = [prefs dataForKey:@"workWeekNumbers"];
    if (!weekData) {
        weekExist = NO;
    }else {
        weekExist = YES;
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:weekData];
        workWeekNumbers = [NSMutableArray arrayWithArray:array];
    }
    NSDate *now = [NSDate date];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:now];
    nowDay = (int)[components day];
    nowMonth = (int)[components month];
    
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)viewDidAppear:(BOOL)animated {
    [self openBase];
    [self ucitaj];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSData *colorData = [prefs dataForKey:@"colorDay"];
    colorExist = NO; // je li ucitana boja dana - praznici
    if (colorData) {
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
        colorDay = [NSMutableArray arrayWithArray:array];
        colorExist = YES;
    }
    dayNum = 0;
    [self makeKalendar];
    
}

- (void)makeKalendar {
    workWeek = 1;
    month = [[NSMutableArray alloc]init];
    monthViewArr = [[NSMutableArray alloc]init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSArray *months = [[dateFormatter shortMonthSymbols] copy];
    //NSDate *pickerDate = [startData date];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];          //start day
    [comps setDay:1];
    [comps setMonth:9];
    NSString *sYear = startYear.text;
    int y = (int)[sYear integerValue];
    [comps setYear:y];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *startDate = [calendar dateFromComponents:comps];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:startDate];
    monthNum = [[NSMutableArray alloc]init];
    int startMonth =(int) [components month]-1;
    int startYearInt = (int) [components year];
    for(int i=startMonth;i<12;i++){
        NSString *mounthString = [NSString stringWithFormat:@" %@. (%d.)",[months objectAtIndex:i],i+1];
        [month addObject:mounthString];
        NSNumber* mNum = [NSNumber numberWithInt:i];
        [monthNum addObject:mNum];
        [monthViewArr addObject:[self makeDaysLabel:i+1 year:startYearInt]];
    }
    for(int i=0;i<startMonth;i++){
        NSString *mounthString = [NSString stringWithFormat:@" %@. (%d.)",[months objectAtIndex:i],i+1];
        [month addObject:mounthString];
        NSNumber* mNum = [NSNumber numberWithInt:i];
        [monthNum addObject:mNum];
        [monthViewArr addObject:[self makeDaysLabel:i+1 year:startYearInt+1]];
    }
    [tablica reloadData];
    //scroll to month
    CGFloat needScroll = nowMonth - 9;
    if (needScroll<0) {
        needScroll += 12;
    }
    [tablica setContentOffset:CGPointMake(0, 230 * needScroll)];//scrolaj za po 230 za svaki mjesec
}

- (UIView *)makeDaysLabel:(int)monthD year:(int)yearD {
    //    NSDate *today = [NSDate date]; //Get a date object for today's date
    //    NSCalendar *c = [NSCalendar currentCalendar];
    //    NSRange days1 = [c rangeOfUnit:NSDayCalendarUnit
    //                           inUnit:NSMonthCalendarUnit forDate:today];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:1];
    [comps setMonth:monthD];
    [comps setYear:yearD];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date = [calendar dateFromComponents:comps];
    NSInteger weekday = [calendar component:NSCalendarUnitWeekday fromDate:date]-1;
    //NSLog(@"%d.%d. weekday:%ld",monthD,yearD,(long)weekday);
    NSRange lastDay = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    UIView *daysView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 250)];
    //daysView.backgroundColor = [UIColor whiteColor];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSArray *days = [[dateFormatter shortWeekdaySymbols] copy];
    double lPosition = 25;
    double lSize = (tablica.frame.size.width - 50) / 7;
    for (int i=0; i<7; i++) {
        UILabel *label = [[UILabel alloc]init];
        label.frame = CGRectMake(lPosition, 0, lSize, 20); //veličina i pozicija labele
        label.text = [[days objectAtIndex:i]capitalizedString]; //dani u tjednu
        label.textAlignment = NSTextAlignmentCenter; //tekst je centriran
        label.font = [UIFont systemFontOfSize:12.0];
        label.layer.borderWidth = 0.5; //labela ima obrub
        label.layer.backgroundColor = [UIColor whiteColor].CGColor;
        label.textColor = [UIColor blackColor]; //boja fonta
        label.backgroundColor = [UIColor clearColor];
        [daysView addSubview:label];
        lPosition += lSize+2;
    }
    double tPosition = 0;
    lPosition = 25+(lSize+2) * weekday;
    int n = (int)weekday;
    for (int i=0; i<lastDay.length; i++) {
        if(n%7==0 || i==0){
            if(i>0) {lPosition = 25;n=0;}
            tPosition += 27;
            //radni tjedan
            UIButton *weekNumButton = [[UIButton alloc]init];
            weekNumButton.frame = CGRectMake(-5, tPosition, 22, 22);
            if (weekExist) {
                int wn = (int)[[workWeekNumbers objectAtIndex:workWeek-1] integerValue];
                [weekNumButton setTitle:[NSString stringWithFormat:@"%d",wn] forState:UIControlStateNormal];
                if (wn==0) {
                    [weekNumButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                } else {
                    [weekNumButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }
            }else {
                [weekNumButton setTitle:[NSString stringWithFormat:@"%d",workWeek] forState:UIControlStateNormal];
                [weekNumButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
            weekNumButton.tag = 1000;
            weekNumButton.showsTouchWhenHighlighted = YES;
            [weekNumButton addTarget:self action:@selector(workWeekSelect:) forControlEvents:UIControlEventTouchUpInside];
            weekNumButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
            weekNumButton.layer.borderWidth = 1;
            weekNumButton.layer.cornerRadius = 10;
            weekNumButton.layer.backgroundColor = [UIColor whiteColor].CGColor;
            [daysView addSubview:weekNumButton];
            [workWeekNumbers addObject:[NSNumber numberWithInt:workWeek]];
            workWeek++;
        }
        //dani u kalendaru - button
        UIButton *dayButton = [[UIButton alloc] init];
        dayButton.frame = CGRectMake(lPosition, tPosition, lSize, 20);
        [dayButton setTitle:[NSString stringWithFormat:@"%d",i+1] forState:UIControlStateNormal];
        dayButton.tag = monthD;
        long year = (long)[startYear.text integerValue];
        if (monthD<9) {
            year++;
        }
        //ima li datum u bazi
        NSString *dateString = [NSString stringWithFormat:@"%ld.%02d.%02d.",year, monthD, i+1];
        if ([someDate containsObject: dateString]){
            [dayButton setBackgroundColor:[UIColor yellowColor]];
        } else {
            [dayButton setBackgroundColor:[UIColor clearColor]];
        }
        dayButton.showsTouchWhenHighlighted = YES;
        [dayButton addTarget:self action:@selector(addData:) forControlEvents:UIControlEventTouchUpInside];
        dayButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
        if (n==0 || n==6) {
            [dayButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }else {
            [dayButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        if (colorExist && dayNum<colorDay.count) {
            if ([[colorDay objectAtIndex:dayNum] boolValue]) {
                [dayButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            }
        }
        if (nowDay == i+1 && nowMonth == monthD ) {
            dayButton.layer.borderWidth = 1;
        } else {
            dayButton.layer.borderWidth = 0;
        }
        dayNum++;
        [daysView addSubview:dayButton];
        n++;
        lPosition += lSize+2;
    }
    return daysView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"KalendarCell";
    KalendarCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    cell.monthLabel.text = [month objectAtIndex:indexPath.row];
    [[cell.monthView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [cell.monthView addSubview:[monthViewArr objectAtIndex:indexPath.row]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [monthViewArr count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedString(@"Školska godina", nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"tip %ld",(long)indexPath.row);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 230;
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    oldStartYear = startYear.text;
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    //save start year
    
    NSString *sYear = startYear.text;
    int y = (int)[sYear integerValue];
    if (y<2010 || y>2037) {
        startYear.text = oldStartYear;
        return YES;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:sYear forKey:@"startYear"];
    [userDefaults synchronize];
    [self makeKalendar];
    return YES;
}

- (void)workWeekSelect:(UIButton *)sender {
    int n=0;
    int wIndex = 0;
    //NSLog(@"work week: %f",sender.center.y);
    if ((int)[sender.titleLabel.text integerValue]==0) {
        [sender setTitle:[NSString stringWithFormat:@"%d",1] forState:UIControlStateNormal];
    } else {
        [sender setTitle:[NSString stringWithFormat:@"%d",0] forState:UIControlStateNormal];
    }
    for (UIView *mw in monthViewArr) {
        //NSLog(@"mw:%@",mw.description);
        for(UIButton *wwb in mw.subviews) {
            if ([wwb isKindOfClass:[UIButton class]] && wwb.tag == 1000){
                int m = (int)[wwb.titleLabel.text integerValue];
                if (m>0) {
                    n++;
                    [wwb setTitle:[NSString stringWithFormat:@"%d",n] forState:UIControlStateNormal];
                    [wwb setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [workWeekNumbers replaceObjectAtIndex:wIndex withObject:[NSNumber numberWithInt:n]];
                } else {
                    [wwb setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                    [workWeekNumbers replaceObjectAtIndex:wIndex withObject:[NSNumber numberWithInt:0]];
                }
                wIndex++;
            }
        }
    }
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSData *theData=[NSKeyedArchiver archivedDataWithRootObject:workWeekNumbers];
    [prefs setObject:theData forKey:@"workWeekNumbers"];
    [prefs synchronize];
    
}
/*
- (void)daySelected:(UIButton *)sender {
    NSLog(@"month %ld",(long)sender.tag);
    NSLog(@"day %@",sender.titleLabel.text);
    someDate = [[NSMutableArray alloc]init];
    
    
}
 */
//data base part ************************
- (void)openBase {
    //dbase create
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"zapisi.db"]];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO) {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &zapisi) == SQLITE_OK) {
            char *errMsg;
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS biljeske (ID INTEGER PRIMARY KEY AUTOINCREMENT, datum TEXT, zapis TEXT)";
            if (sqlite3_exec(zapisi, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
                NSLog(@"Failed to create table");
            }else {
                NSLog(@"Table create");
            }
            sqlite3_close(zapisi);
        } else {
            NSLog(@"Failed to open/create database");
        }
    }
}

- (void)saveData:(NSString *)sDate {
    
    sqlite3_stmt    *statement;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &zapisi) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO biljeske (datum, zapis) VALUES (\"%@\",  \"%@\")",sDate, @""];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(zapisi, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            NSLog(@"Record added");
        }else {
            NSLog(@"Error");
        }
        sqlite3_finalize(statement);
        sqlite3_close(zapisi);
    }
}
//add new to dBase
- (IBAction)addData:(UIButton *)sender {
    long day = (long)[sender.titleLabel.text integerValue];
    long monthl = (long)sender.tag;
    long year = (long)[startYear.text integerValue];
    if (monthl<9) {
        year++;
    }
    NSString *dateString = [NSString stringWithFormat:@"%ld.%02ld.%02ld.",year, monthl, day];
    //NSLog(@"weekday: %ld",[self weekInt:day month:monthl year:year]);
    //_dataLabel.text = dateString;
    NSInteger anIndex = 0; //stranica koja ce se otvoriti
    //NSLog(@"INDEX: %ld",(long)anIndex);
    //NSLog(@"-----");
    if (![someDate containsObject: dateString]){
        [someDate addObject:dateString];
        [self saveData:dateString];
        //NSArray *someArray = [someDate sortedArrayUsingSelector:@selector (compare:)];
        NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self" ascending: YES];
        NSArray *someArray = [someDate sortedArrayUsingDescriptors: [NSArray arrayWithObject: sortOrder]];
        anIndex=[someArray indexOfObject:dateString];
        for (int i=0; i<someArray.count; i++) {
            //NSDate *d = [someArray objectAtIndex:i];
            //NSLog(@"%@",d);
        }
    } else {
        //NSLog(@"to ima");
        anIndex=[someDate indexOfObject:dateString];
        
    }
    [self goToSecond:anIndex];
}

- (NSInteger)weekInt:(long)dayw month:(long)monthw year:(long)yearw {
    NSDateComponents *comps = [[NSDateComponents alloc] init];          //start day
    [comps setDay:dayw];
    [comps setMonth:monthw];
    [comps setYear:yearw];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *startDate = [calendar dateFromComponents:comps];
    NSInteger weekInt = [calendar component:NSCalendarUnitWeekday fromDate:startDate];
    return weekInt;
}


- (void)goToSecond:(NSInteger)selIndex {
    RootViewController *rvc=[self.storyboard instantiateViewControllerWithIdentifier: @"rootView"];
    rvc.startIndex = (int)selIndex;
    [self presentViewController:rvc animated:YES completion:nil];
    
}

-(void) ucitaj {
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    [someDate removeAllObjects];
    if (sqlite3_open(dbpath, &zapisi) == SQLITE_OK) {
        NSString *querySQL =[NSString stringWithFormat:@"SELECT * FROM biljeske ORDER BY datum ASC"];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(zapisi, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            // Loop through the results and add them to the feeds array
            while(sqlite3_step(statement) == SQLITE_ROW) {
                // citaj podatke iz datoteke i unesi u polja
                //NSString *aIndeks = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
                NSString *aDatum = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                //NSString *aBiljeska = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                // Add the object to the Array
                [someDate addObject:aDatum];
            }
            sqlite3_finalize(statement);
            sqlite3_close(zapisi);
        }
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)goBack:(id)sender {
   // [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
