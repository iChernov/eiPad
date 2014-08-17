//
//  CabinetViewController.h
//  E-Iphone
//
//  Created by Ivan Chernov on 08.04.11.
//  Copyright 2011 SKB-Kontur. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TillDateReceiver.h"

@interface CabinetViewController : UIViewController <CabinetControllerDelegate> {
    UIButton *goToStoreButton;
    UIButton *exitButton;
    int numOfLines;
    CGFloat topBarHeight;
}
-(id)initWithTitle:(NSString *)title;
-(void)goToStore;
-(void)exit;
- (void)showTillDateLabelWithCGRect:(CGRect)rect;
@end
