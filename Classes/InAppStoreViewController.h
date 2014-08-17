//
//  InAppStoreViewController.h
//  E-Iphone
//
//  Created by Ivan Chernov on 16.03.11.
//  Copyright 2011 SKB-Kontur. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "MBProgressHUD.h"
#import "MKStoreManager.h"
@interface InAppStoreViewController : UIViewController <MBProgressHUDDelegate, MKStoreKitDelegate> {
	//IBOutlet UIButton *checkInventoryButton;
    UIView *MBProgressHUDView;
    MBProgressHUD *HUD;
	IBOutlet UIButton *oneMonthIPButton, *threeMonthsIPButton, *oneYearIPButton, *threeMonthsOOOButton, *oneYearOOOButton;
}
-(IBAction)buyOneMonthIP:(id)sender;
-(IBAction)buyThreeMonthsIP:(id)sender;
-(IBAction)buyYearIP:(id)sender;
-(IBAction)buyThreeMonthsOOO:(id)sender;
-(IBAction)buyYearOOO:(id)sender;
-(void)transactionCancelled;
-(void)setAllButtonsActive;
-(void)setAllButtonsUnactive;
//-(IBAction)checkInventory:(id)sender;

@end
