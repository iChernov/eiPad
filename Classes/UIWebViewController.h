//
//  UIWebViewController.h
//  E-Iphone
//
//  Created by Exile on 15.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "billWebView.h"
#import "MBProgressHUD.h"

@protocol UICustomWebViewDelegate
- (void)dismissPreview;
@end

@interface UIWebViewController : UIViewController <MFMailComposeViewControllerDelegate, UIScrollViewDelegate, MBProgressHUDDelegate> {
	//UIWebView *webView;
    NSMutableArray *webViews;
    NSMutableArray *htmls;
    UIView* showView;
    int scvHeight;
    MBProgressHUD *HUD;
    int scvWidth;
    double wholesum;
	UIScrollView *scV;
    NSString *dtype;
	UIButton *saveBillInPhotosButton;
	UIToolbar *actionsToolbar;
    id<UICustomWebViewDelegate> _delegate;
	UIButton *saveInPhotosButton;
}

@property (nonatomic, assign) id<UICustomWebViewDelegate> delegate;
@property (nonatomic, retain)  NSString *dtype;
-(void)mailIt;
-(void)saveBillInPhotos;
-(void)initActionPanel;
-(NSString *)nullableToString:(id) object;
-(void)buildTableWithItemsArr:(NSArray *)arr andBillInfo:(NSDictionary *)billInfo andTemplatePath:(NSString *)templatePath andWebFrame:(CGRect)webFrame
;
@end
