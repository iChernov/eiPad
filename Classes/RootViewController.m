/*
 This module is licenced under the BSD license.
 
 Copyright (C) 2011 by raw engineering <nikhil.jain (at) raweng (dot) com, reefaq.mohammed (at) raweng (dot) com>.
 
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  RootView.m
//  StackScrollView
//
//  Created by Reefaq on 2/24/11.
//  Copyright 2011 raw engineering . All rights reserved.
//

#import "RootViewController.h"
#import "MenuViewController.h"
#import "StackScrollViewController.h"
#import "CJSONDeserializer.h"
#import "TillDateReceiver.h"
#import "InAppStoreViewController.h"

extern NSString* serverAddress;
extern NSString* serverHost;


@interface UIViewExt : UIView {} 
@end


@implementation UIViewExt
- (UIView *) hitTest: (CGPoint) pt withEvent: (UIEvent *) event 
{   
	
	UIView* viewToReturn=nil;
	CGPoint pointToReturn;
	
	UIView* uiRightView = (UIView*)[[self subviews] objectAtIndex:1];
	
	if ([[uiRightView subviews] objectAtIndex:0]) {
		
		UIView* uiStackScrollView = [[uiRightView subviews] objectAtIndex:0];	
		
		if ([[uiStackScrollView subviews] objectAtIndex:1]) {	 
			
			UIView* uiSlideView = [[uiStackScrollView subviews] objectAtIndex:1];	
			
			for (UIView* subView in [uiSlideView subviews]) {
				CGPoint point  = [subView convertPoint:pt fromView:self];
				if ([subView pointInside:point withEvent:event]) {
					viewToReturn = subView;
					pointToReturn = point;
				}
				
			}
		}
		
	}
	
	if(viewToReturn != nil) {
		return [viewToReturn hitTest:pointToReturn withEvent:event];		
	}
	
	return [super hitTest:pt withEvent:event];	
	
}

@end

@implementation RootViewController
@synthesize stackScrollViewController;
@synthesize trustedHosts, receivedData;
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {		
        userDefs = [NSUserDefaults standardUserDefaults];
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
	rootView = [[UIViewExt alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	rootView.autoresizingMask = UIViewAutoresizingFlexibleWidth + UIViewAutoresizingFlexibleHeight;
	[rootView setBackgroundColor:[UIColor clearColor]];http://mnovosti.ru/articles/attachment/23ef6168c60c282be15bf8e131fd817409ab8e5e/Siemens%20SL10%21%21%21.jpg
	
	leftMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, self.view.frame.size.height)];
	leftMenuView.autoresizingMask = UIViewAutoresizingFlexibleHeight;	
	
	
	rightSlideView = [[UIView alloc] initWithFrame:CGRectMake(leftMenuView.frame.size.width, 0, rootView.frame.size.width - leftMenuView.frame.size.width, rootView.frame.size.height)];
	rightSlideView.autoresizingMask = UIViewAutoresizingFlexibleWidth + UIViewAutoresizingFlexibleHeight;
	stackScrollViewController = [[StackScrollViewController alloc] init];	
	[stackScrollViewController.view setFrame:CGRectMake(0, 0, rightSlideView.frame.size.width, rightSlideView.frame.size.height)];
	[stackScrollViewController.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth + UIViewAutoresizingFlexibleHeight];
	[stackScrollViewController viewWillAppear:FALSE];
	[stackScrollViewController viewDidAppear:FALSE];
	[rightSlideView addSubview:stackScrollViewController.view];
	
	[rootView addSubview:leftMenuView];
	[rootView addSubview:rightSlideView];
	[self.view setBackgroundColor:[UIColor colorWithPatternImage: [UIImage imageNamed:@"background.png"]]];
	[self.view addSubview:rootView];
    
    loginView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipad_back.png"]];
    [self.view addSubview:loginView];
    
    loginTable = [[LoginTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    loginTable.view.frame = CGRectMake(self.view.center.x, self.view.center.y - 100.0f, 350, 100);
    loginTable.tableView.scrollEnabled = NO;
    [self.view addSubview:loginTable.view];
    
    remeberMeLabel = [[UILabel alloc] init];
    [remeberMeLabel setFont:[UIFont fontWithName:@"Helvetica" size:16.0]];
    [remeberMeLabel setBackgroundColor:[UIColor clearColor]];
    [remeberMeLabel setText:@"Запомнить меня"];
    [remeberMeLabel setTextColor:[UIColor whiteColor]];
    remeberMeLabel.frame = CGRectMake(self.view.center.x + 10.0f, self.view.center.y+ 10.0f, 150, 30);
    [self.view addSubview:remeberMeLabel];
    
    enterButton = [[UIButton alloc] initWithFrame: CGRectMake(self.view.center.x + 10.0f, self.view.center.y + 55.0f, 150, 50)];
    [enterButton setBackgroundImage:[UIImage imageNamed:@"up.png"] forState:UIControlStateNormal];
    [enterButton setBackgroundImage:[UIImage imageNamed:@"down.png"] forState:UIControlStateHighlighted];
    [enterButton addTarget:self action:@selector(checkPass) forControlEvents:UIControlEventTouchUpInside];
    [enterButton setTitleColor:[UIColor blackColor] forState: UIControlStateNormal];
    [enterButton setTitle: @"Войти" forState: UIControlStateNormal];
    [self.view addSubview:enterButton];

    
    tryButton = [[UIButton alloc] init];
    tryButton.titleLabel.textAlignment = UITextAlignmentLeft;
    [tryButton setBackgroundColor:[UIColor clearColor]];
    [tryButton addTarget:self action:@selector(justTry) forControlEvents:UIControlEventTouchUpInside];
    [tryButton setTitleColor:[UIColor colorWithRed:0.7 green:0.7 blue:0.9 alpha:0.9] forState: UIControlStateNormal];
    [tryButton setTitle: @"Попробовать" forState: UIControlStateNormal];
    tryButton.frame = CGRectMake(self.view.center.x + 215.0f, self.view.center.y + 65.0f, 120, 30);
    [self.view addSubview:tryButton];
    
    tryLinkView = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x + 215.0f, self.view.center.y + 90.0f, 120, 1)];
    [tryLinkView setBackgroundColor:[UIColor colorWithRed:0.7 green:0.7 blue:0.9 alpha:0.9]];
    [self.view addSubview:tryLinkView];
    
    shouldRememberPassword = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.center.x + 165, self.view.center.y + 10.0f, 150, 50)];
    [shouldRememberPassword addTarget:self 
                               action:@selector(userChangesRememberSwitch)
                     forControlEvents:UIControlEventTouchUpInside];
    shouldRememberPassword.on = [userDefs boolForKey:@"shouldRememberPassword"];
    //[shouldRememberPassword setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
     [self.view addSubview:shouldRememberPassword];
    
    logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipad_logo.png"]];
    logoView.center = CGPointMake(loginTable.view.center.x-370, loginTable.view.center.y+15);
    [self.view addSubview:logoView];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isLoggedIn"]) {
        
        [self drawLoginFields];
    }
}

- (void)justTry
{
    [loginTable.loginTextField resignFirstResponder];
    [loginTable.passwordTextField resignFirstResponder];
        NSDictionary *resultsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"-1", @"AbonentId",
							 @"987654321", @"AccountNumber",
							 @"Шариков", @"Surname",
							 @"Полиграф", @"Name",
							 @"Полиграфович", @"Patronymic",
							 @"123456, г.Москва, ул.Большие черёмушки, д.1", @"Address",
							 @"89991234567" , @"Phone",
							 @"000000000000", @"INN",
							 @"", @"KPP",
							 @"Самый Лучший Банк", @"BankName",
							 @"987654321", @"BankBik",
							 @"1357902468", @"AccountNumber",
							 @"01234567890123456789", @"BankCorrAccount",

							 nil];
		[userDefs setValue: @"" forKey:@"login"];
		[userDefs setValue: @"" forKey:@"pass"];
		[userDefs setBool:YES forKey:@"loggedIn"];
		[userDefs setBool:YES forKey:@"isIP"];
        [userDefs setValue:[resultsDictionary objectForKey:@"AbonentId"] forKey:@"UserUID"];
		menuViewController = [[MenuViewController alloc] initWithFrame:CGRectMake(0, 100, leftMenuView.frame.size.width, leftMenuView.frame.size.height-400)];
        menuViewController.delegate = self;
        [menuViewController.view setBackgroundColor:[UIColor clearColor]];
        [menuViewController viewWillAppear:FALSE];
        [menuViewController viewDidAppear:FALSE];
        
        
        exitButton = [[UIButton alloc] init];
        exitButton.frame = CGRectMake(30, leftMenuView.frame.size.height-60, leftMenuView.frame.size.width-60, 35);
        [exitButton setBackgroundImage:[UIImage imageNamed:@"exit__button.png"] forState:UIControlStateNormal];
        [exitButton setBackgroundImage:[UIImage imageNamed:@"exit__button__pressed.png"] forState:UIControlStateHighlighted];
        [exitButton addTarget:self action:@selector(exit) forControlEvents:UIControlEventTouchUpInside];
        [exitButton setTitleColor:[UIColor blackColor] forState: UIControlStateNormal];
        [exitButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:15.0]];
        [exitButton setTitle: @"Выйти" forState: UIControlStateNormal];
        [leftMenuView addSubview:exitButton];
        
        logo2ndView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipad_logo.png"]];
        logo2ndView.frame = CGRectMake(60, leftMenuView.frame.size.height-260, 130, 130);
        
        logoSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separator_logo.png"]];
        logoSeparator.frame = CGRectMake(20, leftMenuView.frame.size.height-117, leftMenuView.frame.size.width-40, 3);
        
        [leftMenuView addSubview:logoSeparator];
        [leftMenuView addSubview:logo2ndView];
        [leftMenuView addSubview:menuViewController.view];
	
	
	NSMutableDictionary *resDict = [[NSMutableDictionary new] autorelease];
	[self insertValuesIn:resDict from:resultsDictionary];
	NSString *nameStr = [NSString stringWithFormat:@"%@", [resultsDictionary objectForKey:@"AbonentId"]];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *savingDictionaryFileName = [documentsDirectory stringByAppendingPathComponent:nameStr];
	[[NSFileManager defaultManager] createDirectoryAtPath:savingDictionaryFileName withIntermediateDirectories:YES attributes: nil error: nil];
	[[NSFileManager defaultManager] createFileAtPath:[NSString stringWithFormat:@"%@/selfInfo.plist", savingDictionaryFileName] contents:nil attributes:nil];
	
	[resDict writeToFile:[NSString stringWithFormat:@"%@/selfInfo.plist", savingDictionaryFileName] atomically:YES];
	
    [self dismissLoginFields];
    menuViewController.view.frame = CGRectMake(0, 70+30*numOfLines, leftMenuView.frame.size.width, leftMenuView.frame.size.height-400);
    [menuViewController.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    [menuViewController showInitialDocuments];
    [horizontalLine removeFromSuperview];
    horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(0, 70+30*numOfLines-1, 250, 1)];
    [horizontalLine setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"separator.png"]]];
    [self.view addSubview:horizontalLine];
    [self.view sendSubviewToBack:horizontalLine];
    [horizontalLine release];

}

- (void)drawLoginFields
{
    loginTable.view.alpha = 1;
    logoView.alpha = 1;
    enterButton.alpha = 1;
    loginView.alpha = 1;
    shouldRememberPassword.alpha = 1;
    remeberMeLabel.alpha = 1;
    tryButton.alpha = 1;
    tryLinkView.alpha = 1;
    [loginTable.loginTextField becomeFirstResponder];
    if ([userDefs boolForKey:@"shouldRememberPassword"]) {
        if (([userDefs valueForKey:@"login"])&&([(NSString *)[userDefs valueForKey:@"login"] length] > 0)) {
            loginTable.loginTextField.text = [userDefs valueForKey:@"login"];
        }
        else {
            loginTable.loginTextField.placeholder = @"Введите ваш e-mail";
        }
        if (([userDefs valueForKey:@"pass"])&&([(NSString *)[userDefs valueForKey:@"pass"] length] > 0)) {
            loginTable.passwordTextField.text = [userDefs valueForKey:@"pass"];
            [loginTable.passwordTextField becomeFirstResponder];
        }
        else {
            loginTable.passwordTextField.placeholder = @"Введите ваш пароль";
        }
    }
	else {
		loginTable.loginTextField.placeholder = @"Введите ваш e-mail";
		loginTable.passwordTextField.placeholder = @"Введите ваш пароль";
	}
    
}

- (void)checkPass
{
    [loginTable.loginTextField resignFirstResponder];
    [loginTable.passwordTextField resignFirstResponder];
    tryButton.enabled = NO;
    enterButton.enabled = NO;
    [self tryLogin];
}

/*
 - (IBAction)done:(id)sender {
 [loginTextField resignFirstResponder];
 [passTextField resignFirstResponder];
 // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
 HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
 
 // Add HUD to screen
 [self.view.window addSubview:HUD];
 
 // Regisete for HUD callbacks so we can remove it from the window at the right time
 HUD.delegate = self;
 
 HUD.labelText = @"Вхожу в систему...";
 
 // Show the HUD while the provided method executes in a new thread
 [HUD show:YES];
 [self tryLogin];
 
 }*/

- (void)tryLogin {
    loginIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [loginIndicator setCenter:CGPointMake(enterButton.center.x+105, enterButton.center.y)];
    [self.view addSubview:loginIndicator];
    [loginIndicator startAnimating];
	[receivedData setLength:0];
	NSString *FeedURL = [NSString stringWithFormat:@"%@/PublicInterface/IPhone/GetLegalEntity.ashx?version=%@&login=%@&password=%@", serverAddress, [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], loginTable.loginTextField.text, loginTable.passwordTextField.text];
	
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:FeedURL]
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:60.0];
	NSURLConnection *authURLConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:YES];
	[authURLConnection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
	//[authURLConnection start];
	if (authURLConnection) {
		receivedData = [[NSMutableData data] retain];
	} else {
        [loginIndicator stopAnimating];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Внимание!" message:@"Отсутствует интернет-соединение. Проверьте настройки сетевого подключения." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
    [authURLConnection release];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
	
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
	
    // receivedData is an instance variable declared elsewhere.
    [receivedData setLength:0];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [receivedData appendData:data];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
	return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
		if ([trustedHosts containsObject:challenge.protectionSpace.host])
			[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
	
	[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
	//[HUD hide:YES];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Внимание!" message:@"Отсутствует интернет-соединение. Проверьте настройки сетевого подключения." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[alert release];
    [loginIndicator stopAnimating];
    enterButton.enabled = YES;
    tryButton.enabled = YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [loginIndicator stopAnimating];
    enterButton.enabled = YES;
    tryButton.enabled = YES;
    CJSONDeserializer *jsonDeserializer = [CJSONDeserializer deserializer];
	NSError *error;
	NSDictionary *resultsDictionary = [jsonDeserializer deserializeAsDictionary:receivedData error:&error];
	//[HUD hide:YES];
	BOOL isEmpty = (resultsDictionary == nil);
	if (isEmpty)
	{
        NSString *responseString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
        if([responseString  isEqualToString:@"needSms"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Чтобы иметь возможность войти в свой аккаунт через мобильное приложение - отключите подтверждение входа по sms" delegate:self cancelButtonTitle:@"OК" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        else if ([responseString isEqualToString:@"outsourcer"]) 
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"В настоящий момент работа с аутсорсерами не поддерживается приложением" delegate:self cancelButtonTitle:@"OК" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Вы ввели неверный логин и/или пароль" delegate:self cancelButtonTitle:@"OК" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
		resultsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
							 @"987654321", @"AccountNumber",
							 @"Шариков", @"Surname",
							 @"Полиграф", @"Name",
							 @"Полиграфович", @"Patronymic",
							 @"123456, г.Москва, ул.Большие черёмушки, д.1", @"Address",
							 @"89991234567" , @"Phone",
							 @"000000000000", @"INN",
							 @"", @"KPP",
							 @"Самый Лучший Банк", @"BankName",
							 @"987654321", @"BankBik",
							 @"1357902468", @"AccountNumber",
							 @"01234567890123456789", @"BankCorrAccount",
							 nil];
		[userDefs setBool:NO forKey:@"loggedIn"];
	}
	else {
		
		[userDefs setValue: loginTable.loginTextField.text forKey:@"login"];
		[userDefs setValue: loginTable.passwordTextField.text forKey:@"pass"];
		[userDefs setBool:YES forKey:@"loggedIn"];
		
        TillDateReceiver *dateReceiver = [[TillDateReceiver alloc] init];
        [userDefs setValue:[dateReceiver getTillDate] forKey:@"tillDate"];
        [dateReceiver release];
		
		if ([shouldRememberPassword isOn]) {
			[userDefs setBool:YES forKey:@"savePass"];
		}
		else 
		{
			[userDefs setBool:NO forKey:@"savePass"];
		}
		
		if ([[resultsDictionary objectForKey:@"LegalForm"] isEqual:[NSNumber numberWithInt:0]]) {
			[userDefs setBool:YES forKey:@"isIP"];
		}
		else {
			[userDefs setBool:NO forKey:@"isIP"];
		}
        [userDefs setValue:[resultsDictionary objectForKey:@"AbonentId"] forKey:@"UserUID"];
		menuViewController = [[MenuViewController alloc] initWithFrame:CGRectMake(0, 100, leftMenuView.frame.size.width, leftMenuView.frame.size.height-400)];
        menuViewController.delegate = self;
        [menuViewController.view setBackgroundColor:[UIColor clearColor]];
        [menuViewController viewWillAppear:FALSE];
        [menuViewController viewDidAppear:FALSE];
        
        paymentButton = [[UIButton alloc] init];
        paymentButton.frame = CGRectMake(30, leftMenuView.frame.size.height-105, leftMenuView.frame.size.width-60, 35);
        [paymentButton setBackgroundImage:[UIImage imageNamed:@"up.png"] forState:UIControlStateNormal];
        [paymentButton setBackgroundImage:[UIImage imageNamed:@"down.png"] forState:UIControlStateHighlighted];
        [paymentButton addTarget:self action:@selector(pay) forControlEvents:UIControlEventTouchUpInside];
        [paymentButton setTitleColor:[UIColor blackColor] forState: UIControlStateNormal];
        [paymentButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:15.0]];
        [paymentButton setTitle: @"Заплатить за Эльбу" forState: UIControlStateNormal];
        [leftMenuView addSubview:paymentButton];
        
        exitButton = [[UIButton alloc] init];
        exitButton.frame = CGRectMake(30, leftMenuView.frame.size.height-60, leftMenuView.frame.size.width-60, 35);
        [exitButton setBackgroundImage:[UIImage imageNamed:@"exit__button.png"] forState:UIControlStateNormal];
        [exitButton setBackgroundImage:[UIImage imageNamed:@"exit__button__pressed.png"] forState:UIControlStateHighlighted];
        [exitButton addTarget:self action:@selector(exit) forControlEvents:UIControlEventTouchUpInside];
        [exitButton setTitleColor:[UIColor blackColor] forState: UIControlStateNormal];
        [exitButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:15.0]];
        [exitButton setTitle: @"Выйти" forState: UIControlStateNormal];
        [leftMenuView addSubview:exitButton];
        
        logo2ndView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipad_logo.png"]];
        logo2ndView.frame = CGRectMake(60, leftMenuView.frame.size.height-260, 130, 130);
        
        logoSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separator_logo.png"]];
        logoSeparator.frame = CGRectMake(20, leftMenuView.frame.size.height-117, leftMenuView.frame.size.width-40, 3);

        [leftMenuView addSubview:logoSeparator];
        [leftMenuView addSubview:logo2ndView];
        [leftMenuView addSubview:menuViewController.view];
	}
	
	NSMutableDictionary *resDict = [[NSMutableDictionary new] autorelease];
	[self insertValuesIn:resDict from:resultsDictionary];
	NSString *nameStr = [NSString stringWithFormat:@"%@", [resultsDictionary objectForKey:@"AbonentId"]];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *savingDictionaryFileName = [documentsDirectory stringByAppendingPathComponent:nameStr];
	[[NSFileManager defaultManager] createDirectoryAtPath:savingDictionaryFileName withIntermediateDirectories:YES attributes: nil error: nil];
	[[NSFileManager defaultManager] createFileAtPath:[NSString stringWithFormat:@"%@/selfInfo.plist", savingDictionaryFileName] contents:nil attributes:nil];
	
	[resDict writeToFile:[NSString stringWithFormat:@"%@/selfInfo.plist", savingDictionaryFileName] atomically:YES];
	
	
	if (!isEmpty) 
	{
        [self dismissLoginFields];
        menuViewController.view.frame = CGRectMake(0, 70+30*numOfLines, leftMenuView.frame.size.width, leftMenuView.frame.size.height-400);
        [menuViewController.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
        [menuViewController showInitialDocuments];
	}
    [horizontalLine removeFromSuperview];
    horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(0, 70+30*numOfLines-1, 250, 1)];
    [horizontalLine setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"separator.png"]]];
    [self.view addSubview:horizontalLine];
    [self.view sendSubviewToBack:horizontalLine];
    [horizontalLine release];
}        
        

- (void)insertValuesIn:(NSMutableDictionary *)variables from:(NSDictionary *)selfInfoDct
{
	for (NSString *key in [selfInfoDct allKeys]) {
		[variables setObject:([self nullableToString: [selfInfoDct objectForKey:key] ]) forKey:key];
	}
}

-(NSString *)nullableToString:(id) object {
	if ((object == nil)||([object isEqual:[NSNull null]])) {
		return @"";
	}
	else {
		return (NSString *) object;
	}
	
}

- (int)menuHeight
{
    return 70+30*numOfLines;
}

- (void)userChangesRememberSwitch
{
	[userDefs setBool:shouldRememberPassword.on forKey:@"shouldRememberPassword"];
	if (!shouldRememberPassword.on) {
		[userDefs removeObjectForKey:@"pass"];
		[userDefs removeObjectForKey:@"login"];
	}
}


- (void)dismissLoginFields
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    loginTable.view.alpha = 0;
    enterButton.alpha = 0;
    loginView.alpha = 0;
    shouldRememberPassword.alpha = 0;
    logoView.alpha = 0;
    remeberMeLabel.alpha = 0;
    tryButton.alpha = 0;
    tryLinkView.alpha = 0;
    [UIView commitAnimations];
    [self drawUserInfo];

 }

- (void)drawUserInfo
{
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
        [userDataString appendString:@""];
        [userDataString appendFormat:@"%@", [self nullableToString: [selfInfoArr objectForKey:@"OrganizationShortName"]]];
    }
    iporooolabel = [[UILabel alloc] init];
    numOfLines = ([userDataString length])/26 + 1;
    [iporooolabel setLineBreakMode:UILineBreakModeWordWrap];
    [iporooolabel setNumberOfLines:numOfLines];
    [iporooolabel setFrame:CGRectMake(10, 10, 235, 25*numOfLines)];
    [iporooolabel setBackgroundColor:[UIColor clearColor]];
    [iporooolabel setFont:[UIFont fontWithName:@"Thonburi-Bold" size:19]];
    [iporooolabel setTextColor:[UIColor whiteColor]];
    [iporooolabel setText:userDataString];
    [userDataString release];
    [self.view addSubview: iporooolabel];
    [self.view sendSubviewToBack:iporooolabel];
    
    innlabel = [[UILabel alloc] init];
    [innlabel setBackgroundColor:[UIColor clearColor]];
    [innlabel setFrame:CGRectMake(10, 25*(numOfLines+1)-10, 300, 25)];
    [innlabel setFont:[UIFont fontWithName:@"Thonburi" size:16]];
    [innlabel setTextColor:[UIColor whiteColor]];
    [innlabel setText:[NSString stringWithFormat:@"ИНН: %@", [self nullableToString: [selfInfoArr objectForKey:@"INN"]]]];
    [self.view addSubview: innlabel];
    [self.view sendSubviewToBack:innlabel];
    
    rslabel = [[UILabel alloc] init];
    [rslabel setBackgroundColor:[UIColor clearColor]];
    [rslabel setFrame:CGRectMake(10, 3+25*(numOfLines+2)-10, 300, 25)];
    [rslabel setFont:[UIFont fontWithName:@"Thonburi" size:16]];
    [rslabel setTextColor:[UIColor whiteColor]];
    [rslabel setText:[NSString stringWithFormat:@"р/с: %@", [self nullableToString: [selfInfoArr objectForKey:@"AccountNumber"]]]];
    [self.view addSubview: rslabel];
    [self.view sendSubviewToBack:rslabel];
    [selfInfoArr release];
    
    verticalLine = [[UIView alloc] initWithFrame:CGRectMake(250, 0, 1, 200)];
	[verticalLine setBackgroundColor:[UIColor blackColor]];
	[self.view addSubview:verticalLine];
    [self.view sendSubviewToBack:verticalLine];

    [self.view setNeedsDisplay];
}

- (void)pay
{
    InAppStoreViewController *store = [[InAppStoreViewController alloc] init];
   // [store setDelegate: self];
	UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:store];
    
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentModalViewController:navController animated:YES];
    
    
    [navController release];
    [store release];
}

- (void)exit
{
    if (![userDefs boolForKey:@"shouldRememberPassword"]) {
		[userDefs removeObjectForKey:@"pass"];
		[userDefs removeObjectForKey:@"login"];
	}
	[userDefs setBool:NO forKey:@"loggedIn"];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    
    for (UIView *view in leftMenuView.subviews) {
        [view removeFromSuperview];
    }
    [iporooolabel removeFromSuperview];
    [iporooolabel release];
    iporooolabel = nil;
    [innlabel removeFromSuperview];
    [innlabel release];
    innlabel = nil;
    [rslabel removeFromSuperview];
    [rslabel release];
    rslabel = nil;
    [verticalLine removeFromSuperview];
    [verticalLine release];
    verticalLine = nil;

    [menuViewController release];
    menuViewController = nil;
    [exitButton release];
    exitButton = nil;
    [paymentButton release];
    paymentButton = nil;
    [logo2ndView release];
    logo2ndView = nil;
    
    
    [self drawLoginFields];
    
    [UIView commitAnimations];
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[menuViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	[stackScrollViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [loginIndicator setCenter:CGPointMake(enterButton.center.x+130, enterButton.center.y)];
}

-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if (menuViewController) {
        [menuViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
        paymentButton.frame = CGRectMake(30, leftMenuView.frame.size.height-105, leftMenuView.frame.size.width-60, 35);
        exitButton.frame = CGRectMake(30, leftMenuView.frame.size.height-60, leftMenuView.frame.size.width-60, 35);
        logo2ndView.frame = CGRectMake(60, leftMenuView.frame.size.height-260, 130, 130);
        logoSeparator.frame = CGRectMake(20, leftMenuView.frame.size.height-117, leftMenuView.frame.size.width-40, 3);
    }
	
	[stackScrollViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [loginTable willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        loginTable.view.frame = CGRectMake(self.view.center.x, self.view.center.y - 100.0f, 360, 150);
        enterButton.frame = CGRectMake(self.view.center.x + 10.0f, self.view.center.y + 55.0f, 165, 50);
        remeberMeLabel.frame = CGRectMake(self.view.center.x + 10.0f, self.view.center.y+ 10.0f, 150, 30);
        shouldRememberPassword.frame = CGRectMake(self.view.center.x + 165, self.view.center.y + 10.0f, 150, 50);
        tryButton.frame = CGRectMake(self.view.center.x + 215.0f, self.view.center.y + 65.0f, 120, 30);
        tryLinkView.frame = CGRectMake(self.view.center.x + 215.0f, self.view.center.y + 90.0f, 120, 1);
        logoView.center = CGPointMake(loginTable.view.center.x-370, loginTable.view.center.y+15);
    }
  	if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        loginTable.view.frame   = CGRectMake(self.view.center.x + 100.0f, self.view.center.y - 360.0f, 500, 150);
        remeberMeLabel.frame = CGRectMake(self.view.center.x + 135.0f, self.view.center.y - 240.0f, 150, 50);
        shouldRememberPassword.frame = CGRectMake(self.view.center.x + 310.0f, self.view.center.y - 228.0f, 150, 50);
        enterButton.frame = CGRectMake(self.view.center.x + 135.0f, self.view.center.y - 180.0f, 150, 50);
        tryButton.frame = CGRectMake(self.view.center.x + 440.0f, self.view.center.y - 170.0f, 120, 30);
        tryLinkView.frame = CGRectMake(self.view.center.x + 440.0f, self.view.center.y - 145.0f, 120, 1);
        logoView.center = CGPointMake(loginTable.view.center.x-460, loginTable.view.center.y+45);
    }

}	

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    if (![userDefs boolForKey:@"savePass"]) {
		[userDefs removeObjectForKey:@"login"];
		[userDefs removeObjectForKey:@"pass"];
	}
}


- (void)dealloc {
    [super dealloc];
}

@end
