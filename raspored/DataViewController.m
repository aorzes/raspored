//
//  DataViewController.m
//  praznaPageView
//
//  Created by Anton Orzes on 25/10/2016.
//  Copyright © 2016 Anton Orzes. All rights reserved.
//

#import "DataViewController.h"
#import "ModelController.h"
#import "sqlite3.h"

@interface DataViewController ()
{
    NSString *databasePath;
    sqlite3 *zapisi;
    NSString *sDate;
}

@end

@implementation DataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.dataText.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *dat = [self.dataObject description];
    NSString *y = [dat componentsSeparatedByString:@"."][0];
    NSString *m = [dat componentsSeparatedByString:@"."][1];
    NSString *d = [dat componentsSeparatedByString:@"."][2];
    self.dataLabel.text = [NSString stringWithFormat:@"%@.%@.%@.",d,m,y];
    self.dataText.text = [self.tekstObject description];
    sDate = [self.dataObject description];
}

- (IBAction)saveData:(id)sender {
    NSLog(@"To je save");
    [self.dataText resignFirstResponder];
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"zapisi.db"]];
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    NSString *sZapis = self.dataText.text;
    if (sqlite3_open(dbpath, &zapisi) == SQLITE_OK)
    {
        NSString *updateSQL = [NSString stringWithFormat: @"UPDATE biljeske SET zapis=\"%@\" WHERE datum=\"%@\"",sZapis, sDate];
        const char *insert_stmt = [updateSQL UTF8String];
        sqlite3_prepare_v2(zapisi, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            NSLog(@"Record updated");
        }else {
            NSLog(@"Error");
        }
        sqlite3_finalize(statement);
        sqlite3_close(zapisi);
    }
    ModelController *mc = _pvc;
    [mc loadData];
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    //handle user taps text view to type text
    _dataText.frame = CGRectMake(_dataText.frame.origin.x, _dataText.frame.origin.y, _dataText.frame.size.width, _viewForRecord.frame.size.height-250);
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    _dataText.frame = CGRectMake(_dataText.frame.origin.x, _dataText.frame.origin.y, _dataText.frame.size.width, _viewForRecord.frame.size.height-40);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
