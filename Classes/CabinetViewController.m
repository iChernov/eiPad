//
//  CabinetViewController.m
//  E-Iphone
//
//  Created by Ivan Chernov on 08.04.11.
//  Copyright 2011 SKB-Kontur. All rights reserved.
//

#import "CabinetViewController.h"
#import "InAppStoreViewController.h"


@implementation CabinetViewController
extern NSString* serverAddress;
extern NSString* serverHost;

-(id)initWithTitle:(NSString *)title
{
    if ((self = [super init])) {
        self.tabBarItem.image = [UIImage imageNamed:@"tbicon5.png"];
            }
    return self;
}

- (void)initNavigationBar
{
    UINavigationBar *navigationBar = [[UINavigationBar alloc] 
                     initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    navigationBar.tintColor = [UIColor colorWithRed:0 green:0.38 blue:0.6 alpha:1];
    /*[navigationBar showButtonsWithLeftTitle: @"Hello" 
     rightTitle: @"Bye" leftBack: NO];*/
    [navigationBar setBarStyle: 0];
    [navigationBar setDelegate: self];
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@"Кабинет"];
    [navigationBar pushNavigationItem:navigationItem animated:YES];
    [navigationItem release];
    [self.view addSubview:navigationBar];
    [navigationBar release];
}


- (NSString *)makeUserData
{
    NSString *selfInfoStr = [NSString stringWithFormat:@"%@/selfInfo.plist", [[NSUserDefaults standardUserDefaults] stringForKey:@"UserUID"]];
    NSString *nameStr = [[NSString alloc] initWithString:selfInfoStr];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savingDictFileName = [documentsDirectory stringByAppendingPathComponent:nameStr];
    [nameStr release];
    NSDictionary *selfInfoArr = [[NSDictionary alloc] initWithContentsOfFile:savingDictFileName];
    NSMutableString *userDataString = [[NSMutableString new] autorelease];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isIP"])
    {
        [userDataString appendString:@"ИП "];
        [userDataString appendFormat:@"%@", [self nullableToString: [selfInfoArr objectForKey:@"Surname"]]];
        [userDataString appendString:@" "];
        [userDataString appendFormat:@"%@", [self nullableToString: [selfInfoArr objectForKey:@"Name"]]];
        [userDataString appendString:@" "];
        [userDataString appendFormat:@"%@", [self nullableToString: [selfInfoArr objectForKey:@"Patronymic"]]];
    }
    else {
        [userDataString appendFormat:@"%@", [self nullableToString: [selfInfoArr objectForKey:@"OrganizationShortName"]]];
    }
    [userDataString appendFormat:@"\nИНН: %@\nРасчетный счет: %@", [self nullableToString: [selfInfoArr objectForKey:@"INN"]], [self nullableToString: [selfInfoArr objectForKey:@"AccountNumber"]]];
    [selfInfoArr release];
    return userDataString;

}



-(NSString *)nullableToString:(id) object {
	if (object == nil) {
		return @"";
	}
	else {
		return (NSString *) object;
	}
	
}
     
- (void)goToStore
{
    InAppStoreViewController* store = [InAppStoreViewController new];
    UINavigationController *subNavContr = [[UINavigationController alloc] init];
	subNavContr.navigationBar.tintColor = [UIColor colorWithRed:0 green:0.38 blue:0.6 alpha:1];
	[subNavContr pushViewController:store animated:YES];
	[self presentModalViewController:subNavContr animated:YES];
    [store release];
	[subNavContr release];
}

- (void)exit
{
    NSUserDefaults *userDefs = [NSUserDefaults standardUserDefaults];
    if (![userDefs boolForKey:@"shouldRememberPassword"]) {
		[userDefs removeObjectForKey:@"pass"];
		[userDefs removeObjectForKey:@"login"];
	}
	[userDefs setBool:NO forKey:@"loggedIn"];
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)dealloc
{
    [goToStoreButton release];
    [exitButton release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
       // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    topBarHeight = 40;
    CGFloat bgHeight = 440-topBarHeight;
    UIImageView *userDataBackground = [UIImageView new];
    [userDataBackground setImage:[UIImage imageNamed:@"iPhone4-back2.png"]];
    [userDataBackground setFrame:CGRectMake(0, topBarHeight, 320, bgHeight)];
    [self.view addSubview:userDataBackground];
    [userDataBackground release];
    self.navigationItem.title = @"Кабинет";
    
    NSString *selfInfoStr = [NSString stringWithFormat:@"%@/selfInfo.plist", [[NSUserDefaults standardUserDefaults] stringForKey:@"UserUID"]];
    NSString *nameStr = [[NSString alloc] initWithString:selfInfoStr];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savingDictFileName = [documentsDirectory stringByAppendingPathComponent:nameStr];
    [nameStr release];
    NSDictionary *selfInfoArr = [[NSDictionary alloc] initWithContentsOfFile:savingDictFileName];
    NSMutableString *userDataString = [NSMutableString new];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isIP"])
    {
        [userDataString appendString:@"ИП "];
        [userDataString appendFormat:@"%@", [self nullableToString: [selfInfoArr objectForKey:@"Surname"]]];
        [userDataString appendString:@" "];
        [userDataString appendFormat:@"%@", [self nullableToString: [selfInfoArr objectForKey:@"Name"]]];
        [userDataString appendString:@" "];
        [userDataString appendFormat:@"%@", [self nullableToString: [selfInfoArr objectForKey:@"Patronymic"]]];
    }
    else {
        [userDataString appendString:@"ООО "];
        [userDataString appendFormat:@"%@", [self nullableToString: [selfInfoArr objectForKey:@"OrganizationShortName"]]];
    }
    
    UILabel *iporooolabel = [[UILabel alloc] init];
    numOfLines = ([userDataString length])/33 + 1;
    [iporooolabel setLineBreakMode:UILineBreakModeWordWrap];
    [iporooolabel setNumberOfLines:numOfLines];
    [iporooolabel setFrame:CGRectMake(10, 20+topBarHeight, 300, 25*numOfLines)];
    [iporooolabel setBackgroundColor:[UIColor clearColor]];
    [iporooolabel setFont:[UIFont fontWithName:@"Thonburi-Bold" size:19]];
    [iporooolabel setText:userDataString];
    [userDataString release];
    [self.view addSubview: iporooolabel];
    [iporooolabel release];
    
    UILabel *innlabel = [[UILabel alloc] init];
    [innlabel setBackgroundColor:[UIColor clearColor]];
    [innlabel setFrame:CGRectMake(10, 25*(numOfLines+1)+topBarHeight, 300, 25)];
    [innlabel setFont:[UIFont fontWithName:@"Thonburi" size:16]];
    [innlabel setText:[NSString stringWithFormat:@"ИНН: %@", [self nullableToString: [selfInfoArr objectForKey:@"INN"]]]];
    [self.view addSubview: innlabel];
    [innlabel release];
    
    UILabel *rslabel = [[UILabel alloc] init];
    [rslabel setBackgroundColor:[UIColor clearColor]];
    [rslabel setFrame:CGRectMake(10, 3+25*(numOfLines+2)+topBarHeight, 300, 25)];
    [rslabel setFont:[UIFont fontWithName:@"Thonburi" size:16]];
    [rslabel setText:[NSString stringWithFormat:@"Расчетный счет: %@", [self nullableToString: [selfInfoArr objectForKey:@"AccountNumber"]]]];
    [self.view addSubview: rslabel];
    [selfInfoArr release];
    [rslabel release];
    
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"loggedIn"])
    {
        goToStoreButton = [[UIButton alloc] initWithFrame:CGRectMake(35, 120+25*numOfLines+topBarHeight, 250, 60)];
        [goToStoreButton setBackgroundImage:[UIImage imageNamed:@"up.png"] forState:UIControlStateNormal];
        [goToStoreButton setBackgroundImage:[UIImage imageNamed:@"down.png"] forState:UIControlStateHighlighted];
        [goToStoreButton addTarget:self action:@selector(goToStore) forControlEvents:UIControlEventTouchUpInside];
        goToStoreButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
        goToStoreButton.titleLabel.textAlignment = UITextAlignmentCenter;
        [goToStoreButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [goToStoreButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:18]];
        [goToStoreButton setTitle: @"Оплатить веб-сервис\nЭльба с Айфона" forState: UIControlStateNormal];
        [self.view addSubview:goToStoreButton];
        
        exitButton = [[UIButton alloc] initWithFrame:CGRectMake(35, 300+topBarHeight, 250, 50)];
        [exitButton setBackgroundImage:[UIImage imageNamed:@"logout_up.png"] forState:UIControlStateNormal];
        [exitButton setBackgroundImage:[UIImage imageNamed:@"logout_down.png"] forState:UIControlStateHighlighted];
        [exitButton addTarget:self action:@selector(exit) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:exitButton];
        [self initNavigationBar];
    }
    else
    {
        exitButton = [[UIButton alloc] initWithFrame:CGRectMake(35, 300+topBarHeight, 250, 50)];
        [exitButton setBackgroundImage:[UIImage imageNamed:@"logout_up.png"] forState:UIControlStateNormal];
        [exitButton setBackgroundImage:[UIImage imageNamed:@"logout_down.png"] forState:UIControlStateHighlighted];
        [exitButton addTarget:self action:@selector(exit) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:exitButton];
        [self initNavigationBar];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"loggedIn"])
    {
        TillDateReceiver *dateReceiver = [[TillDateReceiver alloc] init];
        [dateReceiver setDelegate:self];
        UILabel *dateLabel = [[UILabel alloc] init];
        [dateLabel setBackgroundColor:[UIColor clearColor]];
        [dateLabel setFrame:CGRectMake(10, 6+25*(numOfLines+3)+topBarHeight, 300, 25)];
        [dateLabel setFont:[UIFont fontWithName:@"Thonburi" size:16]];
        [dateLabel setText:[[NSUserDefaults standardUserDefaults] valueForKey:@"tillDate"]];
        [self.view addSubview: dateLabel];
        [self.view setNeedsDisplay];
        [dateLabel release];
        [dateReceiver release];
    }
    else
    {
        UILabel *dateLabel = [[UILabel alloc] init];
        [dateLabel setBackgroundColor:[UIColor clearColor]];
        [dateLabel setFrame:CGRectMake(10, 6+25*(numOfLines+3)+topBarHeight, 300, 25)];
        [dateLabel setFont:[UIFont fontWithName:@"Thonburi" size:16]];
        [dateLabel setText:@"Веб-сервис Эльба не оплачен"];
        [self.view addSubview: dateLabel];
        [dateLabel release];
    }

}








- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
