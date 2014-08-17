//
//  InAppStoreViewController.m
//  E-Iphone
//
//  Created by Ivan Chernov on 16.03.11.
//  Copyright 2011 SKB-Kontur. All rights reserved.
//

#import "InAppStoreViewController.h"

@implementation InAppStoreViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization.
 }
 return self;
 }
 */

#define kInAppPurchaseIPMonthSubscriptionProductId @"com.skbkontur.elbahd.ip.monthsubscription"
#define kInAppPurchaseIPThreeMonthsSubscriptionProductId @"com.skbkontur.elbahd.ip.threemonthsubscription"
#define kInAppPurchaseIPYearSubscriptionProductId @"com.skbkontur.elbahd.ip.yearsubscription"

#define kInAppPurchaseOOOThreeMonthsSubscriptionProductId @"com.skbkontur.elbahd.ooo.threemonthsubscription"
#define kInAppPurchaseOOOYearSubscriptionProductId @"com.skbkontur.elbahd.ooo.yearsubscription"


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [MKStoreManager setDelegate:self];
    [self drawExistingBillsActionButtons];
    self.navigationItem.title = @"Оплата Эльбы";
   /* UIImageView *bg = [UIImageView new];
    [bg setFrame:CGRectMake(0, 0, 320, 480)];
    [bg setImage:[UIImage imageNamed:@"iPhone4-back2.png"]];
    [self.view addSubview:bg];*/
    
    MBProgressHUDView = [[UIView  alloc] initWithFrame:CGRectMake(0, 0, 540, 500)];
    [self.view addSubview:MBProgressHUDView];
    
    
    
    // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
    HUD = [[MBProgressHUD alloc] initWithView: MBProgressHUDView];
	
    // Add HUD to screen
    [MBProgressHUDView addSubview:HUD];
	
    // Regisete for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
	
    HUD.labelText = @"Подключаюсь к iTunes Store...";
	
    // Show the HUD while the provided method executes in a new thread
	//[HUD show:YES];
    
	if ([SKPaymentQueue canMakePayments])
	{
        //      checkInventoryButton = [[UIButton alloc] initWithFrame:CGRectMake(36, 14, 250, 66)];
        //		[checkInventoryButton setBackgroundImage:[UIImage imageNamed:@"iPhone4-enter.png"] forState:UIControlStateNormal];
        //		[checkInventoryButton setBackgroundImage:[UIImage imageNamed:@"iPhone4-enter-down.png"] forState:UIControlStateHighlighted];
        //		[checkInventoryButton addTarget:self action:@selector(checkInventory:) forControlEvents:UIControlEventTouchUpInside];
        
		oneMonthIPButton = [[UIButton alloc] initWithFrame:CGRectMake(70, 50, 400, 106)];
        [oneMonthIPButton.titleLabel setText:@"ИП 1 месяц"];
		[oneMonthIPButton setBackgroundImage:[UIImage imageNamed:@"pay_month_up.png"] forState:UIControlStateNormal];
		[oneMonthIPButton setBackgroundImage:[UIImage imageNamed:@"pay_month_down.png"] forState:UIControlStateHighlighted];
		[oneMonthIPButton addTarget:self action:@selector(buyElba:) forControlEvents:UIControlEventTouchUpInside];	
        oneMonthIPButton.tag = 0;
		
		threeMonthsIPButton = [[UIButton alloc] initWithFrame:CGRectMake(70, 200, 400, 106)];
        [threeMonthsIPButton.titleLabel setText:@"ИП 3 месяца"];
		[threeMonthsIPButton setBackgroundImage:[UIImage imageNamed:@"pay_3months_up.png"] forState:UIControlStateNormal];
		[threeMonthsIPButton setBackgroundImage:[UIImage imageNamed:@"pay_3months_down.png"] forState:UIControlStateHighlighted];
		[threeMonthsIPButton addTarget:self action:@selector(buyElba:) forControlEvents:UIControlEventTouchUpInside];
        threeMonthsIPButton.tag = 1;
		
		oneYearIPButton = [[UIButton alloc] initWithFrame:CGRectMake(70, 350, 400, 106)];
        [oneYearIPButton.titleLabel setText:@"ИП 1 год"];
		[oneYearIPButton setBackgroundImage:[UIImage imageNamed:@"pay_year_up.png"] forState:UIControlStateNormal];
		[oneYearIPButton setBackgroundImage:[UIImage imageNamed:@"pay_year_down.png"] forState:UIControlStateHighlighted];
		[oneYearIPButton addTarget:self action:@selector(buyElba:) forControlEvents:UIControlEventTouchUpInside];
        oneYearIPButton.tag = 2;
        
        threeMonthsOOOButton = [[UIButton alloc] initWithFrame:CGRectMake(70, 50, 400, 106)];
        [threeMonthsOOOButton.titleLabel setText:@"ООО 3 месяца"];
		[threeMonthsOOOButton setBackgroundImage:[UIImage imageNamed:@"pay_3monthsOOO_up.png"] forState:UIControlStateNormal];
		[threeMonthsOOOButton setBackgroundImage:[UIImage imageNamed:@"pay_3monthsOOO_down.png"] forState:UIControlStateHighlighted];
		[threeMonthsOOOButton addTarget:self action:@selector(buyElba:) forControlEvents:UIControlEventTouchUpInside];
        threeMonthsOOOButton.tag = 3;
		
		oneYearOOOButton = [[UIButton alloc] initWithFrame:CGRectMake(70, 200, 400, 106)];
        [oneYearOOOButton.titleLabel setText:@"ООО 1 год"];
		[oneYearOOOButton setBackgroundImage:[UIImage imageNamed:@"pay_yearOOO_up.png"] forState:UIControlStateNormal];
		[oneYearOOOButton setBackgroundImage:[UIImage imageNamed:@"pay_yearOOO_down.png"] forState:UIControlStateHighlighted];
		[oneYearOOOButton addTarget:self action:@selector(buyElba:) forControlEvents:UIControlEventTouchUpInside];
        oneYearOOOButton.tag = 4;

        
        UITextView *costsText = [UITextView new];
        [costsText setFrame:CGRectMake(10, 520, 540, 95)];
        [costsText setBackgroundColor:[UIColor clearColor]];
        costsText.userInteractionEnabled = NO;
        [costsText setText:@"С вашего аккаунта в iTunes Store будут списаны соответствующие суммы в долларах США. Конкретные суммы будут показаны перед подтверждением покупки."];
        [self.view addSubview:costsText];
    }
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Предупреждение" message:@"На вашем iPhone стоит ограничение Родительского контроля. Для совершения покупок вам необходимо отключить его." delegate:self cancelButtonTitle:@"Ок" otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
    //    [self.view addSubview: checkInventoryButton];
    NSUserDefaults *udefs = [NSUserDefaults standardUserDefaults];
    if(![udefs boolForKey:@"isIP"])
    {
        [self.view addSubview:threeMonthsOOOButton];
        [self.view addSubview:oneYearOOOButton];
    }
    else
    {
        [self.view addSubview:oneMonthIPButton];
        [self.view addSubview:threeMonthsIPButton];
        [self.view addSubview:oneYearIPButton];
    }
    [self setAllButtonsHidden];
   // [self requestProductData];
    [self setAllButtonsVisible];
	[self.view setNeedsDisplay];
    
}

- (void)drawExistingBillsActionButtons
{	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] 
									 initWithTitle:@"Назад" style:UIBarButtonItemStylePlain
									 target:self action:@selector(cancel)];
	
	self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];
}

-(void)cancel
{
	[self dismissModalViewControllerAnimated:YES];
}

-(void)setAllButtonsHidden
{
    //    checkInventoryButton.hidden = YES;
    oneMonthIPButton.hidden = YES;
    threeMonthsIPButton.hidden = YES;
    oneYearIPButton.hidden = YES;
    threeMonthsOOOButton.hidden = YES;
    oneYearOOOButton.hidden = YES;
}

-(void)setAllButtonsUnactive
{
    oneMonthIPButton.enabled = NO;
    threeMonthsIPButton.enabled = NO;
    oneYearIPButton.enabled = NO;
    threeMonthsOOOButton.enabled = NO;
    oneYearOOOButton.enabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
}

-(void)setAllButtonsActive
{
    oneMonthIPButton.enabled = YES;
    threeMonthsIPButton.enabled = YES;
    oneYearIPButton.enabled = YES;
    threeMonthsOOOButton.enabled = YES;
    oneYearOOOButton.enabled = YES;
    self.navigationItem.leftBarButtonItem.enabled = YES;
}

-(void)setAllButtonsVisible
{
    //    checkInventoryButton.hidden = NO;
    
    oneMonthIPButton.hidden = NO;
    threeMonthsIPButton.hidden = NO;
    oneYearIPButton.hidden = NO;
    threeMonthsOOOButton.hidden = NO;
    oneYearOOOButton.hidden = NO;
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.title == @"Предупреждение") {
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (void) requestProductData
{
    SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: 
                                 [NSSet setWithObjects: kInAppPurchaseIPMonthSubscriptionProductId, 
                                  kInAppPurchaseIPThreeMonthsSubscriptionProductId, 
                                  kInAppPurchaseIPYearSubscriptionProductId,
                                  kInAppPurchaseOOOThreeMonthsSubscriptionProductId,
                                  kInAppPurchaseOOOYearSubscriptionProductId,
                                  nil]];
    request.delegate = self;
    [request start];
}
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:
(SKProductsResponse *)response
{
    NSArray *myProduct = response.products;
   //NSLog(@"Product count: %d", [myProduct count]);
    // populate UI
    for(int i=0;i<[myProduct count];i++)
    {
        SKProduct *product = [myProduct objectAtIndex:i];
       //NSLog(@"Name: %@ - Price: %f", [product localizedTitle], [[product price] doubleValue]);
       //NSLog(@"Product identifier: %@", [product productIdentifier]);
    }
    
    NSArray *items = response.products;
    
   // NSArray *myProduct = response.products;
    // populate UI
    //[self performSelector:@selector(setAllButtonsActive) withObject:self afterDelay: 7];
    [request autorelease];
    //[HUD hide:YES];
}

//-(IBAction)checkInventory:(id)sender
//{
//    
//}transactionSuccessful
-(void)transactionCanceled
{
    [self setAllButtonsActive];
}

-(void)transactionSuccessful
{
    [self setAllButtonsActive];
}


-(IBAction)buyElba:(id)sender
{
    [self setAllButtonsUnactive];
    NSUInteger *tid = ((UIControl *) sender).tag;
    [[MKStoreManager sharedManager] buyFeature:[self getFeatureIdByNumber:tid]];
}

-(NSString *)getFeatureIdByNumber:(int)numb
{
    NSArray *featureArr = [NSArray arrayWithObjects: kInAppPurchaseIPMonthSubscriptionProductId, 
                           kInAppPurchaseIPThreeMonthsSubscriptionProductId, 
                           kInAppPurchaseIPYearSubscriptionProductId,
                           kInAppPurchaseOOOThreeMonthsSubscriptionProductId,
                           kInAppPurchaseOOOYearSubscriptionProductId,
                           nil];
    return [featureArr objectAtIndex:numb];
}



 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return YES;
 }
 

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
