//
//  DataSetPickerView.m
//  eiPad
//
//  Created by Ivan Chernov on 16.08.11.
//  Copyright 2011 SKB-Kontur. All rights reserved.
//

#import "DataSetPickerView.h"


@implementation DataSetPickerView

@synthesize datepicker = _datepicker;
@synthesize delegate = _delegate;

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
        [self.datepicker addTarget:self action:@selector(setDate) forControlEvents:UIControlEventAllTouchEvents];
        self.contentSizeForViewInPopover = CGSizeMake(300.0, 216.0);
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.datepicker.date = [[[NSDate alloc] init] autorelease];
}

- (IBAction)setDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"dd.MM.YYYY"];
	NSString *today = [dateFormatter stringFromDate:self.datepicker.date];
	[dateFormatter release];
    [self.delegate DateSelected:today];
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
