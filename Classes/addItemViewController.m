//
//  addItemViewController.m
//  eiPad
//
//  Created by Ivan Chernov on 18.08.11.
//  Copyright 2011 SKB-Kontur. All rights reserved.
//

#import "addItemViewController.h"

@implementation addItemViewController
@synthesize summaryLabel, nameTF, qtyTF, edizmTF, costTF, saveBttn, delegate, deleteBttn, hintNamePickerPopover, hintEdizmPickerPopover;
@synthesize documentNameHintPicker = _documentNameHintPicker;
@synthesize documentEdizmHintPicker = _documentEdizmHintPicker;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        shouldHideDeleteButton = YES;
    }
    return self;
}

- (NSString *)getNameHintedText
{
    return nameTF.text;
}

- (NSString *)getEdizmHintedText
{
    return edizmTF.text;
}

- (id)initWithDeleteButton
{
    self = [super init];
    if (self) {
        shouldHideDeleteButton = NO;
    }
    return self;
}

- (void)dealloc
{
    [iSaver release];
    [super dealloc];
}

- (IBAction)itemNameIsFilling
{
    //editingNameNotEnded = YES;
    if (editingNameNotEnded) {
        if (_documentNameHintPicker == nil) {
            self.documentNameHintPicker = [[[DocumentHintPickerController alloc] 
                                            initWithType:@"name"] autorelease];
            _documentNameHintPicker.delegate = self;
            self.hintNamePickerPopover = [[[UIPopoverController alloc] 
                                           initWithContentViewController:_documentNameHintPicker] autorelease];   
        }
        
        if ([[_documentNameHintPicker calculateHints] count] > 0) {
            [_documentNameHintPicker showHints];
            [self performSelector:@selector(presentNamePopover) withObject:self afterDelay:0.5];
        }
        else if ([[_documentNameHintPicker calculateHints] count] == 0) {
            [self hideNamePopover];
        }
    }
}

- (void)presentNamePopover
{
    self.hintNamePickerPopover.popoverContentSize = CGSizeMake(300.0, 44*([[_documentNameHintPicker calculateHints] count] > 5 ? 5 : [[_documentNameHintPicker calculateHints] count]));
    [self.hintNamePickerPopover presentPopoverFromRect:CGRectMake(23, 38, 1, 31) inView:self.view
                              permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}


- (void)presentEdizmPopover
{
    editingEdizmNotEnded = YES;
    self.hintEdizmPickerPopover.popoverContentSize = CGSizeMake(300.0, 44*([[_documentEdizmHintPicker calculateHints] count] > 5 ? 5 : [[_documentEdizmHintPicker calculateHints] count]));
    [self.hintEdizmPickerPopover presentPopoverFromRect:CGRectMake(170, 106, 1, 31) inView:self.view
                               permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}

- (IBAction)itemEdizmIsFilling
{
    if (editingEdizmNotEnded) {
        if (_documentEdizmHintPicker == nil) {
            self.documentEdizmHintPicker = [[[DocumentHintPickerController alloc] 
                                             initWithType:@"edizm"] autorelease];
            _documentEdizmHintPicker.delegate = self;
            self.hintEdizmPickerPopover = [[[UIPopoverController alloc] 
                                            initWithContentViewController:_documentEdizmHintPicker] autorelease];   
        }

            if ([[_documentEdizmHintPicker calculateHints] count] > 0) {
                [_documentEdizmHintPicker showHints];
                [self performSelector:@selector(presentEdizmPopover) withObject:self afterDelay:0.5];
            }
            else if ([[_documentEdizmHintPicker calculateHints] count] == 0) {
                [self hideEdizmPopover];
            }

    }
}

- (IBOutlet)tryFillItem:(id)sender
{
    [self tryFillClientWithName:nameTF.text];
}


- (void)hidePopover
{
    [self hideNamePopover];
    [self hideEdizmPopover];
}

- (void)hideNamePopover
{
    [self.hintNamePickerPopover dismissPopoverAnimated:YES];
}

- (void)hideEdizmPopover
{
    [self.hintEdizmPickerPopover dismissPopoverAnimated:YES];
}


- (void)showDeleteBttn
{
    deleteBttn.hidden = shouldHideDeleteButton;
}

- (void)setNextFirstResponder
{
    if ([nameTF isFirstResponder]) {
        [qtyTF becomeFirstResponder];
    }
    if ([edizmTF isFirstResponder]) {
        [costTF becomeFirstResponder];
    }
}

- (IBAction)putFocusToQty:(id)sender
{
    [qtyTF becomeFirstResponder];
}
- (IBAction)putFocusToEdizm:(id)sender
{
    [edizmTF becomeFirstResponder];
}
- (IBAction)putFocusToCost:(id)sender
{
    [costTF becomeFirstResponder];    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (IBAction)deleteItem:(id)sender
{
    [self.delegate deleteItem];
}

- (IBAction)recalculateSummary:(id)sender
{
    NSString *costText = [costTF.text stringByReplacingOccurrencesOfString:@"," withString:@"."];
    
	double cost;
	if ([costText rangeOfString:@"."].location == NSNotFound) 
	{
		cost = [costText intValue];
	}
	else 
	{
		cost = [costText doubleValue];
	}
    
    NSString *qtyText = [qtyTF.text stringByReplacingOccurrencesOfString:@"," withString:@"."];
    
	double qty;
	if ([qtyText rangeOfString:@"."].location == NSNotFound) 
	{
		qty = [qtyText intValue];
	}
	else 
	{
		qty = [qtyText doubleValue];
	}
	
	double resCost = cost * qty;
	[summaryLabel setText: [[[NSString alloc] initWithString:[NSString stringWithFormat:@"%.2f", resCost]] stringByReplacingOccurrencesOfString:@"." withString:@","]];
}

- (IBAction)saveItem:(id)sender
{
    
    if ([qtyTF.text length] > 1) {
        qtyTF.text = [[self clearStr:qtyTF.text] stringByReplacingOccurrencesOfString:@"." withString:@","];;
    }
    if ([costTF.text length] > 1) {
        costTF.text = [[self clearStr:costTF.text] stringByReplacingOccurrencesOfString:@"." withString:@","];
    }

                          
    DocumentHintPickerController *tempNameHint = [[[DocumentHintPickerController alloc] initWithType:@"name"] autorelease];
    [tempNameHint checkAndSaveHint:nameTF.text];
    
    DocumentHintPickerController *tempEdizmHint = [[[DocumentHintPickerController alloc] initWithType:@"edizm"] autorelease];
    [tempEdizmHint checkAndSaveHint:edizmTF.text];
    
    itemContainer *container = [itemContainer new];
    container.itemsName = nameTF.text;
    container.itemsQty = [qtyTF.text isEqualToString:@""] ? @"0" : qtyTF.text;
    container.itemsEdIzm = edizmTF.text ;
    container.itemsCost = [costTF.text isEqualToString:@""] ? @"0" : costTF.text;
    [container reCalculateSummary];

    [[[[itemRepository alloc] init] autorelease] saveItemWithName:nameTF.text andEdizm:edizmTF.text andCost:costTF.text];
    
    [delegate didDismissAddItemViewWithItemContainer:container];
}

- (NSString *)clearStr:(NSString *)str
{
    while (([str characterAtIndex:0] == '0')&&([str characterAtIndex:1] != '.')) {
        str = [str substringFromIndex:1];
    }
    str = [str stringByReplacingOccurrencesOfString:@"," withString:@"."];
    if ([str doubleValue] == 0.0) {
        return @"0.0";
    }
    else if ((double)[str intValue] == [str doubleValue]) {
        return [NSString stringWithFormat:@"%d", ABS([str intValue])];
    }
    else
    {
        return [NSString stringWithFormat:@"%.2f", ABS([str doubleValue])];
    }
    return str;
}

- (IBAction)cancel:(id)sender
{
    [delegate dismissAddItemView];
}

- (void)setHintedText: (NSString*)temp forTextFieldType: (NSString *)hintType
{
    if ([hintType isEqualToString:@"name"]) {
        editingNameNotEnded = NO;
        nameTF.text = temp;
        editingNameNotEnded = YES;
        [self tryFillItemWithName:temp];
    }
    else if ([hintType isEqualToString:@"edizm"])
    {
        editingEdizmNotEnded = NO;
        edizmTF.text = temp;
        editingEdizmNotEnded = YES;
    }
    [self setNextFirstResponder];
    [self hidePopover];
}

-(IBAction)tryFillItem
{
    NSString *temp = [iSaver tryLoadItemWithName:nameTF.text];
    if ([temp length] > 0) {
        [self tryFillItemWithName:temp];
    }
}

- (void)tryFillItemWithName:(NSString *)itemName
{
    if([iSaver doesExistItemWithName:itemName])
    {
        itemNonmutableFields *itemF = [[iSaver loadItemWithName:itemName] retain];
        edizmTF.text = [itemF getEdizm];
        costTF.text = [itemF getCost];
        [itemF release];
    }
}



- (void)viewDidLoad
{
    iSaver = [[itemRepository alloc] init];
    deleteBttn.hidden = shouldHideDeleteButton;
    editingNameNotEnded = YES;
    editingEdizmNotEnded = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self hidePopover];
    [self.hintNamePickerPopover release];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self hidePopover];
  //  [self performSelector:@selector(rotateDetected:) withObject:[NSNumber numberWithInt:fromInterfaceOrientation] afterDelay:0.5];
    

    //    [self.hintNamePickerPopover presentPopoverFromRect:CGRectMake(28, 49, 465, 1) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

- (void)rotateDetected:(NSNumber *)num
{
    [self.delegate rotatedDetected:num];
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
	return YES;
}

@end
