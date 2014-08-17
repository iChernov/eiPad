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
//  MenuViewController.m
//  StackScrollView
//
//  Created by Reefaq on 2/24/11.
//  Copyright 2011 raw engineering . All rights reserved.
//

#import "MenuViewController.h"
#import "DocumentListViewController.h"
#import "StackScrollViewAppDelegate.h"
#import "RootViewController.h"
#import "StackScrollViewController.h"
#import "itemContainer.h"
#import "Contragent.h"
#import "ClientRequsites.h"

@implementation MenuViewController
@synthesize tableView = _tableView;
@synthesize delegate = _delegate;

#pragma mark -
#pragma mark View lifecycle

- (id)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
		[self.view setFrame:frame]; 
        repo = [[BillRepository alloc] init];
        
		dtypes = [[NSArray arrayWithObjects:@"AllDocs", @"Счет", @"Акт", @"Накладная", nil] retain];
		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
		[_tableView setDelegate:self];
		[_tableView setDataSource:self];
		[_tableView setBackgroundColor:[UIColor clearColor]];
        _tableView.scrollEnabled = NO;
		_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
		[self.view addSubview:_tableView];
		_tableView.separatorColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"separator.png"]];
		UIView* verticalLineView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, -5, 1, 1024)];
		[verticalLineView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
		[verticalLineView setBackgroundColor:[UIColor blackColor]];
		[self.view addSubview:verticalLineView];
		[self.view bringSubviewToFront:verticalLineView];	
		
	}
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
 }



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
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
    return 4;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
    }
    cell.backgroundColor = [UIColor clearColor];
    // Configure the cell...
    UIImageView *imageView;
    
    if (indexPath.row == 0) {
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tbicon1.png"]];
        imageView.transform = CGAffineTransformMakeTranslation(10.0f,7.0f);
        [cell.contentView addSubview:imageView];
        cell.textLabel.text = @"        Документы";
    }
    else if (indexPath.row == 1) {
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tbicon2.png"]];
        imageView.transform = CGAffineTransformMakeTranslation(10.0f,7.0f);
        [cell.contentView addSubview:imageView];
        cell.textLabel.text = @"        Счета";
    }
    else if (indexPath.row == 2) {
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tbicon3.png"]];
        imageView.transform = CGAffineTransformMakeTranslation(10.0f,7.0f);
        [cell.contentView addSubview:imageView];
        cell.textLabel.text = @"        Акты";
    }
    else if (indexPath.row == 3) {
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tbicon4.png"]];
        imageView.transform = CGAffineTransformMakeTranslation(10.0f,7.0f);
        [cell.contentView addSubview:imageView];
        cell.textLabel.text = @"        Накладные";
    }
    cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SelectedCellBackground1.png"]] autorelease];
	//cell.textLabel.text = [NSString stringWithFormat:@"Menu %d", indexPath.row +1];
	[cell.textLabel setTextColor:[UIColor whiteColor]];
    //cell.textLabel.highlightedTextColor = [UIColor blackColor];

    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)showInitialDocuments
{
    SearchViewController *dataViewController = [[SearchViewController alloc] initWithFrame:CGRectMake(0, 0, 520, self.view.frame.size.height) andTitle:[dtypes objectAtIndex:0] andRepo:repo];
    dataViewController.delegate = self.delegate;
	[[StackScrollViewAppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:dataViewController invokeByController:self isStackStartView:TRUE];
	[dataViewController release];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SearchViewController *dataViewController = [[SearchViewController alloc] initWithFrame:CGRectMake(0, 0, 520, self.view.frame.size.height) andTitle:[dtypes objectAtIndex:indexPath.row] andRepo:repo];
    dataViewController.delegate = self.delegate;
	[[StackScrollViewAppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:dataViewController invokeByController:self isStackStartView:TRUE];
	[dataViewController release];
}


#pragma mark -
#pragma mark Memory management


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}


- (void)dealloc {
    [repo release];
    [super dealloc];
}


@end

