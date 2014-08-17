//
//  instrViewController.m
//  E-Iphone
//
//  Created by Ivan Chernov on 17.12.10.
//  Copyright 2010 SKB-Kontur. All rights reserved.
//

#import "instrViewController.h"


@implementation instrViewController

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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	printInstrView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
	printInstrView.image = [UIImage imageNamed:@"Print.png"];
	[self.view addSubview:printInstrView];
	
	readyButton = [[UIButton alloc] initWithFrame:CGRectMake(25, 390, 270, 44)];
	[readyButton setBackgroundImage:[UIImage imageNamed:@"btn.png"] forState:UIControlStateNormal];
	[readyButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
	[readyButton setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:readyButton];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)goBack
{
	[self dismissModalViewControllerAnimated:YES];
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
	[printInstrView release];
    [super dealloc];
}


@end
