//
//  ContentViewController.m
//  praznaPageView
//
//  Created by Anton Orzes on 31/10/2016.
//  Copyright © 2016 Anton Orzes. All rights reserved.
//

#import "ContentViewController.h"

@interface ContentViewController ()
{
    NSString *databasePath;
    sqlite3 *zapisi;
    NSArray *days;
    BOOL deleteSomething;
}
@property (readonly, strong, nonatomic) NSArray *pageData;
@property (readonly, strong, nonatomic) NSArray *pageTekst;
@end

@implementation ContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"zapisi.db"]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    days = [[dateFormatter shortWeekdaySymbols] copy];
    deleteSomething = NO;
    [self loadData];
}

- (void)loadData {
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    NSMutableArray *rData = [[NSMutableArray alloc]init];
    NSMutableArray *rTekst = [[NSMutableArray alloc]init];
    if (sqlite3_open(dbpath, &zapisi) == SQLITE_OK) {
        NSString *querySQL =[NSString stringWithFormat:@"SELECT * FROM biljeske ORDER BY datum ASC"];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(zapisi, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            // Loop through the results and add them to the feeds array
            while(sqlite3_step(statement) == SQLITE_ROW) {
                // citaj podatke iz datoteke i unesi u polja
                NSString *aDatum = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                NSString *aBiljeska = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                // Add the object to the Array
                [rData addObject:aDatum];
                [rTekst addObject:aBiljeska];
            }
            sqlite3_finalize(statement);
            sqlite3_close(zapisi);
        }
    }
    _pageData = rData;
    _pageTekst = rTekst;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCell" forIndexPath:indexPath];
    NSString *dat = [_pageData objectAtIndex:indexPath.row];
    int y = (int)[[dat componentsSeparatedByString:@"."][0] integerValue];
    int m = (int)[[dat componentsSeparatedByString:@"."][1] integerValue];
    int d = (int)[[dat componentsSeparatedByString:@"."][2] integerValue];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:d];
    [comps setMonth:m];
    [comps setYear:y];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date = [calendar dateFromComponents:comps];
    NSString *weekday = [days objectAtIndex:[calendar component:NSCalendarUnitWeekday fromDate:date]-1];
    cell.dateLabel.text = [NSString stringWithFormat:@"%d.%d.%i. %@",d,m,y,weekday];
    cell.tekstLabel.text = [_pageTekst objectAtIndex:indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _pageData.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RootViewController *rvc=[self.storyboard instantiateViewControllerWithIdentifier: @"rootView"];
    rvc.startIndex = (int)indexPath.row;
    [self presentViewController:rvc animated:YES completion:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        deleteSomething = YES;
        NSString *dat = [_pageData objectAtIndex:indexPath.row];
        const char *dbpath = [databasePath UTF8String];
        sqlite3_stmt    *statement;
        if (sqlite3_open(dbpath, &zapisi) == SQLITE_OK) {
            NSString *querySQL =[NSString stringWithFormat: @"DELETE FROM biljeske WHERE datum=\"%@\"",dat];
            const char *query_stmt = [querySQL UTF8String];
            if (sqlite3_prepare_v2(zapisi, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
                NSLog(@"record deleted");
                //array delete
                NSMutableArray *delDate = [NSMutableArray arrayWithArray:_pageData];
                NSMutableArray *delRec = [NSMutableArray arrayWithArray:_pageTekst];
                [delDate removeObjectAtIndex:indexPath.row];
                [delRec removeObjectAtIndex:indexPath.row];
                _pageData = delDate;
                _pageTekst = delRec;
                [_tablica reloadData];
            }
            sqlite3_finalize(statement);
            sqlite3_close(zapisi);
        }
        
    }
}

- (IBAction)goBack:(id)sender {
    if (deleteSomething) {
        ViewController *vc=[self.storyboard instantiateViewControllerWithIdentifier: @"FirstView"];
        [self presentViewController:vc animated:YES completion:nil];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
