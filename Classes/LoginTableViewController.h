//
//  LoginTableViewController.h
//  eiPad
//
//  Created by Ivan Chernov on 03.08.11.
//  Copyright 2011 SKB-Kontur. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoginTableViewController : UITableViewController {
    UITextField *loginTextField, *passwordTextField;
}
@property(nonatomic, retain) UITextField *loginTextField;
@property(nonatomic, retain) UITextField *passwordTextField;
@end
