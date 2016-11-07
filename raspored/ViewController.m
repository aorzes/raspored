//
//  ViewController.m
//  raspored
//
//  Created by Anton Orzes on 28/06/16.
//  Copyright © 2016 Anton Orzes. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    UIImageView *bottomView;
    UIImageView *baseView;
    UIImageView *redDot;
    UIImageView *clockView;
    UIImageView *digitalClockView;
    UIImageView *clockTouchView;
    CGFloat skala;
    NSArray *color;
    UIView *viewColor;
    UITextField *tf;
    double endLessonY;
    double endLessonX;
    double lWidth;
    double redDotY;
    CGSize beginSize;
    NSMutableArray *days;
    NSMutableDictionary *sendDictionary;
    int lessons;
    float currentLessionTime;
    NSMutableArray *periodTime;
    NSString *lessonStartEnd;
    int clockState;
    DigitalClock *dClock;
    
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *appController = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appController.saveDelegate = self;
    _acceptedData = NO;
    _resetImage = NO;
    NSLog(@"broj sati je: %ld",[self preLoad]);
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)saveOnClosing {
    [self save];
}

- (void)viewDidAppear:(BOOL)animated {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *s = [prefs stringForKey:@"rstImage"];
    
    if ([s isEqualToString:@"YES"]) {
        _resetImage = YES;
    }
    if (baseView) {
        //NSLog(@"vec je ucitano");
        if (_resetImage) {
             bottomView.image = [UIImage imageNamed:@"blueDesk"];
        }
        [self loadLessionTime];
        return;
    }
    clockState = 0;
    CGSize mainSize = self.view.frame.size;
    lWidth = mainSize.width/6;
    double lPosition = lWidth/2;
    lessons = 7;
    redDotY = 0;
    
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setLocale: [NSLocale currentLocale]];
    NSArray * day = [df shortWeekdaySymbols];
    color = [NSArray arrayWithObjects:
             [UIColor colorWithRed:(float)255/255 green:0.0 blue:0.0 alpha:1],
             [UIColor colorWithRed:(float)255/255 green:(float)102/255 blue:(float)102/255 alpha:1],
             [UIColor colorWithRed:(float)255/255 green:(float)153/255 blue:(float)153/255 alpha:1],
             [UIColor colorWithRed:(float)255/255 green:(float)214/255 blue:(float)0.0 alpha:1],
                [UIColor colorWithRed:(float)255/255 green:(float)140/255 blue:(float)0/255 alpha:1],
                [UIColor colorWithRed:(float)255/255 green:(float)178/255 blue:(float)102/255 alpha:1],
                [UIColor colorWithRed:(float)255/255 green:(float)204/255 blue:(float)153/255 alpha:1],
                [UIColor colorWithRed:(float)255/255 green:(float)255/255 blue:(float)0.0 alpha:1],
             [UIColor colorWithRed:(float)0/255 green:(float)255/255 blue:(float)0/255 alpha:1],
             [UIColor colorWithRed:(float)104/255 green:(float)175/255 blue:(float)31/255 alpha:1],
             [UIColor colorWithRed:(float)204/255 green:(float)255/255 blue:(float)105/255 alpha:1],
             [UIColor colorWithRed:(float)229/255 green:(float)255/255 blue:(float)204/255 alpha:1],
                [UIColor colorWithRed:(float)51/255 green:(float)255/255 blue:(float)255/255 alpha:1],
                [UIColor colorWithRed:(float)255/255 green:(float)53/255 blue:(float)255/255 alpha:1],
                [UIColor colorWithRed:(float)155/255 green:(float)153/255 blue:(float)255/255 alpha:1],
                [UIColor colorWithRed:1 green:1 blue:1 alpha:1],
             nil];
    beginSize = CGSizeMake(mainSize.width,  mainSize.height);
    bottomView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, beginSize.width, beginSize.height)];
    [self.view addSubview:bottomView];
    [self loadBottomSelectedImage];
    if (!bottomView.image || _resetImage) {
        bottomView.image = [UIImage imageNamed:@"blueDesk"];
    }
    baseView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, beginSize.width, beginSize.height)];
    baseView.userInteractionEnabled = YES;
    baseView.multipleTouchEnabled = YES;
    [self.view addSubview:baseView];
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoomMeIn:)];
    [baseView addGestureRecognizer:pinch];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(paneMe:)];
    [baseView addGestureRecognizer:pan];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(returnToNormal:)];
    doubleTap.numberOfTapsRequired = 2;
    [baseView addGestureRecognizer:doubleTap];
    
//dani u tjednu
    days = [[NSMutableArray alloc]init];
    for (int i=0; i<5; i++) {
        UILabel *label = [[UILabel alloc]init];
        label.frame = CGRectMake(lPosition, 0, lWidth, 40); //veličina i pozicija labele
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = label.bounds;
        //(id)[[UIColor colorWithWhite:1 alpha:1] CGColor],
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor],
                                                    (id)[[UIColor colorWithWhite:0 alpha:0.2] CGColor],
                                                    (id)[[UIColor clearColor] CGColor],
                                                    (id)[[UIColor colorWithWhite:0 alpha:0.3] CGColor],
                                                    (id)[[UIColor colorWithWhite:0 alpha:0.4] CGColor], nil];
        [label.layer addSublayer:gradient];
        gradient.masksToBounds = YES;
        label.text = [[day objectAtIndex:i+1]capitalizedString]; //dani u tjednu
        label.textAlignment = NSTextAlignmentCenter; //tekst je centriran
        label.layer.borderWidth = 1; //labela ima obrub
        label.layer.backgroundColor = [UIColor cyanColor].CGColor;
        label.textColor = [UIColor whiteColor]; //boja fonta
        label.backgroundColor = [UIColor clearColor];
        label.shadowColor = [UIColor blackColor]; //boja sjene
        label.shadowOffset = CGSizeMake(2, 2);
        label.layer.cornerRadius = 5;
        [baseView addSubview:label];
        [days addObject:label];
        lPosition += lWidth+2;
    }
//redni broj sata 1-7
    double vPosition = 40;
    for (int i = 0; i<lessons; i++) {
        UILabel *lessonsNum = [[UILabel alloc]init];
        lessonsNum.frame = CGRectMake(0, vPosition, 40, 40); //veličina i pozicija labele
        lessonsNum.text = [NSString stringWithFormat:@" %i.",i+1]; //broj sata
        lessonsNum.tag = 100 + i;
        lessonsNum.textAlignment = NSTextAlignmentLeft; //tekst je lijevo
        lessonsNum.layer.borderWidth=0.5; //labela ima obrub
        lessonsNum.textColor = [UIColor whiteColor]; //boja fonta
        lessonsNum.backgroundColor = [UIColor clearColor];
        lessonsNum.shadowColor = [UIColor blackColor]; //boja sjene
        lessonsNum.shadowOffset = CGSizeMake(2, 2);
        lessonsNum.layer.cornerRadius = 10;
        [baseView addSubview:lessonsNum];
        vPosition += 40;

    }
//redDot pokazuje dokle je došlo (vrijeme)
    redDot = [[UIImageView alloc]init];
    redDot.frame = CGRectMake(0,0,10, 10);
    redDot.center = CGPointMake(20, redDotY);
    redDot.layer.backgroundColor = [UIColor redColor].CGColor;
    redDot.layer.borderColor = [UIColor whiteColor].CGColor;
    redDot.layer.borderWidth = 1;
    redDot.layer.cornerRadius = 5;
    [baseView addSubview:redDot];
//raspored-textField za unos/prikaz
    double tPositionX = lWidth/2;
    double tPositionY = 40;
    for (int i = 0; i<5*lessons; i++) {
        UITextField *txt = [[UITextField alloc]init];
        txt.frame = CGRectMake(tPositionX, tPositionY, lWidth, 40); //veličina i pozicija texta
        txt.layer.borderWidth = 0.5;
        txt.textAlignment = NSTextAlignmentCenter;
        txt.backgroundColor = [UIColor whiteColor];
        txt.adjustsFontSizeToFitWidth = YES;
        txt.minimumFontSize = 4;
        txt.layer.cornerRadius = 5;
        txt.tag = i+1;
        txt.delegate = self;
        [baseView addSubview:txt];

        tPositionY += 40;
        endLessonX = tPositionX;
        endLessonY = tPositionY;
        if ((i+1)%lessons==0 ) {
            tPositionY = 40;
            tPositionX += lWidth+2;
        }
    }
    
//tipka za sliku podloge
    CGRect selectImageFrame = CGRectMake(5, mainSize.height-50, (mainSize.width-10)/4, 40);
    [self makeButton:NSLocalizedString(@"Slika title", nil) withFrame:selectImageFrame andTarget:@selector(openImage:)];
//tipka za brisanje
    CGRect clearButtonFrame = CGRectMake(selectImageFrame.origin.x+selectImageFrame.size.width,selectImageFrame.origin.y,
                                         selectImageFrame.size.width, selectImageFrame.size.height);
    [self makeButton:NSLocalizedString(@"Obrisi title", nil) withFrame:clearButtonFrame andTarget:@selector(clearAll)];
//tipka za slanje/primanje/postavke
    CGRect comunicateButtonFrame = CGRectMake(clearButtonFrame.origin.x+clearButtonFrame.size.width,selectImageFrame.origin.y,
                                              selectImageFrame.size.width, selectImageFrame.size.height);
    [self makeButton:NSLocalizedString(@"Postavke title", nil) withFrame:comunicateButtonFrame andTarget:@selector(onSecondView)];
//tipka info
    CGRect infoButtonFrame = CGRectMake(comunicateButtonFrame.origin.x+comunicateButtonFrame.size.width,
                                        selectImageFrame.origin.y,
                                        selectImageFrame.size.width, selectImageFrame.size.height);
    [self makeButton:NSLocalizedString(@"Info title", nil) withFrame:infoButtonFrame andTarget:@selector(showInfo)];
    
//izbornik boja
    double sizeB = mainSize.width/9;
    viewColor = [[UIView alloc]init];
    viewColor.frame = CGRectMake(endLessonX+lWidth-sizeB*4, endLessonY + 10, sizeB*4, sizeB*4);
    viewColor.backgroundColor = [UIColor clearColor];
    viewColor.layer.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
    viewColor.layer.cornerRadius = sizeB/3;
    [baseView addSubview:viewColor];
    int n = 0;
    for (int i=0; i<4; i++) {
        for (int j=0; j<4; j++) {
            UIView *cbutton = [[UIView alloc]initWithFrame:CGRectMake(i*sizeB, j*sizeB, sizeB, sizeB)];
            cbutton.layer.borderColor = [UIColor blackColor].CGColor;
            cbutton.backgroundColor = [UIColor whiteColor];
            cbutton.layer.borderWidth = 1;
            cbutton.layer.cornerRadius = sizeB/3;
            cbutton.backgroundColor = color[n];
            [viewColor addSubview:cbutton];
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(colorSelected:)] ;
            singleTap.numberOfTapsRequired = 1;
            [cbutton addGestureRecognizer:singleTap];
            n++;
        }
    }
//dan u tjednu
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekday fromDate:now];
    NSInteger weekd = components.weekday-2;
    //NSLog(@"dan u tjednu: %li",weekd);
    if (weekd>=0 && weekd<days.count) {
        UILabel *label =[days objectAtIndex:weekd];
        label.layer.backgroundColor = [UIColor redColor].CGColor;
        
    }
//sat
    [self makeClock:CGPointMake(0, viewColor.frame.origin.y-10)];
    [self load];
//redDot sat
    [self loadLessionTime];
    [self moveRedDot];
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(moveRedDot) userInfo:nil repeats:YES];
}

- (void)makeButton:(NSString *)title withFrame:(CGRect)rectangle andTarget:(SEL)target {
    UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    selectButton.frame = rectangle;
    [selectButton setTitle:title forState:UIControlStateNormal];
    selectButton.layer.borderWidth = 1;
    selectButton.layer.cornerRadius = 10;
    [selectButton setTintColor:[UIColor whiteColor]];
    selectButton.titleLabel.numberOfLines = 1;
    selectButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    selectButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
    selectButton.titleLabel.shadowOffset = CGSizeMake(2, 2);//sjena teksta
    [selectButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    [selectButton addTarget:self action:target forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:selectButton];
}

- (void)makeClock:(CGPoint)clockPoint {
    CGSize cSize = CGSizeMake(lWidth*3, lWidth*3);
    Clock *clock = [[Clock alloc]initWithPosition:CGPointMake(0, 0) andSize: cSize];
    dClock = [[DigitalClock alloc]initWithPosition:CGPointMake(0, 0) andSize: cSize];
    clockView = [[UIImageView alloc]init];
    clockView.frame = CGRectMake(clockPoint.x, clockPoint.y, cSize.width, cSize.height);
    clockView.backgroundColor = [UIColor clearColor];
    digitalClockView = [[UIImageView alloc]init];
    digitalClockView.frame = CGRectMake(clockPoint.x, clockPoint.y, cSize.width, cSize.height);
    digitalClockView.backgroundColor = [UIColor clearColor];
    digitalClockView.alpha = 0;
    clockTouchView = [[UIImageView alloc]init];
    clockTouchView.frame = CGRectMake(clockPoint.x, clockPoint.y, cSize.width, cSize.height);
    clockTouchView.backgroundColor = [UIColor clearColor];
    clockTouchView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                            action:@selector(changeClock)];
    [clockTouchView addGestureRecognizer:tapRecognizer];

    [baseView addSubview:clockView];
    [baseView addSubview:digitalClockView];
    [baseView addSubview:clockTouchView];
    [clockView addSubview:clock];
    [digitalClockView addSubview:dClock];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSData *bcData = [prefs objectForKey:@"dClockColor"];
    UIColor *dc = [NSKeyedUnarchiver unarchiveObjectWithData:bcData];
    if (dc) {
        dClock.dColor = dc;
    }
}

- (void)changeClock {
    clockState++;
    if (clockState>2) {
        clockState = 0;
    }
    switch (clockState) {
        case 0:
            clockView.alpha = 1;
            digitalClockView.alpha = 0;
            break;
        case 1:
            clockView.alpha = 0;
            digitalClockView.alpha = 1;
            break;
        case 2:
            clockView.alpha = 0;
            digitalClockView.alpha = 0;
            break;
        default:
            break;
    }
}

//red dot
- (void)moveRedDot {
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:
                                    (NSCalendarUnitHour | NSCalendarUnitMinute)
                                    fromDate:now];
    NSInteger hour = components.hour;
    NSInteger minute = components.minute;
    
    float localTime = ((hour*60+minute));//-(_statHour*60+_startMinute));
    redDotY = 0;
    redDot.center = CGPointMake(25, redDotY);
    for (int i=0; i<lessons; i++) {
        if (localTime>= [periodTime[i][0] floatValue] && localTime< [periodTime[i][1] floatValue]) {
            redDot.layer.backgroundColor = [UIColor redColor].CGColor;
            redDotY = (i+1)*40 + ((localTime-[periodTime[i][0] intValue])/45)*40;
            //NSLog(@"%f",(localTime-[periodTime[i][0] intValue])/45);
            redDot.center = CGPointMake(25, redDotY);
            break;
        } else if (i<lessons-1 && localTime > [periodTime[i][1] floatValue] && localTime< [periodTime[i+1][0] floatValue]) {
            redDot.layer.backgroundColor = [UIColor greenColor].CGColor;
            redDotY = (i+2)*40;
            redDot.center = CGPointMake(25, redDotY);
            break;
        }
    }
}

//color
- (void)colorSelected:(UITapGestureRecognizer *)sender {
    UIView *tappedView = [sender.view hitTest:[sender locationInView:sender.view] withEvent:nil];
    NSString *targetString= tf.text;
    UIColor *tColor = tappedView.backgroundColor;
    if (targetString.length==0) {
        if (digitalClockView.alpha == 1) {
            dClock.dColor = tColor;
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSData *theData=[NSKeyedArchiver archivedDataWithRootObject:dClock.dColor];
            [prefs setObject:theData forKey:@"dClockColor"];
            [prefs synchronize];
        }
        return;
    }
    
    tf.backgroundColor = tColor;
    tf.layer.borderWidth = 1;
    for (UITextField *txt in baseView.subviews) {
        if (txt.tag>0 && txt.tag<100) {
            NSString *s = txt.text;
            if ([s isEqualToString:targetString]) {
                txt.layer.backgroundColor = tColor.CGColor;
            }
        }
    }
    [self save];
}

- (IBAction)zoomMeIn:(UIPinchGestureRecognizer *)recognizer {
    recognizer.view.autoresizesSubviews=YES;
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    skala=recognizer.scale;
    recognizer.scale = 1.0;
}

- (IBAction)paneMe:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x+translation.x,
                                       recognizer.view.center.y+translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    //inercija
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:self.view];
        CGFloat magnitude = sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y));
        CGFloat slideMult = magnitude / 200;
        float slideFactor = 0.1 * slideMult; // Increase for more of a slide
        float transformFactor = baseView.transform.a;
        if (transformFactor<1) {
            transformFactor = 1;
        }
        CGPoint finalPoint = CGPointMake(recognizer.view.center.x + (velocity.x * slideFactor),
                                         recognizer.view.center.y + (velocity.y * slideFactor));
        finalPoint.x = MIN(MAX(finalPoint.x, 0), self.view.bounds.size.width * transformFactor);
        finalPoint.y = MIN(MAX(finalPoint.y, 0), self.view.bounds.size.height * transformFactor);
        
        [UIView animateWithDuration:slideFactor*2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            recognizer.view.center = finalPoint;
        } completion:nil];
    }
}
//doubleTap
- (IBAction)returnToNormal:(id)sender {
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        baseView.transform = CGAffineTransformMakeScale(1, 1);
        baseView.frame = CGRectMake(0, 40, beginSize.width, beginSize.height);
    } completion:nil];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    tf = textField;
    tf.layer.borderWidth = 2;
    tf.layer.borderColor = [UIColor blackColor].CGColor;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self save];
    textField.layer.borderWidth = 0.5;
    textField.layer.borderColor = [UIColor blackColor].CGColor;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    textField.layer.borderWidth = 0.5;
    textField.layer.borderColor = [UIColor blackColor].CGColor;
    [self save];
    return YES;
}

- (IBAction)openImage:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    //CGRect cropRect = [info[UIImagePickerControllerCropRect] CGRectValue];
    bottomView.image = chosenImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self saveBottomSelectedImage];
}

- (void)saveBottomSelectedImage {
    NSData *pngData = UIImagePNGRepresentation(bottomView.image);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"bottomImage.png"]; //Add the file name
    [pngData writeToFile:filePath atomically:YES]; //Write the file
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:@"NO" forKey:@"rstImage"];
    [prefs synchronize];
    _resetImage = NO;
    
}
- (void)loadBottomSelectedImage {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"bottomImage.png"];
    NSData *pngData = [NSData dataWithContentsOfFile:filePath];
    UIImage *image = [UIImage imageWithData:pngData];
    if (image) {
        bottomView.image = image;
    }
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)clearAll {
    UIAlertController *alert = [UIAlertController
                                  alertControllerWithTitle:NSLocalizedString(@"Brisanje title", nil)
                                  message:NSLocalizedString(@"Brisanje cijelog rasporeda?", nil)
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             [self clearAllAndSave];
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)clearAllAndSave {
    for (UITextField *txt in baseView.subviews) {
        if (txt.tag>0 && txt.tag<100) {
            txt.text = @"";
            txt.backgroundColor = [UIColor whiteColor];
        }
    }
    [self save];
}

- (void)onSecondView {
    _acceptedData = NO;
    [self colectData:^(BOOL success) {
        if (success) {
            NSError *error = nil;
            NSData *data = [NSJSONSerialization dataWithJSONObject:sendDictionary
                                                           options:kNilOptions error:&error];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                        @"Main" bundle:[NSBundle mainBundle]];
            ConectionView *cv=[storyboard instantiateViewControllerWithIdentifier:@"ConectionView"];
            cv.toSend = data;
            [self presentViewController:cv animated:YES completion:nil];
        }
    }];

    
}

- (void)colectData:(void(^)(BOOL success))sucess{
    sendDictionary = [[NSMutableDictionary alloc]init];
    for (UITextField *txt in baseView.subviews) {
        if (txt.tag>0 && txt.tag<100) {
            NSString *s = txt.text;
            //UIColor *bc = txt.backgroundColor;
            //NSData *theData=[NSKeyedArchiver archivedDataWithRootObject:bc];
            [sendDictionary setValue:s forKey:[NSString stringWithFormat:@"p%ld",(long)txt.tag]];
        }
    }
    sucess(YES);
}

- (void)save {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    for (UITextField *txt in baseView.subviews) {
        if (txt.tag>0 && txt.tag<100) {
            NSString *s = txt.text;
            UIColor *bc = txt.backgroundColor;
            NSData *theData=[NSKeyedArchiver archivedDataWithRootObject:bc];
            [prefs setObject:s forKey:[NSString stringWithFormat:@"p%ld",(long)txt.tag]];
            [prefs setObject:theData forKey:[NSString stringWithFormat:@"c%ld",(long)txt.tag]];
        }
    }
    NSData *theData=[NSKeyedArchiver archivedDataWithRootObject:dClock.dColor];
    [prefs setObject:theData forKey:@"dClockColor"];
    [prefs synchronize];
}

-(long)preLoad {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    long n = 1;
    NSString *s = @"";
    while (s!=NULL) {
        s = [prefs stringForKey:[NSString stringWithFormat:@"p%ld",n]];
        NSLog(@"%ld. %@",n++,s);
    }
    return n-2;
}

- (void)load {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    for (UITextField *txt in baseView.subviews) {
        if (txt.tag>0 && txt.tag<100) {
            NSString *s = [prefs stringForKey:[NSString stringWithFormat:@"p%ld",(long)txt.tag]];
            NSData *bcData = [prefs objectForKey:[NSString stringWithFormat:@"c%ld",(long)txt.tag]];
            if (s.length==0) {
                NSLog(@"nil");
            }
            NSLog(@"%@",s);
            
            txt.text = s;
            UIColor *bc = [NSKeyedUnarchiver unarchiveObjectWithData:bcData];
            if (bc==nil) {
                bc = [UIColor whiteColor];
            }
            txt.backgroundColor = bc;
        }
    }
    NSString *s = [prefs stringForKey:[NSString stringWithFormat:@"p%ld",(long)36]];
    NSLog(@"%@",s);
    if (s==NULL) {
        NSLog(@"DA je");
    }
    NSData *bcData = [prefs objectForKey:@"dClockColor"];
    UIColor *dc = [NSKeyedUnarchiver unarchiveObjectWithData:bcData];
    if (dc) {
        dClock.dColor = dc;
    }
    
}

- (void)loadLessionTime {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *s = [prefs stringForKey:@"startHour"];
    if (s.length>0) {
        _statHour = [s floatValue];
    } else {
        _statHour = 8;
    }
    s = [prefs stringForKey:@"startMinute"];
    if (s.length>0) {
        _startMinute = [s floatValue];
    } else {
        _startMinute = 0;
    }
    s = [prefs stringForKey:@"lessonLength"];
    if (s.length>0) {
        _lessonLength = [s floatValue];
    } else {
        _lessonLength = 45;
    }
    s = [prefs stringForKey:@"bigBreak"];
    if (s.length>0) {
        _bigBreak = [s floatValue];
    } else {
        _bigBreak = 20;
    }
    s = [prefs stringForKey:@"bigBreak1After"];
    if (s.length>0) {
        _bigBreak1After = [s intValue];
    } else {
        _bigBreak1After = 2;
    }
    s = [prefs stringForKey:@"bigBreak2After"];
    if (s.length>0) {
        _bigBreak2After = [s intValue];
    } else {
        _bigBreak2After = 0;
    }
    _litleBreak = 5;
    periodTime = [[NSMutableArray alloc]init];
    float stTime = _statHour*60+_startMinute;
    for (int i=0; i<lessons; i++) {
        float endTime = stTime + _lessonLength;
        NSArray *lessonT = @[[NSNumber numberWithFloat: stTime],[NSNumber numberWithFloat: endTime]];
        if ((i+1)==_bigBreak1After || (i+1)==_bigBreak2After) {
            stTime +=_lessonLength + _bigBreak;
        } else {
            stTime +=_lessonLength + _litleBreak;
        }
        [periodTime addObject:lessonT];
    }
    
}

- (void)showInfo {
    lessonStartEnd = @"";

    for (int i=0; i<lessons; i++) {
        NSString *s = [NSString stringWithFormat:@"%i. %02i:%02i - %02i:%02i\n",i+1,
                       [periodTime[i][0] intValue]/60,[periodTime[i][0] intValue]%60,
                       [periodTime[i][1] intValue]/60,[periodTime[i][1] intValue]%60];
        //NSLog(@"%@",s);
        lessonStartEnd = [lessonStartEnd stringByAppendingString:s];
    }
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:NSLocalizedString(@"Trajanje title", nil)
                                message:@"\n\n\n\n\n\n\n\n"
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    UIAlertAction *kalend = [UIAlertAction
                         actionWithTitle:NSLocalizedString(@"Kalendar", nil)
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             KalendarController *kvc=[self.storyboard instantiateViewControllerWithIdentifier: @"Kalendar"];
                             [self presentViewController:kvc animated:YES completion:nil];
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    UIAlertAction *content = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"Record", nil)
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 ContentViewController *cvc=[self.storyboard instantiateViewControllerWithIdentifier: @"Content"];
                                 [self presentViewController:cvc animated:YES completion:nil];
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];


    UILabel *tmpLebel = [[UILabel alloc]init];
    tmpLebel.frame = CGRectMake(60, 0, 200, 240);
    tmpLebel.numberOfLines = 8;
    [tmpLebel setFont: [UIFont fontWithName:@"Arial" size:16.0]];
    tmpLebel.text = lessonStartEnd;
    [alert.view addSubview:tmpLebel];
    [alert addAction:kalend];
    [alert addAction:content];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)returnActionForSegue:(UIStoryboardSegue *)returnSegue {
    if (_acceptedData) {
        for (UITextField *txt in baseView.subviews) {
            if (txt.tag>0 && txt.tag<100) {
                NSString *key = [NSString stringWithFormat:@"p%ld",(long)txt.tag];
                txt.text = [NSString stringWithFormat:@"%@",[_receivedData2 objectForKey:key]];
                txt.backgroundColor = [UIColor whiteColor];
            }
        }
        [self save];
    }
    [self loadLessionTime];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
