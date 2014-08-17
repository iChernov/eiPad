//
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
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.f
 */
//  DataViewController.m
//  StackScrollView
//
//  Created by Reefaq on 2/24/11.
//  Copyright 2011 raw engineering . All rights reserved.
//
#import "itemContainer.h"
#import "DataViewController.h"
#import "StackScrollViewAppDelegate.h"
#import "RootViewController.h"
#import "StackScrollViewController.h"
#import "BillNumberCounter.h"
#import "itemTableViewCell.h"
#import "chooseOrCreateNewTableViewCell.h"
@implementation DataViewController
@synthesize tableView = _tableView;
@synthesize dateSetPicker = _dateSetPicker;
@synthesize dateSetPickerPopover = _dateSetPickerPopover;
@synthesize delegate = _delegate;
@synthesize clientNameHintPicker = _clientNameHintPicker;
@synthesize hintClientNamePickerPopover;

#pragma mark -
#pragma mark View lifecycle

const int maxVerticalCellNumber = 8;
const int maxHorizontalCellNumber = 4;

- (id)initWithFrame:(CGRect)frame docType:(NSString *)dtype andBillId:(int)receivedBillId{
    if (self = [super init]) {
        [self.view setFrame:frame]; 
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg2.png"]]];
        contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1004)];
        [contentView setBackgroundColor:[UIColor clearColor]];
        shouldMoveUpTable = NO;
        billId = receivedBillId;
        clientWasLoaded = NO;
        addNewItemButton = [[UIButton alloc] init];
        [contentView addSubview:addNewItemButton];
        
        repo = [[BillRepository alloc] init];  
        addingCellCount = 0;
        selectedCell = -1;
        if (receivedBillId > -1) {
            currentBill = [[repo loadWithId:receivedBillId] retain];
        }
        else
        {
            currentBill = [[Bill alloc] init];
            currentBill.BillNumb = [[BillNumberCounter findNextBillNumberForDocType:dtype] retain];

            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"dd.MM.YYYY"];
            NSDate *dat = [[NSDate alloc] init];
            NSString *today = [dateFormatter stringFromDate:dat];
            [dateFormatter release];
            currentBill.DocumentType = dtype;
            currentBill.BillDate = [today retain];
            [dat release];
        }
        [self drawUpperButtonsAndLabels];
        
        [self initMoveVariables];
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 230, 520, (isMoreThanMaxCells ? maxTableHeight : [[currentBill Items] count]*65)) style:UITableViewStylePlain];
		
        [_tableView setDelegate:self];
		[_tableView setDataSource:self];
		_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentView.frame.size.width, 1)];
        [_tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg2.png"]]];
		[contentView addSubview:_tableView];
        
        addNewItemButton = [[UIButton alloc] initWithFrame:CGRectMake(251, 245 + _tableView.frame.size.height, 242, 44)];
        [addNewItemButton setBackgroundImage:[UIImage imageNamed:@"addthing_button.png"] forState:UIControlStateNormal];
        [addNewItemButton setBackgroundImage:[UIImage imageNamed:@"addthing_button__pressed.png"] forState:UIControlStateSelected];
        [addNewItemButton setTitle:@"   Добавить" forState:UIControlStateNormal];
        [addNewItemButton setTitleColor:[UIColor colorWithRed:0.467 green:0.408 blue:0.353 alpha:1] /*#77685a*/  forState:UIControlStateNormal];
        [addNewItemButton setTitleColor:[UIColor colorWithRed:0.643 green:0.565 blue:0.486 alpha:1] /*#a4907c*/  forState:UIControlStateSelected];

        if (isMoreThanMaxCells) {
            _tableView.scrollEnabled = YES;
        }
        else
        {
            _tableView.scrollEnabled = NO;
        }
        [self.view addSubview:contentView];
        [self drawAddItemButton];
	}
    return self;
}

- (void)setDate
{
    if (_dateSetPicker == nil) {
        self.dateSetPicker = [[[DataSetPickerView alloc] init] autorelease];
        _dateSetPicker.delegate = self;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd.mm.yyyy"];
        NSDate *date = [dateFormat dateFromString:selectDateButton.titleLabel.text];
        _dateSetPicker.datepicker.date = date;
        self.dateSetPicker = [[[UIPopoverController alloc] initWithContentViewController:_dateSetPicker] autorelease];               
    }
    [self.dateSetPicker presentPopoverFromRect:CGRectMake(251, 96, 242, 44) inView:contentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)DateSelected:(NSString *)Date
{
    [selectDateButton setTitle:[NSString stringWithFormat:@"    %@", Date] forState:UIControlStateNormal];
    currentBill.BillDate = Date;
    [self redrawButtonsForNewBill];
}

- (void)drawUpperButtonsAndLabels
{
    docNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 15, 210, 25)];
    [docNameLabel setBackgroundColor:[UIColor clearColor]];
    docNameLabel.textAlignment = UITextAlignmentCenter;
    [docNameLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
    [docNameLabel setTextColor:[UIColor colorWithRed:0.29 green:0.133 blue:0 alpha:1] ];
    [docNameLabel setText:[NSString stringWithFormat:@"%@ №%@",currentBill.DocumentType, currentBill.BillNumb]];
    
    docNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(27, 70, 143, 20)];
    [docNumberLabel setBackgroundColor:[UIColor clearColor]];
    [docNumberLabel setTextColor:[UIColor colorWithRed:0.29 green:0.133 blue:0 alpha:1] ];
    [docNumberLabel setText:@"Номер документа"];
    
    clientLabel = [[UILabel alloc] initWithFrame:CGRectMake(27, 150, 143, 20)];
    [clientLabel setBackgroundColor:[UIColor clearColor]];
    [clientLabel setTextColor:[UIColor colorWithRed:0.29 green:0.133 blue:0 alpha:1] ];
    [clientLabel setText:@"Клиент"];
    
    [contentView addSubview:docNameLabel];
    [contentView addSubview:docNumberLabel];
    [contentView addSubview:clientLabel];
    
    sendEmailButton = [[UIButton alloc] initWithFrame:CGRectMake(27, 15, 130, 25)];
    [sendEmailButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:12.0]];
    [sendEmailButton setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
    [sendEmailButton setBackgroundImage:[UIImage imageNamed:@"button__pressed.png"] forState:UIControlStateSelected];
    [sendEmailButton setTitle:@"Отправить по e-mail" forState:UIControlStateNormal];
    [sendEmailButton setTitleColor:[UIColor colorWithRed:0.467 green:0.408 blue:0.353 alpha:1] /*#77685a*/  forState:UIControlStateNormal];
    [sendEmailButton setTitleColor:[UIColor colorWithRed:0.643 green:0.565 blue:0.486 alpha:1] /*#a4907c*/  forState:UIControlStateSelected];
    [sendEmailButton addTarget:self action:@selector(sendEmail) forControlEvents:UIControlEventTouchUpInside];

    
    makePreviewButton = [[UIButton alloc] initWithFrame:CGRectMake(363, 15, 130, 25)];
    [makePreviewButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:12.0]];
    [makePreviewButton setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
    [makePreviewButton setBackgroundImage:[UIImage imageNamed:@"button__pressed.png"] forState:UIControlStateSelected];
    [makePreviewButton setTitle:@"Посмотреть" forState:UIControlStateNormal];
    [makePreviewButton setTitleColor:[UIColor colorWithRed:0.467 green:0.408 blue:0.353 alpha:1] /*#77685a*/  forState:UIControlStateNormal];
    [makePreviewButton setTitleColor:[UIColor colorWithRed:0.643 green:0.565 blue:0.486 alpha:1] /*#a4907c*/  forState:UIControlStateSelected];
    [makePreviewButton addTarget:self action:@selector(makePreview) forControlEvents:UIControlEventTouchUpInside];
    
    selectDateButton = [[UIButton alloc] initWithFrame:CGRectMake(251, 96, 242, 44)];
    [selectDateButton setBackgroundImage:[UIImage imageNamed:@"date_button.png"] forState:UIControlStateNormal];
    [selectDateButton setBackgroundImage:[UIImage imageNamed:@"date_button__pressed.png"] forState:UIControlStateSelected];
    [selectDateButton setTitle:[NSString stringWithFormat:@" %@",currentBill.BillDate] forState:UIControlStateNormal];
    [selectDateButton setTitleColor:[UIColor colorWithRed:0.467 green:0.408 blue:0.353 alpha:1] /*#77685a*/  forState:UIControlStateNormal];
    [selectDateButton setTitleColor:[UIColor colorWithRed:0.643 green:0.565 blue:0.486 alpha:1] /*#a4907c*/  forState:UIControlStateSelected];
    [selectDateButton addTarget:self action:@selector(setDate) forControlEvents:UIControlEventTouchUpInside];
    
    changeClientRequisitesButton = [[UIButton alloc] initWithFrame:CGRectMake(363, 183, 130, 32)];
    [changeClientRequisitesButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:16.0]];
    [changeClientRequisitesButton setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
    [changeClientRequisitesButton setBackgroundImage:[UIImage imageNamed:@"button__pressed.png"] forState:UIControlStateSelected];
    [changeClientRequisitesButton setTitle:@"Реквизиты" forState:UIControlStateNormal];
    [changeClientRequisitesButton setTitleColor:[UIColor colorWithRed:0.467 green:0.408 blue:0.353 alpha:1] /*#77685a*/  forState:UIControlStateNormal];
    [changeClientRequisitesButton setTitleColor:[UIColor colorWithRed:0.643 green:0.565 blue:0.486 alpha:1] /*#a4907c*/  forState:UIControlStateSelected];
    [changeClientRequisitesButton addTarget:self action:@selector(setRequisites) forControlEvents:UIControlEventTouchUpInside];
    

    saveDocButton = [[UIButton alloc] init];
    saveDocButton.frame = CGRectMake(363, 11, 130, 34); 
    [saveDocButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15.0]];
  
    [saveDocButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveDocButton setBackgroundImage:[UIImage imageNamed:@"save_button.png"] forState:UIControlStateNormal];
    [saveDocButton setBackgroundImage:[UIImage imageNamed:@"save_button__pressed.png"] forState:UIControlStateSelected];

    [saveDocButton addTarget:self action:@selector(saveBill) forControlEvents:UIControlEventTouchUpInside];
    
    cancelButton = [[UIButton alloc] init];
    [cancelButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15.0]];
    [cancelButton setTitle:@"Отменить" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor colorWithRed:0.467 green:0.408 blue:0.353 alpha:1] /*#77685a*/  forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor colorWithRed:0.643 green:0.565 blue:0.486 alpha:1] /*#a4907c*/  forState:UIControlStateSelected];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"button__pressed.png"] forState:UIControlStateSelected];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    
    deleteDocButton = [[UIButton alloc] init];
    if (self.interfaceOrientation == UIDeviceOrientationPortrait || self.interfaceOrientation == UIDeviceOrientationPortraitUpsideDown) {
        cancelButton.frame = CGRectMake(260, 950, 240, 34);
        deleteDocButton.frame = CGRectMake(10, 950, 240, 34);
    }
    else
    {
        cancelButton.frame = CGRectMake(260, 700, 240, 34);
        deleteDocButton.frame = CGRectMake(10, 700, 240, 34); 
    }
    [deleteDocButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15.0]];
    [deleteDocButton setTitle:@"Удалить документ" forState:UIControlStateNormal];
    [deleteDocButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [deleteDocButton setBackgroundImage:[UIImage imageNamed:@"RedButton.png"] forState:UIControlStateNormal];
    [deleteDocButton setBackgroundImage:[UIImage imageNamed:@"RedButton__pressed.png"] forState:UIControlStateSelected];
    [deleteDocButton addTarget:self action:@selector(deleteDocument) forControlEvents:UIControlEventTouchUpInside];

    
    [contentView addSubview:changeClientRequisitesButton];
    [contentView addSubview:sendEmailButton];
    [contentView addSubview:makePreviewButton];
    [contentView addSubview:cancelButton];
    [contentView addSubview:saveDocButton];
    [contentView addSubview:selectDateButton];
    [contentView addSubview:deleteDocButton];
    
    
    if (billId > -1) {
        [self redrawButtonsForExistingBill];
    }
    else
    {
        [self redrawButtonsForNewBill];
    }
    
    docNumberTextField = [[UITextField alloc] initWithFrame:CGRectMake(27, 98, 194, 44)];
    docNumberTextField.clearButtonMode = UITextFieldViewModeUnlessEditing;
    docNumberTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    docNumberTextField.font = [UIFont fontWithName:@"Helvetica" size:18.0];
    docNumberTextField.text = [NSString stringWithFormat:@"%@",currentBill.BillNumb];
    docNumberTextField.textAlignment = UITextAlignmentLeft;
    docNumberTextField.borderStyle=UITextBorderStyleRoundedRect;
    docNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
    docNumberTextField.textColor = [UIColor colorWithRed:0.467 green:0.404 blue:0.349 alpha:1] ;
    [docNumberTextField addTarget:self action:@selector(docNumberChanges) forControlEvents:UIControlEventEditingChanged];
    [contentView addSubview:docNumberTextField];
    
    clientTextField = [[UITextField alloc] initWithFrame:CGRectMake(27, 178, 315, 44)];
    clientTextField.clearButtonMode = UITextFieldViewModeUnlessEditing;
    clientTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    clientTextField.placeholder = @"Например: ООО \"Ромашка\"";
    clientTextField.font = [UIFont fontWithName:@"Helvetica" size:18.0];
    clientTextField.text = [NSString stringWithFormat:@"%@",currentBill.Client.ClientName];
    clientTextField.textAlignment = UITextAlignmentLeft;
    clientTextField.textColor = [UIColor colorWithRed:0.467 green:0.404 blue:0.349 alpha:1];
    clientTextField.borderStyle=UITextBorderStyleRoundedRect;
    clientTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    [clientTextField addTarget:self action:@selector(clientNameIsFilling) forControlEvents:UIControlEventEditingDidBegin];
    [clientTextField addTarget:self action:@selector(clientNameChanges) forControlEvents:UIControlEventEditingChanged];
    [clientTextField addTarget:self action:@selector(tryFillClient) forControlEvents:UIControlEventEditingDidEndOnExit];
    [contentView addSubview:clientTextField];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(27,50, 466, 1)];
    lineView.backgroundColor = [UIColor blackColor];
    [contentView addSubview:lineView];
    [lineView release];


}

- (void)clientNameIsFilling
{
    if (aiView) {
        [self dismissAddItemView];
    }
    
    if (editingClientNotEnded) {
        if (_clientNameHintPicker == nil) {
            self.clientNameHintPicker = [[[DocumentHintPickerController alloc] initWithType:@"client"] autorelease];
            _clientNameHintPicker.delegate = self;
            self.hintClientNamePickerPopover = [[[UIPopoverController alloc] 
                                                 initWithContentViewController:_clientNameHintPicker] autorelease];   
        }
        if (([[_clientNameHintPicker calculateHints] count] == 1)&&[[[[_clientNameHintPicker calculateHints] objectAtIndex:0] lowercaseString] isEqualToString:[clientTextField.text lowercaseString]])
        {
            [self tryFillClientWithName:clientTextField.text];
        }
        else if ([[_clientNameHintPicker calculateHints] count] > 0) {
            [_clientNameHintPicker showHints];
            [self performSelector:@selector(presentPopover) withObject:self afterDelay:0.5];
        }
        else if ([[_clientNameHintPicker calculateHints] count] == 0) {
            [self hidePopover];
        }
    }
   
}

- (void)clientNameCheckAndSave
{
    DocumentHintPickerController *tempClientHint = [[[DocumentHintPickerController alloc] initWithType:@"client"] autorelease];
    [tempClientHint checkAndSaveHint:clientTextField.text];
}

- (void)hidePopover
{
    [self.hintClientNamePickerPopover dismissPopoverAnimated:YES];
}

- (void)presentPopover
{
    editingClientNotEnded = YES;
    self.hintClientNamePickerPopover.popoverContentSize = CGSizeMake(300.0, 44*([[_clientNameHintPicker calculateHints] count] > 5 ? 5 : [[_clientNameHintPicker calculateHints] count]));
    [self.hintClientNamePickerPopover presentPopoverFromRect:CGRectMake(29, 180, 1, 40) inView:self.view
                                        permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];    

}


- (void)setHintedText: (NSString*)temp forTextFieldType: (NSString *)hintType
{
    if ([hintType isEqualToString:@"client"]) {
        editingClientNotEnded = NO;
        clientTextField.text = temp;
        editingClientNotEnded = YES;
        [self tryFillClientWithName:temp];
    }
    [self hidePopover];
}

- (void)tryFillClient
{
    [self tryFillClientWithName:clientTextField.text];
}

- (void)tryFillClientWithName:(NSString *)clientName
{
    clientWasLoaded = YES;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savedListOfClientHintsFileName = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/ClientHints.plist", [[NSUserDefaults standardUserDefaults] stringForKey:@"UserUID"]]];
    NSDictionary *hints = [NSDictionary dictionaryWithContentsOfFile:savedListOfClientHintsFileName];
    NSArray* tempArr = [_clientNameHintPicker calculateHints];
    if ([tempArr count] == 1 && [[[tempArr objectAtIndex:0] lowercaseString] isEqualToString:[clientName lowercaseString]]) {
        clientName = [tempArr objectAtIndex:0];
        int clientID = [(NSNumber *)[hints objectForKey:clientName] intValue];
        NSString *clientFileName = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/Client-%d.plist", [[NSUserDefaults standardUserDefaults] stringForKey:@"UserUID"], clientID]];
        [currentBill.Client makeClientFromArray:[NSArray arrayWithContentsOfFile:clientFileName]];
        [self hidePopover];
    }
    else
    {
        currentBill.Client = [[Contragent alloc] init];
        currentBill.Client.ClientName = clientName;
    }
}

- (ClientRequsites *)getBillClientRequisites
{
	return currentBill.Client.Requisites;
}


- (void)sendEmail
{
    UIWebViewController *UIWebVC = [[UIWebViewController alloc] initWithBill:[currentBill getDictionary] andMailBool:YES];
    [UIWebVC setDelegate: self];
	UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:UIWebVC];
    
    navController.modalPresentationStyle = UIModalPresentationPageSheet;
    
    [self presentModalViewController:navController animated:YES];
    

    [navController release];
    [UIWebVC release];
}

- (void)makePreview
{
    UIWebViewController *UIWebVC = [[UIWebViewController alloc] initWithBill:[currentBill getDictionary] andMailBool:NO];
    [UIWebVC setDelegate: self];
	UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:UIWebVC];
    
    navController.modalPresentationStyle = UIModalPresentationPageSheet;
    
    // show the navigation controller modally
    [self presentModalViewController:navController animated:YES];
    
    // Clean up resources
    [navController release];
    [UIWebVC release];

	//[UIWebVC release];
}


- (void)clientNameChanges
{
    if (clientWasLoaded) {
        currentBill.Client.Requisites = [ClientRequsites new];
    }
    [self clientNameIsFilling];
    currentBill.Client.ClientName = clientTextField.text;
    [self redrawButtonsForNewBill];
}

- (void)redrawButtonsForExistingBill
{
    saveDocButton.hidden = YES;
    deleteDocButton.hidden = NO;
    cancelButton.frame = CGRectMake(260, cancelButton.frame.origin.y, cancelButton.frame.size.width, cancelButton.frame.size.height);
    sendEmailButton.hidden = NO;
    makePreviewButton.hidden = NO;
}

- (void)redrawButtonsForNewBill
{
    saveDocButton.hidden = NO;
    cancelButton.frame = CGRectMake(140, cancelButton.frame.origin.y, cancelButton.frame.size.width, cancelButton.frame.size.height);
    deleteDocButton.hidden = YES;
    sendEmailButton.hidden = YES;
    makePreviewButton.hidden = YES;
}

- (void)docNumberChanges
{
    currentBill.BillNumb = docNumberTextField.text;
    [docNameLabel setText:[NSString stringWithFormat:@"%@ №%@",currentBill.DocumentType, docNumberTextField.text]];
    [self redrawButtonsForNewBill];
}

- (void)setRequisites
{
    [clientTextField resignFirstResponder];
    if ([clientTextField.text length] > 0) {
        // Create the modal view controller
        FillClientRequisitesTableViewController *viewController = [[FillClientRequisitesTableViewController alloc]
                                                                   initWithStyle:UITableViewStyleGrouped andClientRequisites: currentBill.Client.Requisites];
        // We are the delegate responsible for dismissing the modal view 
        viewController.delegate = self;
        
        // Create a Navigation controller
        UINavigationController *navController = [[UINavigationController alloc]
                                                 initWithRootViewController:viewController];
        
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        
        // show the navigation controller modally
        [self presentModalViewController:navController animated:YES];
        
        // Clean up resources
        [navController release];
        [viewController release];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Заполните название клиента" message:@"Перед заполнением реквизитов необходимо ввести название клиента - например \"ООО \"Ромашка\"" delegate:self cancelButtonTitle:@"Ок" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [self.delegate reloadTable];
}

- (void)didDismissModalViewWithClientRequisites:(ClientRequsites *)clientReq {
    currentBill.Client.Requisites.billsClientAddress = clientReq.billsClientAddress;
    currentBill.Client.Requisites.billsClientBank = clientReq.billsClientBank;
    currentBill.Client.Requisites.billsClientBIK = clientReq.billsClientBIK;
    currentBill.Client.Requisites.billsClientINN = clientReq.billsClientINN;
    currentBill.Client.Requisites.billsClientKPP = clientReq.billsClientKPP;
    currentBill.Client.Requisites.billsClientKS = clientReq.billsClientKS;
    currentBill.Client.Requisites.billsClientRS = clientReq.billsClientRS;
    [self dismissModalViewControllerAnimated:YES];
    [self redrawButtonsForNewBill];
}

- (void)dismissPreview
{
    [self dismissModalViewControllerAnimated:YES];
    [clientTextField resignFirstResponder];
}

- (void)drawAddItemButton
{
    [addNewItemButton removeFromSuperview];
    addNewItemButton.frame = CGRectMake(27, 240 + (isMoreThanMaxCells ? maxTableHeight : [[currentBill Items] count]*65), 214, 44);
    [addNewItemButton setBackgroundImage:[UIImage imageNamed:@"addthing_button.png"] forState:UIControlStateNormal];
    [addNewItemButton setBackgroundImage:[UIImage imageNamed:@"addthing_button__pressed.png"] forState:UIControlStateSelected];
    [addNewItemButton setTitle:@"   Добавить товар" forState:UIControlStateNormal];
    [addNewItemButton setTitleColor:[UIColor colorWithRed:0.467 green:0.408 blue:0.353 alpha:1] /*#77685a*/  forState:UIControlStateNormal];
    [addNewItemButton setTitleColor:[UIColor colorWithRed:0.643 green:0.565 blue:0.486 alpha:1] /*#a4907c*/  forState:UIControlStateSelected];
    [addNewItemButton addTarget:self action:@selector(addItemAction) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:addNewItemButton];
    
    
    summaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(270, 240 + (isMoreThanMaxCells ? maxTableHeight : [[currentBill Items] count]*65), 220, 44)];
    summaryLabel.textAlignment = UITextAlignmentRight;
    [summaryLabel setBackgroundColor:[UIColor clearColor]];
    [summaryLabel setTextColor:[UIColor colorWithRed:0.467 green:0.404 blue:0.349 alpha:1]];
    NSString *fillSum = [[self collectAllSummary] stringByReplacingOccurrencesOfString:@"." withString:@","];
    [summaryLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
    [summaryLabel setText:fillSum];
    [contentView addSubview:summaryLabel];
}

- (void)addItemAction
{
    [self recalculateMoveVariables];
    addNewItemButton.enabled = NO;
    if ((addingCellCount == 1)||(selectedCell > -1)) {
        [aiView saveItem:self];
    }
    addingCellCount = 1;
    [self upgradeTable];
    [self performSelector:@selector(enableAddItemButton) withObject:self afterDelay:0.5];
}

- (void)enableAddItemButton
{
    addNewItemButton.enabled = YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [currentBill.Items count] || indexPath.row == selectedCell) {
        return 247.0;
    }
    [tableView setSeparatorColor:[UIColor colorWithRed:0.886 green:0.804 blue:0.718 alpha:1] /*#e2cdb7*/];
    return 65.0;
}

/*- (void)didDismissModalViewWithItemContainer:(itemContainer *)itemCont
{
    [self dismissModalViewControllerAnimated:YES];
    [self redrawButtonsForNewBill];
}*/




- (void)saveBill
{
    [self clientNameCheckAndSave];
    if ([currentBill.Items count] < 1) 
    {
        currentBill.Items = [NSArray arrayWithObject:[[itemContainer alloc] init]];
        _tableView.frame = CGRectMake(0, 230, 520, 65);
        addNewItemButton.frame = CGRectMake(27, 240 + (isMoreThanMaxCells ? maxTableHeight : [[currentBill Items] count]*65), 194, 44);
        summaryLabel.frame = CGRectMake(270, addNewItemButton.frame.origin.y, 220, 44);
    }
    Bill *savingBill = [currentBill retain];
    savingBill.Modified = YES;

	if (billId > -1)
	{
		if (![[repo loadWithId:billId].BillNumb isEqualToString:currentBill.BillNumb]) {
			[[NSUserDefaults standardUserDefaults] setValue:currentBill.BillNumb forKey:[NSString stringWithFormat:@"%@-%@-lastBillNumber", currentBill.DocumentType, [[NSUserDefaults standardUserDefaults] stringForKey:@"UserUID"]]];
		}
		[repo saveBill:savingBill withId:billId];
	}
	else 
	{
		[[NSUserDefaults standardUserDefaults] setValue:currentBill.BillNumb forKey:[NSString stringWithFormat:@"%@-%@-lastBillNumber", currentBill.DocumentType, [[NSUserDefaults standardUserDefaults] stringForKey:@"UserUID"]]];
		billId = [repo saveNewBill:savingBill];
	}
    
	[savingBill release];
	[self redrawButtonsForExistingBill];
    if (addingCellCount > 0 || selectedCell > -1) {
        [self downgradeTable];
    }
    [self.delegate dataViewDidSaveBill:billId];
    if ([clientTextField isFirstResponder]) {
        [docNumberTextField becomeFirstResponder];
        [docNumberTextField resignFirstResponder];
    }
    [self makePreview];
    [_tableView reloadData];
}

- (NSString *)getClientHintedText
{
    return clientTextField.text;
}

- (void)viewDidLoad {
    editingClientNotEnded = YES;
    [super viewDidLoad];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
		
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [currentBill.Items count]+addingCellCount;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    itemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[itemTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
    if (indexPath.row == [currentBill.Items count])
    {
        aiView = [[addItemViewController alloc] init];
        aiView.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView addSubview:[aiView view]];
        [aiView.nameTF becomeFirstResponder];
    }
    else if(selectedCell == indexPath.row)
    {
        aiView = [[addItemViewController alloc] initWithDeleteButton];
        itemContainer *container = [currentBill.Items objectAtIndex:indexPath.row];
        aiView.delegate = self;
        [cell.contentView addSubview:[aiView view]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        aiView.nameTF.text = container.itemsName;
        aiView.qtyTF.text = [container getItemsQty];
        aiView.edizmTF.text = container.itemsEdIzm;
        aiView.summaryLabel.text = [container getItemsSummary];
        aiView.costTF.text = [container getItemsCost];
        [aiView.qtyTF becomeFirstResponder];
    }
    else
    {
        itemContainer *container = [currentBill.Items objectAtIndex:indexPath.row];
        
        cell.clientNameLabel.text = [NSString stringWithFormat:@"%@", container.itemsName];
        [cell.clientNameLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16.0f]];
        cell.billDetailsLabel.text = [NSString stringWithFormat:@"%@ %@ x %@ р.", [container getItemsQty], container.itemsEdIzm, [container getItemsCost]];
        [cell.billDetailsLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.0f]];
        cell.summaryLabel.text = [NSString stringWithFormat:@"%@ р.",[container getItemsSummary]];
        [cell.summaryLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16.0f]];
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bill_cell.png"]] autorelease];
       // cell.itemDetailLabel.textColor = [UIColor colorWithRed:0.467 green:0.404 blue:0.349 alpha:1] ;
        //cell.itemNameLabel.textColor = [UIColor colorWithRed:0.467 green:0.404 blue:0.349 alpha:1] ;
    }
    return cell;
}

- (void)deleteItem
{
    NSMutableArray *tempArr = [NSMutableArray arrayWithArray: currentBill.Items];
    [tempArr removeObjectAtIndex:selectedCell];
    currentBill.Items = [NSArray arrayWithArray:tempArr];
    if (!isMoreThanMaxCells) {
        _tableView.scrollEnabled = NO;
    }
   // selectedCell = -1;
    [_tableView reloadData];
    [self downgradeTable];
    
    [self recalculateMoveVariables];
    int tableHeight = isMoreThanMaxCells ? maxTableHeight : [[currentBill Items] count]*65;
    _tableView.frame = CGRectMake(0, 230, 520, tableHeight);
    addNewItemButton.frame = CGRectMake(27, 240 + tableHeight, 194, 44);
    
    [self redrawButtonsForNewBill];
   // [self dismissAddItemView];

}

- (void)didDismissAddItemViewWithItemContainer:(itemContainer *)itemCont
{
    NSMutableArray *tempArr = [NSMutableArray arrayWithArray: currentBill.Items];
    if (selectedCell == -1) {
        [tempArr addObject:itemCont];
    }
    else
    {
        [tempArr replaceObjectAtIndex:selectedCell withObject:itemCont];
    }

    currentBill.Items = [NSArray arrayWithArray:tempArr];
    if (isMoreThanMaxCells) {
        _tableView.scrollEnabled = YES;
    }
    else
    {
        _tableView.scrollEnabled = NO;
    }
    [_tableView reloadData];
    [self dismissAddItemView];
}

- (void)dismissAddItemView
{
    [self downgradeTable];
    [self redrawButtonsForNewBill];
}

- (void)upgradeTable
{
    [self recalculateMoveVariables];
    _tableView.userInteractionEnabled = NO;
    [_tableView reloadData];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];

    int tableHeight = isMoreThanMaxCells ? maxTableHeight : ([[currentBill Items] count]*65 < 247 ? 247 : [[currentBill Items] count]*65);
    _tableView.frame = CGRectMake(0, 230, 520, tableHeight);
    addNewItemButton.frame = CGRectMake(27, 240 + tableHeight, 194, 44);
    
    CGRect rect = contentView.frame;
    rect.origin.y -= upMargin;
    contentView.frame = rect;
    summaryLabel.frame = CGRectMake(270, addNewItemButton.frame.origin.y, 220, 44);
    
    [UIView commitAnimations];
    _tableView.userInteractionEnabled = YES;
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[currentBill Items] count]-1+addingCellCount inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    _tableView.scrollEnabled = NO;
}

- (void)downgradeTable
{
    [self recalculateMoveVariables];
    _tableView.userInteractionEnabled = NO;
    selectedCell = -1;
    addingCellCount = 0;
    [_tableView reloadData];
    /*if ([[currentBill Items] count] > 0) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }*/
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    _tableView.frame = CGRectMake(0, 230, 520, (isMoreThanMaxCells ? maxTableHeight : [[currentBill Items] count]*65));
    addNewItemButton.frame = CGRectMake(27, 240 + (isMoreThanMaxCells ? maxTableHeight : [[currentBill Items] count]*65), 194, 44);
    
    CGRect rect = contentView.frame;
    rect.origin.y += upMargin;
    contentView.frame = rect;
    if (aiView) {
        [aiView.view removeFromSuperview];
        [aiView release];
        aiView = nil;
    }
    
    summaryLabel.frame = CGRectMake(270, addNewItemButton.frame.origin.y, 220, 44);
    NSString *fillSum = [[self collectAllSummary] stringByReplacingOccurrencesOfString:@"." withString:@","];
    [summaryLabel setText:fillSum];
       
    [UIView commitAnimations];
    _tableView.userInteractionEnabled = YES;
    _tableView.scrollEnabled = YES;
}

- (void)hideAddCell
{
    selectedCell = -1;
    
}

- (void)recalculateMoveVariables
{
    if(([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait) || ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown)) {
        maxTableHeight = 8*65;
        upMargin = 0;
        isMoreThanMaxCells = [[currentBill Items] count]>maxVerticalCellNumber;
        cancelButton.frame = CGRectMake(cancelButton.frame.origin.x, 950, cancelButton.frame.size.width, cancelButton.frame.size.height);
        deleteDocButton.frame = CGRectMake(deleteDocButton.frame.origin.x, 950, deleteDocButton.frame.size.width, deleteDocButton.frame.size.height);

        
    }
    else if(([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) || ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight))
    {
        maxTableHeight = 4*65;
        upMargin = 74;
        isMoreThanMaxCells = [[currentBill Items] count]>maxHorizontalCellNumber;
        cancelButton.frame = CGRectMake(cancelButton.frame.origin.x, 700, cancelButton.frame.size.width, cancelButton.frame.size.height);
        deleteDocButton.frame = CGRectMake(deleteDocButton.frame.origin.x, 700, deleteDocButton.frame.size.width, deleteDocButton.frame.size.height);
    }
    else if((self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)){
        maxTableHeight = 4*65;
        upMargin = 74;
        isMoreThanMaxCells = [[currentBill Items] count]>maxHorizontalCellNumber;
        
    }
    else if((self.interfaceOrientation == UIInterfaceOrientationPortrait) || (self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)) 
    {
        maxTableHeight = 8*65;
        upMargin = 0;
        isMoreThanMaxCells = [[currentBill Items] count]>maxVerticalCellNumber;
    }

}

- (void)initMoveVariables
{
    if((self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)){
        maxTableHeight = 65*4;
        upMargin = 74;
        isMoreThanMaxCells = [[currentBill Items] count]>maxHorizontalCellNumber;
        
    }
    else if((self.interfaceOrientation == UIInterfaceOrientationPortrait) || (self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)) 
    {
        maxTableHeight = 65*8;
        upMargin = 0;
        isMoreThanMaxCells = [[currentBill Items] count]>maxVerticalCellNumber;
    }
}

-(NSString *)collectAllSummary
{
	float sum = 0.0;
	for (int i=0; i<[currentBill.Items count]; i++) {
		sum = sum + [(itemContainer *)[currentBill.Items objectAtIndex:i] getItemsDoubleValueSummary];
	}
	return [NSString stringWithFormat:@"Сумма: %.2f" , sum];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self recalculateMoveVariables];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
//    if (selectedCell > -1 || addingCellCount > 0) {
//        [aiView willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
//    }
//    [self hidePopover];
//    [self.hintClientNamePickerPopover release];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
{
    [self performSelector:@selector(rotatedDetected:) withObject:[NSNumber numberWithInt:fromInterfaceOrientation] afterDelay:0.1];
}

- (void)rotatedDetected:(NSNumber *)fr
{
    int fromInterfaceOrientation = [fr intValue];
    [self hidePopover];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [self recalculateMoveVariables];

    if (selectedCell > -1 || addingCellCount != 0) {
        [aiView didRotateFromInterfaceOrientation:fromInterfaceOrientation];
        if(([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) || ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)) {
            CGRect rect = contentView.frame;
            rect.origin.y -= 74;
            contentView.frame = rect;
        }
        else
        {
            CGRect rect = contentView.frame;
            rect.origin.y += 74;
            contentView.frame = rect;
        }
        if (addingCellCount == 1) {
            int tableHeight = isMoreThanMaxCells ? maxTableHeight : ([[currentBill Items] count]*65 < 247 ? 247 : [[currentBill Items] count]*65);
             _tableView.frame = CGRectMake(0, 230, 520, tableHeight);
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[currentBill Items] count] inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];

        }
        else if (selectedCell > -1) {
            int tableHeight = isMoreThanMaxCells ? maxTableHeight : ([[currentBill Items] count]*65 < 247 ? 247 : [[currentBill Items] count]*65);
            _tableView.frame = CGRectMake(0, 230, 520, tableHeight);
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selectedCell inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        else
        {
            _tableView.frame = CGRectMake(0, 230, 520, (isMoreThanMaxCells ? maxTableHeight : [[currentBill Items] count]*65));
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selectedCell inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
    else
    {
        int tableHeight = isMoreThanMaxCells ? maxTableHeight : [[currentBill Items] count]*65;
        _tableView.frame = CGRectMake(0, 230, 520, tableHeight);
    }
    addNewItemButton.frame = CGRectMake(27, 240 +  _tableView.frame.size.height, 194, 44);
    summaryLabel.frame = CGRectMake(270, addNewItemButton.frame.origin.y, 220, 44);
    NSString *fillSum = [[self collectAllSummary] stringByReplacingOccurrencesOfString:@"." withString:@","];
    [summaryLabel setText:fillSum];
    [UIView commitAnimations];
    

}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _tableView.scrollEnabled = NO;
    if (selectedCell == indexPath.row) {
        return;
    }
    if (selectedCell > -1) {
        [self performSelectorOnMainThread:@selector(dismissAddItemView) withObject:self waitUntilDone:YES];
    }
    
    if (indexPath.row != selectedCell && indexPath.row != [currentBill.Items count]) {
        selectedCell = indexPath.row;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [_tableView reloadData];
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];    
        int tableHeight = isMoreThanMaxCells ? maxTableHeight : ([[currentBill Items] count]*65 < 247 ? 247 : [[currentBill Items] count]*65);
        _tableView.frame = CGRectMake(0, 230, 520, tableHeight);
        addNewItemButton.frame = CGRectMake(27, 240 + tableHeight, 194, 44);
         summaryLabel.frame = CGRectMake(270, addNewItemButton.frame.origin.y, 220, 44);
        CGRect rect = contentView.frame;
        rect.origin.y -= upMargin;
        contentView.frame = rect;
        [UIView commitAnimations];
        
    }
}

- (void)deleteDocument
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Предупреждение" message:@"Все данные документа будут удалены и не будут подлежать восстановлению. Вы подтверждаете удаление?" delegate:self cancelButtonTitle:@"Отмена" otherButtonTitles: @"Удалить", nil];
    [alert show];
    [alert release];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.title == @"Предупреждение") {
		if (buttonIndex == 1) {
            currentBill.Deleted = YES;
            currentBill.Modified = YES;
			[repo saveBill:currentBill withId:billId];
            [self.delegate dataViewDidDeleteBill];
            [self.view removeFromSuperview];
		}
	}
}

-(void)cancel
{
    [self.delegate dataViewDidDeleteBill];
    [self.view removeFromSuperview];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}


- (void)dealloc {
    self.dateSetPicker = nil;
    self.dateSetPickerPopover = nil;
    [currentBill release];
    [repo release];
    [super dealloc];
}


@end

