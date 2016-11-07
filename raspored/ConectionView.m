//
//  ConectionView.m
//  raspored
//
//  Created by Anton Orzes on 17/09/16.
//  Copyright © 2016 Anton Orzes. All rights reserved.
//

#import "ConectionView.h"

@interface ConectionView ()
{
    id result;
    id result2;
    BOOL accepted;
    BOOL rstImage;
    BOOL timeChange;
    __weak IBOutlet UIDatePicker *startTime;
    __weak IBOutlet UITextField *periodLegth;
    __weak IBOutlet UITextField *bigBreakAfter1;
    __weak IBOutlet UITextField *bigBreakAfter2;
    __weak IBOutlet UITextField *bigBrakLength;
    
    __weak IBOutlet UIVisualEffectView *visualBoard;
}
@property (nonatomic, strong) NSMutableArray *arrConnectedDevices;
- (void)peerDidChangeStateWithNotification:(NSNotification *)notification;

@end

@implementation ConectionView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[_appDelegate mcManager] setupPeerAndSessionWithDisplayName:[UIDevice currentDevice].name];
    [[_appDelegate mcManager] advertiseSelf:_isVisibleSwitch.isOn];
    [_myName setDelegate:self];
    [periodLegth setDelegate:self];
    [bigBreakAfter1 setDelegate:self];
    [bigBreakAfter2 setDelegate:self];
    [bigBrakLength setDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerDidChangeStateWithNotification:)
                                                 name:@"MCDidChangeStateNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataWithNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];
    _arrConnectedDevices = [[NSMutableArray alloc] init];
    _myName.text = [[UIDevice currentDevice] name];
    accepted = NO;
    timeChange = NO;
    [self loadLessionTime];
}

- (void)viewDidAppear:(BOOL)animated {
    NSError *error = nil;
    result = [NSJSONSerialization JSONObjectWithData: _toSend options: NSJSONReadingMutableContainers error: &error];
    if (!error){
        for (int i=1; i<36; i++) {
            NSString *key = [NSString stringWithFormat:@"p%i",i];
            NSLog(@"%i.%@",i,[result objectForKey:key]);
        }
    }
}


- (IBAction)sendMessage:(id)sender {
    [self sendMyMessage];
}

//send message
- (void)sendMyMessage {
    NSArray *allPeers = _appDelegate.mcManager.session.connectedPeers;
    NSError *error;
    //ovo salje poruku
    [_appDelegate.mcManager.session sendData:_toSend
                                     toPeers:allPeers
                                    withMode:MCSessionSendDataReliable
                                       error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:NSLocalizedString(@"Slanje title", nil)
                                message:NSLocalizedString(@"Poslani title", nil)
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

//primanje podataka
- (void)didReceiveDataWithNotification:(NSNotification *)notification {
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    _receivedData = [[notification userInfo] objectForKey:@"data"];
    NSError *error = nil;
    result2 = [NSJSONSerialization JSONObjectWithData: _receivedData options: NSJSONReadingMutableContainers error: &error];
    if (!error){
        for (int i=1; i<36; i++) {
            NSString *key = [NSString stringWithFormat:@"p%i",i];
            NSLog(@"%i.%@",i,[result2 objectForKey:key]);
        }
        [self showRecive:peerDisplayName];
    }
}

- (void)showRecive:(NSString *)displayName {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:NSLocalizedString(@"Novi title", nil)
                                message:NSLocalizedString(@"Novi message", nil)
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:NSLocalizedString(@"Prihvati title", nil)
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             accepted = YES;
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"Odbaci title", nil)
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.tag == 0) {
        double yp =  200;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.7];
        visualBoard.center = CGPointMake(visualBoard.center.x, yp);
        [UIView commitAnimations];
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 1) {
        [_myName resignFirstResponder];
        _appDelegate.mcManager.peerID = nil;
        _appDelegate.mcManager.session = nil;
        _appDelegate.mcManager.browser = nil;
        if ([_isVisibleSwitch isOn]) {
            [_appDelegate.mcManager.advertiser stop];
        }
        _appDelegate.mcManager.advertiser = nil;
        [_appDelegate.mcManager setupPeerAndSessionWithDisplayName:_myName.text];
        [_appDelegate.mcManager setupMCBrowser];
        [_appDelegate.mcManager advertiseSelf:_isVisibleSwitch.isOn];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

- (IBAction)toggleVisibility:(id)sender {
    [_appDelegate.mcManager advertiseSelf:_isVisibleSwitch.isOn];
}

- (void)peerDidChangeStateWithNotification:(NSNotification *)notification {
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    if (state != MCSessionStateConnecting) {
        if (state == MCSessionStateConnected) {
            [_arrConnectedDevices addObject:peerDisplayName];
        }
        else if (state == MCSessionStateNotConnected){
            if ([_arrConnectedDevices count] > 0) {
                int indexOfPeer = (int)[_arrConnectedDevices indexOfObject:peerDisplayName];
                [_arrConnectedDevices removeObjectAtIndex:indexOfPeer];
            }
        }
        BOOL peersExist = ([[_appDelegate.mcManager.session connectedPeers] count] == 0);
        [_myName setEnabled:peersExist];
    }
}

- (void)disconect {
    [_appDelegate.mcManager.session disconnect];
    _myName.enabled = YES;
    [_arrConnectedDevices removeAllObjects];
}

- (IBAction)browseForDevice:(id)sender {
    [[_appDelegate mcManager] setupMCBrowser];
    [[[_appDelegate mcManager] browser] setDelegate:self];
    [self presentViewController:[[_appDelegate mcManager] browser] animated:YES completion:nil];
}

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    [_appDelegate.mcManager.browser dismissViewControllerAnimated:YES completion:nil];
}


- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    [_appDelegate.mcManager.browser dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)resetImage:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *s = @"YES";
    [prefs setObject:s forKey:@"rstImage"];
    [prefs synchronize];
}

-(void)loadLessionTime {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *sh = [prefs stringForKey:@"startHour"];
    NSString *sm = [prefs stringForKey:@"startMinute"];
    if (!sh) {
        sh = @"8";
        sm = @"0";
    }
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:
                                    (NSCalendarUnitHour | NSCalendarUnitMinute )
                                               fromDate:startTime.date];

    [components setHour:[sh integerValue]];
    [components setMinute:[sm integerValue]];
    NSDate * date = [calendar dateFromComponents:components];
    [startTime setDate:date];
    
    bigBrakLength.text = [prefs stringForKey:@"bigBreak"];
    bigBreakAfter1.text = [prefs stringForKey:@"bigBreak1After"];
    bigBreakAfter2.text = [prefs stringForKey:@"bigBreak2After"];
    periodLegth.text = [prefs stringForKey:@"lessonLength"];
}

- (IBAction)showEmail:(id)sender {
    // Email Subject
    NSString *emailTitle = @"";
    // Email Content
    NSString *messageBody = @"<table border=1>";
    NSError *error = nil;
    result = [NSJSONSerialization JSONObjectWithData: _toSend options: NSJSONReadingMutableContainers error: &error];
    int n=1;
    NSString *a[5][7];
    for (int i=0; i<5; i++) {
        for (int j=0; j<7; j++) {
            NSString *key = [NSString stringWithFormat:@"p%i",n];
            NSString *s = [result objectForKey:key];
            if (s.length==0) {
                s=@" ";
            }
            a[i][j] = s;
            n++;
        }
    }
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setLocale: [NSLocale currentLocale]];
    NSArray * day = [df shortWeekdaySymbols];
    messageBody = [messageBody stringByAppendingString:@"<tr><td></td>"];
    for (int i=0; i<5; i++) {
        messageBody = [NSString stringWithFormat:@"%@<td>%@</td>",messageBody,[[day objectAtIndex:i+1]capitalizedString]];
    }
    messageBody = [messageBody stringByAppendingString:@"</tr>"];
    for (int i=0; i<7; i++) {
        messageBody = [messageBody stringByAppendingString:[NSString stringWithFormat:@"%@%i%@",@"<tr><td>",i+1,@".</td>"]];
        for (int j=0; j<5; j++) {
            messageBody = [NSString stringWithFormat:@"%@<td>%@</td>",messageBody,a[j][i]];
        }
        messageBody = [messageBody stringByAppendingString:@"</tr>"];
    }
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@""];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:YES];
    [mc setToRecipients:toRecipents];
    // Present mail view controller on screen
    if ([MFMailComposeViewController canSendMail]){
        [self presentViewController:mc animated:YES completion:NULL];
    }
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)resultM error:(NSError *)error
{
    switch (resultM)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    ViewController *svc = [segue.self destinationViewController];
    svc.receivedData2 = result2;
    svc.acceptedData = accepted;

    //save lession time
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:
                                    (NSCalendarUnitHour | NSCalendarUnitMinute )
                                               fromDate:startTime.date];
    NSString *lessonLength = periodLegth.text;
    NSString *bigBreak = bigBrakLength.text;
    NSString *bigBreak1After = bigBreakAfter1.text;
    NSString *bigBreak2After = bigBreakAfter2.text;

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:[NSString stringWithFormat:@"%ld",(long)components.hour] forKey:@"startHour"];
    [prefs setObject:[NSString stringWithFormat:@"%ld",(long)components.minute] forKey:@"startMinute"];
    [prefs setObject:lessonLength forKey:@"lessonLength"];
    [prefs setObject:bigBreak forKey:@"bigBreak"];
    [prefs setObject:bigBreak1After forKey:@"bigBreak1After"];
    [prefs setObject:bigBreak2After forKey:@"bigBreak2After"];
    [prefs synchronize];
    [self disconect];
}

@end
