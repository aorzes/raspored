//
//  ModelController.m
//  praznaPageView
//
//  Created by Anton Orzes on 25/10/2016.
//  Copyright © 2016 Anton Orzes. All rights reserved.
//

#import "ModelController.h"
#import "DataViewController.h"
#import "sqlite3.h"

/*
 A controller object that manages a simple model -- a collection of month names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */


@interface ModelController ()
{
    NSString *databasePath;
    sqlite3 *zapisi;
}
@property (readonly, strong, nonatomic) NSArray *pageData;
@property (readonly, strong, nonatomic) NSArray *pageTekst;
@end

@implementation ModelController

- (instancetype)init {
    self = [super init];
    if (self) {
        // Create the data model.
        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsDir = [dirPaths objectAtIndex:0];
        databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"zapisi.db"]];
        //NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [self loadData];
    }
    return self;
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

- (DataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard {
    // Return the data view controller for the given index.
    if (([self.pageData count] == 0) || (index >= [self.pageData count])) {
        return nil;
    }

    // Create a new view controller and pass suitable data.
    DataViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:@"DataViewController"];
    dataViewController.dataObject = self.pageData[index];
    dataViewController.tekstObject = self.pageTekst[index];
    dataViewController.pvc = self;
    return dataViewController;
}


- (NSUInteger)indexOfViewController:(DataViewController *)viewController {
    // Return the index of the given data view controller.
    // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
    return [self.pageData indexOfObject:viewController.dataObject];
}


#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(DataViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(DataViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageData count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

@end
