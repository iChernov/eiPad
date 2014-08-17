//
//  UIWebViewController.m
//  E-Iphone
//
//  Created by Exile on 15.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIWebViewController.h"
#import "MGTemplateEngine.h"
#import "ICUTemplateMatcher.h"
#import "funcs.h"
#import "instrViewController.h"


@implementation UIWebViewController
@synthesize dtype;
@synthesize delegate = _delegate;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

- (id)initWithBill:(NSDictionary *)billInfo andMailBool:(BOOL)mailNeeded
{
	[super init];
    scvHeight = 10;
    scvWidth = 0;
    wholesum = 0;
	webViews = [[NSMutableArray alloc] init];
    htmls = [[NSMutableArray alloc] init];
    self.navigationItem.title = @"Предварительный просмотр";
	/*UIButton *sendEmailButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	sendEmailButton.frame = CGRectMake(0, 0, 42, 30);
	[sendEmailButton setBackgroundImage:[UIImage imageNamed:@"mail_icon.png"] forState:UIControlStateNormal];
	[sendEmailButton addTarget:self action:@selector(mailIt) forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *mailItem = [[UIBarButtonItem alloc] initWithCustomView:sendEmailButton];
	
	UIView *printButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	printButton.frame = CGRectMake(0, 0, 42, 30);
	[printButton setBackgroundImage:[UIImage imageNamed:@"printer_button.png"] forState:UIControlStateNormal];
	[printButton addTarget:self action:@selector(saveBillInPhotos) forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *printItem = [[UIBarButtonItem alloc] initWithCustomView:printButton];
	
	
	// create a toolbar to have two buttons in the right
	UIToolbar* tools = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 118, 45)];
    tools.tintColor = [UIColor colorWithRed:0 green:0.38 blue:0.6 alpha:1];
	
	// create the array to hold the buttons, which then gets added to the toolbar
	NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:3];
	
	[buttons addObject:printItem];
	[buttons addObject:mailItem];
	[mailItem release];
	[printItem release];
	[sendEmailButton release];
	[printButton release];
	
	// stick the buttons in the toolbar
	[tools setItems:buttons animated:NO];
	
	[buttons release];
	*/
	// and put the toolbar in the nav bar

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Готово" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Сохранить в фотоальбоме" style:UIBarButtonItemStylePlain target:self action:@selector(saveBillInPhotos)];

	
	
	NSString *templatePath;
    
	int lineH = 0;
    CGFloat height = 0;
    CGRect webFrame = CGRect();
	NSArray *arr = [billInfo objectForKey:@"Items"];
	int numberOfItems = [arr count];
	
    dtype = [billInfo objectForKey: @"DocumentType"];
    scvWidth = 750;
    if([dtype isEqualToString:@"Акт"])
    {
        lineH = 25;
        height = 720+lineH*numberOfItems;
        webFrame = CGRectMake(0.0, 0.0, 768.0, height);
        templatePath = [[NSBundle mainBundle] pathForResource:@"Act" ofType:@"html"];
        [self buildTableWithItemsArr:arr andBillInfo:billInfo andTemplatePath:templatePath andWebFrame:webFrame andAddedNumber:0];
    }
    else if([dtype isEqualToString:@"Счет"])
    {
        lineH = 34;
        height = 720+lineH*numberOfItems;
        webFrame = CGRectMake(0.0, 0.0, 768.0, height);
        templatePath = [[NSBundle mainBundle] pathForResource:@"bill" ofType:@"html"];
        [self buildTableWithItemsArr:arr andBillInfo:billInfo andTemplatePath:templatePath andWebFrame:webFrame andAddedNumber:0];
    }
    else if([dtype isEqualToString:@"Накладная"])
    {
        scvWidth = 1100;
        int firstPageAddedH = 500;
        lineH = 20;
        if(numberOfItems <= 1)
        {
            height = 850;
            webFrame = CGRectMake(0.0, 0.0, scvWidth, height);
            templatePath = [[NSBundle mainBundle] pathForResource:@"DeliveryNoteWhole" ofType:@"html"];
            [self buildTableWithItemsArr:arr andBillInfo:billInfo andTemplatePath:templatePath andWebFrame:webFrame andAddedNumber:0];
        }
        else
        {
            int numberOf23 = (numberOfItems-12)/23;
            
            
            if(numberOfItems < 13)
            {
                float y = 0.0;
                templatePath = [[NSBundle mainBundle] pathForResource:@"DeliveryNoteBegin" ofType:@"html"];
                webFrame = CGRectMake(0.0, y, scvWidth, firstPageAddedH+lineH*(numberOfItems-1));
                [self buildTableWithItemsArr:[NSArray arrayWithArray: [arr subarrayWithRange:NSMakeRange (0, numberOfItems-1)]] andBillInfo:billInfo andTemplatePath:templatePath andWebFrame:webFrame andAddedNumber:0];
                y+=firstPageAddedH+lineH*(numberOfItems-1);
               
                
                templatePath = [[NSBundle mainBundle] pathForResource:@"DeliveryNoteEnd" ofType:@"html"];
                webFrame = CGRectMake(0.0, y, scvWidth, 525);
                [self buildTableWithItemsArr:[NSArray arrayWithObject:[arr lastObject]] andBillInfo:billInfo andTemplatePath:templatePath andWebFrame:webFrame andAddedNumber: numberOfItems-1];
            }
            else if((numberOfItems - 12)%23 < 12)
            {
                float y = 0.0;
                int middleHeight = 570;
                templatePath = [[NSBundle mainBundle] pathForResource:@"DeliveryNoteBegin" ofType:@"html"];
                webFrame = CGRectMake(0.0, y, scvWidth, 700);
                [self buildTableWithItemsArr:[NSArray arrayWithArray: [arr subarrayWithRange:NSMakeRange (0, 12)]] andBillInfo:billInfo andTemplatePath:templatePath andWebFrame:webFrame andAddedNumber:0];
                y+=700;
                
                for(int i = 1; i<=numberOf23; i++)
                {
                    templatePath = [[NSBundle mainBundle] pathForResource:@"DeliveryNoteMiddle" ofType:@"html"];
                    webFrame = CGRectMake(0.0, y, scvWidth, middleHeight);
                    [self buildTableWithItemsArr:[NSArray arrayWithArray: [arr subarrayWithRange:NSMakeRange (12+(i-1)*23, ((i == numberOf23)&&((numberOfItems - 12)%23 == 0) ? 22 : 23))]] andBillInfo:billInfo andTemplatePath:templatePath andWebFrame:webFrame andAddedNumber:12+(i-1)*23];
                    y+=middleHeight;
                }
                templatePath = [[NSBundle mainBundle] pathForResource:@"DeliveryNoteEnd" ofType:@"html"];
                int lastItems = (numberOfItems - 12)%23;
                if(lastItems == 0)
                    lastItems = 1;
                NSArray* array = [NSArray arrayWithArray: [arr subarrayWithRange:NSMakeRange (numberOfItems-lastItems, lastItems)]];
                webFrame = CGRectMake(0.0, y, scvWidth, firstPageAddedH+lineH*lastItems);

               
                [self buildTableWithItemsArr:array andBillInfo:billInfo andTemplatePath:templatePath andWebFrame:webFrame andAddedNumber:numberOfItems-lastItems];
            }
            else
            {
                float y = 0.0;
                templatePath = [[NSBundle mainBundle] pathForResource:@"DeliveryNoteBegin" ofType:@"html"];
                webFrame = CGRectMake(0.0, y, scvWidth, 700);
                y+=700;
                [self buildTableWithItemsArr:[NSArray arrayWithArray: [arr subarrayWithRange:NSMakeRange (0, 12)]] andBillInfo:billInfo andTemplatePath:templatePath andWebFrame:webFrame andAddedNumber:0];
                if(numberOfItems > 34)
                {
                    for(int i = 1; i<=numberOf23; i++)
                    {
                        templatePath = [[NSBundle mainBundle] pathForResource:@"DeliveryNoteMiddle" ofType:@"html"];
                        webFrame = CGRectMake(0.0, y, scvWidth, 700);
                        [self buildTableWithItemsArr:[NSArray arrayWithArray: [arr subarrayWithRange:NSMakeRange (12+(i-1)*23, 23)]] andBillInfo:billInfo andTemplatePath:templatePath andWebFrame:webFrame andAddedNumber:12+(i-1)*23];
                        y+=700;
                    }
                }
                templatePath = [[NSBundle mainBundle] pathForResource:@"DeliveryNoteMiddle" ofType:@"html"];
                int howMuchItemsInThePreLastSection = (numberOfItems - 12)%23 - 1;
                webFrame = CGRectMake(0.0, y, scvWidth, 100+howMuchItemsInThePreLastSection*lineH);
                [self buildTableWithItemsArr:[NSArray arrayWithArray: [arr subarrayWithRange:NSMakeRange ([arr count]-howMuchItemsInThePreLastSection-1, howMuchItemsInThePreLastSection)]] andBillInfo:billInfo andTemplatePath:templatePath andWebFrame:webFrame andAddedNumber:[arr count]-howMuchItemsInThePreLastSection-1];
                y+=100+howMuchItemsInThePreLastSection*lineH;
                templatePath = [[NSBundle mainBundle] pathForResource:@"DeliveryNoteEnd" ofType:@"html"];
                webFrame = CGRectMake(0.0, y, scvWidth, 525);
                [self buildTableWithItemsArr:[NSArray arrayWithObject:[arr lastObject]] andBillInfo:billInfo andTemplatePath:templatePath andWebFrame:webFrame andAddedNumber:numberOfItems-1];
            }
        }
    }
	
	[self drawWebViews:webViews];
	if (mailNeeded) {
        [self.navigationItem.leftBarButtonItem release];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Отправить по e-mail" style:UIBarButtonItemStylePlain target:self action:@selector(mailIt)];
    }
	return self;
}

-(void)buildTableWithItemsArr:(NSArray *)arr andBillInfo:(NSDictionary *)billInfo andTemplatePath:(NSString *)templatePath andWebFrame:(CGRect)webFrame andAddedNumber:(int)number
{
	int numberOfItems = [arr count];
    MGTemplateEngine *engine = [MGTemplateEngine templateEngine];
	[engine setMatcher:[ICUTemplateMatcher matcherWithTemplateEngine:engine]];
    NSMutableDictionary *variables = [[NSMutableDictionary alloc] init];
    double allSummary = 0;
	NSMutableArray *showingItems = [[NSMutableArray alloc] init];
	NSArray *ta = (NSArray *)[billInfo valueForKey:@"Client"];
	[variables setObject:[billInfo valueForKey:@"BillNumb"] forKey:@"docNumbLabel"];
	[variables setObject:[billInfo valueForKey:@"BillDate"] forKey:@"docDateLabel"];
	[variables setObject:[ta objectAtIndex:2] forKey:@"clNameLabel"];
    
    NSString *clientKPPRequisites = @"";
    if ([(NSString *)[ta objectAtIndex:4] length] == 10) {
        clientKPPRequisites = [NSString stringWithFormat:@", КПП %@", [ta objectAtIndex:5]];
    }
    
    NSString *clientRequisites = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", 
                                  ([[ta objectAtIndex:3] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@"%@", [ta objectAtIndex:3]]),
                                  ([[ta objectAtIndex:4] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@", ИНН %@", [ta objectAtIndex:4]]),
                                  clientKPPRequisites,
                                  ([[ta objectAtIndex:8] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@", р/сч %@", [ta objectAtIndex:8]]),
                                  ([[ta objectAtIndex:7] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@", %@", [ta objectAtIndex:7]]),
                                  ([[ta objectAtIndex:9] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@", корр.сч. %@", [ta objectAtIndex:9]]),
                                  ([[ta objectAtIndex:6] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@", БИК %@", [ta objectAtIndex:6]])];
	[variables setObject:clientRequisites forKey:@"clRequisites"];

    [variables setObject:[self nullableToString: [ta objectAtIndex:3]] forKey:@"Caddress"];
	[variables setObject:[self nullableToString: [ta objectAtIndex:4]] forKey:@"CINN"];
	[variables setObject:[self nullableToString: [ta objectAtIndex:5]] forKey:@"CKPP"];
	[variables setObject:[self nullableToString: [ta objectAtIndex:7]] forKey:@"CbankName"];
	[variables setObject:[self nullableToString: [ta objectAtIndex:6]] forKey:@"CbankBIK"];
	[variables setObject:[self nullableToString: [ta objectAtIndex:8]] forKey:@"Crs"];
	[variables setObject:[self nullableToString: [ta objectAtIndex:9]] forKey:@"Cks"];
    
    int lastNumber = 0;
	for (int i=0; i<numberOfItems; i++) {
		NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithDictionary:[arr objectAtIndex:i]];
		[item setObject:[[NSString alloc] initWithFormat:@"%d", i+1+number] forKey:@"number"];
        lastNumber = i+1+number;
		allSummary += [[item valueForKey:@"Summary"] doubleValue];
		[showingItems addObject:item];
	}
	//допеределать с массива на словарь
	wholesum += allSummary;
	NSString *noi = [[NSString alloc] initWithFormat:@"%d",numberOfItems];
	NSString *summary = [[[NSString alloc] initWithFormat:@"%.2f",allSummary] stringByReplacingOccurrencesOfString:@"."
                                                                                                        withString:@","];
    
    NSString *wholeSummary = [[[NSString alloc] initWithFormat:@"%.2f",wholesum] stringByReplacingOccurrencesOfString:@"."
                                                                                                        withString:@","];
    
	NSString *summaryWord = [[NSString alloc] initWithCString:(numberToString(wholesum)) encoding:NSUTF8StringEncoding];
	[variables setObject:showingItems forKey:@"items"];
	[variables setObject:noi forKey:@"numberOfItems"];
    [variables setObject:wholeSummary forKey:@"wholeSummary"];
	[variables setObject:summary forKey:@"summary"];
	[variables setObject:summaryWord forKey:@"summaryWord"];
    NSString *placesWord = [[NSString alloc] initWithCString:(numberToString(lastNumber)) encoding:NSUTF8StringEncoding];
    [variables setObject:[[placesWord componentsSeparatedByString:@" "] objectAtIndex:0] forKey:@"placesLabel"];
	
	NSString *selfInfoStr = [NSString stringWithFormat:@"%@/selfInfo.plist", [[NSUserDefaults standardUserDefaults] stringForKey:@"UserUID"]];
	NSString *nameStr = [[NSString alloc] initWithString:selfInfoStr];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *savingDictFileName = [documentsDirectory stringByAppendingPathComponent:nameStr];
	NSDictionary *selfInfoArr = [[NSDictionary alloc] initWithContentsOfFile:savingDictFileName];
	if([[NSUserDefaults standardUserDefaults] boolForKey:@"isIP"])
	{
		[variables setObject:@"ИП" forKey:@"IPorOOO"];
		[variables setObject:@"Индивидуальный предприниматель" forKey:@"IPorPROFESSION"];
		NSMutableString *tempstr = [NSMutableString new];
		[tempstr appendFormat:@"%@", [self nullableToString: [selfInfoArr objectForKey:@"Surname"]]];
		[tempstr appendFormat:@" "];
		[tempstr appendFormat:@"%@", [self nullableToString: [selfInfoArr objectForKey:@"Name"]]];
		[tempstr appendFormat:@" "];
		[tempstr appendFormat:@"%@", [self nullableToString: [selfInfoArr objectForKey:@"Patronymic"]]];
		[variables setObject:tempstr forKey:@"selfName"];
	}
	else {
		[variables setObject:@"" forKey:@"IPorOOO"];
		
		[variables setObject:[self nullableToString: [selfInfoArr objectForKey:@"OrganizationShortName"]] forKey:@"selfName"];
	}
	[variables setObject:[self nullableToString: [selfInfoArr objectForKey:@"Address"]] forKey:@"address"];
	[variables setObject:[self nullableToString: [selfInfoArr objectForKey:@"Phone"]] forKey:@"phoneNumber"];
	[variables setObject:[self nullableToString: [selfInfoArr objectForKey:@"INN"]] forKey:@"INN"];
	[variables setObject:[self nullableToString: [selfInfoArr objectForKey:@"KPP"]] forKey:@"KPP"];
	[variables setObject:[self nullableToString: [selfInfoArr objectForKey:@"BankName"]] forKey:@"bankName"];
	[variables setObject:[self nullableToString: [selfInfoArr objectForKey:@"BankBik"]] forKey:@"bankBIK"];
	[variables setObject:[self nullableToString: [selfInfoArr objectForKey:@"AccountNumber"]] forKey:@"rs"];
	[variables setObject:[self nullableToString: [selfInfoArr objectForKey:@"BankCorrAccount"]] forKey:@"ks"];
    NSMutableString *deliveryNoteEntity = [NSMutableString new];
    [deliveryNoteEntity appendFormat:@"%@ %@", [variables objectForKey:@"IPorOOO"], [variables objectForKey:@"selfName"]];
    [deliveryNoteEntity appendFormat:@"%@", ([[variables objectForKey:@"address"] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@", %@", [variables objectForKey:@"address"]])];
    [deliveryNoteEntity appendFormat:@"%@", ([[variables objectForKey:@"INN"] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@", ИНН %@", [variables objectForKey:@"INN"]])];
    [deliveryNoteEntity appendFormat:@"%@", ([[variables objectForKey:@"KPP"] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@", КПП %@", [variables objectForKey:@"KPP"]])];
    [deliveryNoteEntity appendFormat:@"%@", ([[variables objectForKey:@"rs"] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@", р/сч %@", [variables objectForKey:@"rs"]])];
    [deliveryNoteEntity appendFormat:@"%@", ([[variables objectForKey:@"bankName"] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@", банк %@", [variables objectForKey:@"bankName"]])];
    [deliveryNoteEntity appendFormat:@"%@", ([[variables objectForKey:@"ks"] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@", корр.счет %@", [variables objectForKey:@"ks"]])];
    [deliveryNoteEntity appendFormat:@"%@", ([[variables objectForKey:@"bankBIK"] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@", БИК %@", [variables objectForKey:@"bankBIK"]])];
    [variables setObject:deliveryNoteEntity forKey:@"deliveryNoteEntity"];
    
	[self insertValuesIn:variables from:selfInfoArr];
	
	NSString *htmlPage = [engine processTemplateInFileAtPath:templatePath withVariables:variables];
    [htmls addObject:htmlPage];
	UIWebView *wV = [[UIWebView alloc] initWithFrame:webFrame];
	wV.detectsPhoneNumbers = NO;
	[wV loadHTMLString:htmlPage baseURL:nil];
	[wV setBackgroundColor:[UIColor whiteColor]];
	[variables release];
	[wV autorelease];
    [webViews addObject: wV];
	scvHeight += webFrame.size.height;	
}

- (void)drawWebViews:(NSArray *)webViews
{
    if((self.interfaceOrientation == UIDeviceOrientationPortrait) || (self.interfaceOrientation == UIDeviceOrientationPortraitUpsideDown))
    {
        scV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 768, 980)];
    }
    else
    {
        scV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 768, 706)];
    }
    
	scV.bouncesZoom = YES;
	scV.delegate = self;
    scV.contentSize = CGSizeMake(scvWidth, scvHeight);
	scV.showsVerticalScrollIndicator = NO;
	scV.showsHorizontalScrollIndicator = NO;
	[scV setBackgroundColor:[UIColor whiteColor]];
    scV.maximumZoomScale = 1.0;
    if([dtype isEqualToString:@"Накладная"])
    {
        scV.minimumZoomScale = .70;
    }
    else
    {
        scV.minimumZoomScale = 1.0;
    }
   
	[self.view addSubview:scV];	
	[scV setDelegate:self];
    showView = [[UIView alloc] initWithFrame:CGRectMake(0,0,scvWidth,scvHeight)];
    for (UIWebView *webView in webViews) {
        [showView addSubview:webView];
    }
    showView.userInteractionEnabled = NO;
    [scV addSubview:showView];
    if([dtype isEqualToString:@"Накладная"])
    {
        [scV setZoomScale:0.70 animated:YES];
    }
    else
    {
        [scV setZoomScale:1.00 animated:YES];
    }
    
	[scV becomeFirstResponder];
}

- (void)insertValuesIn:(NSMutableDictionary *)variables from:(NSDictionary *)selfInfoDct
{
	for (NSString *key in [selfInfoDct allKeys]) {
		[variables setObject:([self nullableToString: [selfInfoDct objectForKey:key] ]) forKey:key];
	}
}

-(NSString *)nullableToString:(id) object {
	if (object == nil) {
		return @"";
	}
	else {
		return (NSString *) object;
	}
	
}


- (void)viewDidLoad {
    [super viewDidLoad];
}
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
/*- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
	for (UITouch *touch in touches) {
        if (touch.tapCount >= 2) {
			if(scV.zoomScale > .43)
			{
				scV.zoomScale = .43;
			}
			else {
				scV.zoomScale = 1.0;
			}
        }
    }
	return YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        if (touch.tapCount == 2) {
			if(scV.zoomScale > .43)
			{
				scV.zoomScale = .43;
			}
			else {
				scV.zoomScale = 1.0;
			}
        }
    }
}*/

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
	return NO;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return showView;
}


-(void)initActionPanel
{
	actionsToolbar = [UIToolbar new];
	actionsToolbar.barStyle = UIBarStyleDefault;
	[actionsToolbar sizeToFit];
	actionsToolbar.frame = CGRectMake(0, 380, 320, 40);
	
	UIBarButtonItem *systemItem1 = [[UIBarButtonItem alloc] initWithTitle:@"Отправить по e-mail" 
																style:UIBarButtonItemStyleBordered
																target:self
																action:@selector(mailIt)];
																   
	
	UIBarButtonItem *systemItem2 =[[UIBarButtonItem alloc] initWithTitle:@"Сохранить в фото" 
																   style:UIBarButtonItemStyleBordered
																  target:self
																  action:@selector(saveBillInPhotos)];
	
	UIBarButtonItem	*flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	NSArray *actionItems = [NSArray arrayWithObjects: flex, systemItem1, flex, systemItem2, flex, nil];
	[actionsToolbar setItems:actionItems animated:NO];
	[self.view addSubview:actionsToolbar];
	
}
-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{
	[self dismissModalViewControllerAnimated:YES];
}

-(void)mailIt 
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	
	picker.mailComposeDelegate = self;
	
	[picker setSubject:[NSString stringWithFormat: @"%@ от пользователя электронного бухгалтера Эльба", dtype]];
    
    int i=0;
	for(UIImage* docImage in [self getWebViewsPics])
    {
        NSData *imageData = UIImageJPEGRepresentation(docImage, 1);
        [picker addAttachmentData:imageData mimeType:@"image/jpg" fileName:[NSString stringWithFormat:@"bill-%d.jpg", i]];
        i++;
    }
    /*for(UIWebView* webView in webViews)
    {
        NSData *webViewData = [NSKeyedArchiver archivedDataWithRootObject:webView];
        [picker addAttachmentData:webViewData mimeType:@"text/html" fileName:[NSString stringWithFormat:@"bill-%d.html", i]];
        i++;
    }*/
	
	
	NSString *emailBody = [NSString stringWithFormat: @"В приложении находится %@ от пользователя электронного бухгалтера Эльба", [dtype lowercaseString]];
    [picker setMessageBody:emailBody isHTML:YES];
	@try {
		[self presentModalViewController:picker animated:YES];
	}
	@catch (NSException *exception) {

	}
	@finally {
		[picker release];
	}
}

-(NSArray *)getWebViewsPics
{
    NSMutableArray* pics = [NSMutableArray new];
    for (UIWebView* webView in webViews) {
        UIGraphicsBeginImageContext(webView.bounds.size);
        [webView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *billImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [pics addObject:billImage];
    }

    return pics;
}

-(void)saveBillInPhotos
{

        // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
        HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
        
        // Add HUD to screen
        [self.view.window addSubview:HUD];
        
        // Regisete for HUD callbacks so we can remove it from the window at the right time
        HUD.delegate = self;
        
        HUD.labelText = @"Сохраняю документ...";
        
        // Show the HUD while the provided method executes in a new thread
        
        [HUD showWhileExecuting:@selector(saveBillInPhotosProcess) onTarget:self withObject:nil animated:YES];

}

-(void)saveBillInPhotosProcess
{
    [self.navigationItem.leftBarButtonItem release];
    UIActivityIndicatorView *activityIndicator = 
    [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    UIBarButtonItem * barButton = 
    [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [[self navigationItem] setLeftBarButtonItem:barButton];
    [barButton release];

    
    NSArray* arr = [self getWebViewsPics];
    for(int i=0; i<[arr count]; i++)
    {
        UIImageWriteToSavedPhotosAlbum([arr objectAtIndex:i], nil, nil, nil);
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Сохранить в фотоальбоме" style:UIBarButtonItemStylePlain target:self action:@selector(saveBillInPhotos)];
    
    HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark@2x.png"]] autorelease];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = @"Готово!";
    [NSThread sleepForTimeInterval:1.0];
}


 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
    return YES;
}

- (void)done
{
    [self.delegate dismissPreview];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        scV.frame = CGRectMake(0, 0, 768, 706);
    }
    else
    {
        scV.frame =  CGRectMake(0, 0, 768, 980);
    }
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [webViews removeAllObjects];
    [webViews release];
    [super dealloc];
}


@end
