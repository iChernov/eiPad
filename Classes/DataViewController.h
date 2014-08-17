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
//  DataViewController.h
//  StackScrollView
//
//  Created by Reefaq on 2/24/11.
//  Copyright 2011 raw engineering . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataSetPickerView.h"
#import "Bill.h"
#import "BillRepository.h"
#import "FillClientRequisitesTableViewController.h"
#import "addItemViewController.h"
#import "UIWebViewController.h"
#import "MBProgressHUD.h"

@protocol DataViewControllerDelegate <NSObject>

- (void)dataViewDidSaveBill:(int)bid;
- (void)dataViewDidDeleteBill;

@end

@interface DataViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ModalViewControllerDelegate, DatePickerDelegate, AddItemViewControllerDelegate, UICustomWebViewDelegate, DocumentHintPickerDelegate, MBProgressHUDDelegate> {
	UITableView*  _tableView;
    addItemViewController *aiView;
    Bill *currentBill;
    BillRepository *repo;
    DataSetPickerView *_dateSetPicker;
    UIPopoverController *_dateSetPickerPopover;
    UIView *contentView;
    UILabel *summaryLabel;
    UIView *MBProgressHUDView;
    MBProgressHUD *HUD;
    BOOL isMoreThanMaxCells;
    BOOL isMoveNeeded;
    BOOL clientWasLoaded;
    BOOL shouldMoveUpTable;
    int billId;
    int upMargin;
    int selectedCell;
    int addingCellCount;
    int maxTableHeight;
    BOOL editingClientNotEnded;
    UIButton *addNewItemButton, *cancelButton, *saveDocButton, *sendEmailButton, *makePreviewButton, *selectDateButton, *changeClientRequisitesButton, *deleteDocButton;
    UILabel *docNameLabel, *docNumberLabel, *clientLabel, *itogoLabel;
    UITextField *clientTextField, *docNumberTextField;
    id<DataViewControllerDelegate> _delegate;
    DocumentHintPickerController *_clientNameHintPicker;
    
}

@property (nonatomic, assign) id<DataViewControllerDelegate> delegate;
@property (nonatomic, retain) UIPopoverController *hintClientNamePickerPopover;

- (id)initWithFrame:(CGRect)frame;
- (void)redrawButtonsForExistingBill;
- (void)redrawButtonsForNewBill;
- (void)dataViewDidSaveBill;
- (void)dataViewDidDeleteBill;

@property (nonatomic, retain) UIPopoverController *dateSetPickerPopover;
@property (nonatomic, retain) DataSetPickerView *dateSetPicker;
@property (nonatomic, retain) UITableView* tableView;
@property (nonatomic, retain) DocumentHintPickerController *clientNameHintPicker;
@end
