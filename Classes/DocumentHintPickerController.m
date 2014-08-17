//
//  DocumentTypePickerController.m
//  MathMonsters
//
//  Created by Ray Wenderlich on 5/3/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "DocumentHintPickerController.h"
#import "itemNameHints.h"

@implementation DocumentHintPickerController
@synthesize hints = _hints;
@synthesize delegate = _delegate;
@synthesize hintType, nameHints;

#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/

- (id)initWithType:(NSString *)type
{
    hintType = [type retain];
    nameHints = [[itemNameHints alloc] initWithClientNameType];
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        if ([hintType isEqualToString:@"name"]) {
            nameHints = [[itemNameHints alloc] initWithNameType];
        }
        else if([hintType isEqualToString:@"edizm"])
        {
            nameHints = [[itemNameHints alloc] initWithEdIzmType];
        }
        else if([hintType isEqualToString:@"client"])
        {
            nameHints = [[itemNameHints alloc] initWithClientNameType];
        }
    }
    if ((int)[nameHints getNumberOfHints] < 5) {
        self.contentSizeForViewInPopover = CGSizeMake(300.0, 44*[nameHints getNumberOfHints]);
    }
    else
    {
        self.contentSizeForViewInPopover = CGSizeMake(300.0, 220.0);
    }

    return self;
}

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    _hints = [NSMutableArray new];
	itemWasFoundInHints = NO;
    
    userDefs = [NSUserDefaults standardUserDefaults];
    self.clearsSelectionOnViewWillAppear = NO;
    self.hints = _hints;
}

- (void)showInitialHints
{
	[_hints removeAllObjects];
    int numberOfHints = [nameHints getNumberOfHints];
    
	if (numberOfHints <=5) {
		for (int i = numberOfHints-1; i>=0; i--) {
			[_hints addObject:[nameHints getHintAtIndex:i]];
		}
	}
	else {
		for (int i = (numberOfHints-1); i>=(numberOfHints-5); i--) {
			[_hints addObject:[nameHints getHintAtIndex:i]];
		}
	}
    self.contentSizeForViewInPopover = CGSizeMake(300.0, 44*[_hints count]);
    [self.view setNeedsDisplay];
}

- (void)showHints
{
    NSString *hintedText;
    if (hintType == @"name") {
        hintedText = [[self.delegate getNameHintedText] retain];
    }
    else if (hintType == @"edizm") {
        hintedText = [[self.delegate getEdizmHintedText] retain];
    }
    else if (hintType == @"client") {
        hintedText = [[self.delegate getClientHintedText] retain];
    }
        
	[_hints removeAllObjects];
	if ([hintedText length] == 0) {
		[self showInitialHints];
	}
	else {
        NSArray *arr = [NSArray arrayWithArray:[nameHints getAllHintsContainingSubstring:[[self clearString:hintedText] lowercaseString]]];
        if([arr count] == 0)
        {
            itemWasFoundInHints = NO; 
            [self.delegate hidePopover];
        }
        else
        {
            [_hints addObjectsFromArray:arr];
            itemWasFoundInHints = YES;
        }
	}
	[self.tableView reloadData];
    self.contentSizeForViewInPopover = CGSizeMake(300.0, 44.0*[_hints count]);
}

- (NSArray *)calculateHints
{
    NSString *hintedText;
    if (hintType == @"name") {
        hintedText = [[self.delegate getNameHintedText] retain];
    }
    else if (hintType == @"edizm") {
        hintedText = [[self.delegate getEdizmHintedText] retain];
    }
    else if (hintType == @"client") {
        hintedText = [[self.delegate getClientHintedText] retain];
    }
    
	if ([hintedText length] == 0) {
		return [nameHints getAllHints];
	}
	else {
        NSArray *arr = [NSArray arrayWithArray:[nameHints getAllHintsContainingSubstring:[[self clearString:hintedText] lowercaseString]]];
        return arr;
	}

    return [NSArray new];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self showHints];
}

- (NSString *)clearString:(NSString *)theString
{
	NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
	NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
	
	NSArray *parts = [theString componentsSeparatedByCharactersInSet:whitespaces];
	NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];
	NSString *resultString = [NSString stringWithString:[filteredArray componentsJoinedByString:@" "]];
    
	return resultString;
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/


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
    return [_hints count];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[self.tableView reloadData];
		[nameHints deleteHint:[_hints objectAtIndex:indexPath.row]];
		[nameHints saveHints];
        [_hints removeObjectAtIndex:indexPath.row];
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animate
{
    [super setEditing:editing animated:animate];
    [self.tableView setEditing:editing animated:animate];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];	
    NSString *hint = [_hints objectAtIndex:indexPath.row];
    cell.textLabel.text = hint;
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
	NSString *temp = [[NSString alloc] initWithFormat:@"%@", [_hints objectAtIndex:indexPath.row]];
	
	//[nameHints deleteHint: [showHints objectAtIndex:indexPath.row]]; //так, зачем мы это
	//[nameHints tryToAddHint:[showHints objectAtIndex:indexPath.row]]; //делаем?
	//[nameHints saveHints];
    [self.delegate hidePopover];
    [self.delegate setHintedText: temp forTextFieldType: hintType];
    [self.delegate hidePopover];
	[temp release];
    
	itemWasFoundInHints = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    
}

- (BOOL)checkAndSaveHint:(NSString *)hText
{
    if (![[self clearString:hText] isEqualToString:@""]) {
        [nameHints tryToAddHint:[self clearString:hText]];
        [nameHints saveHints];
        return YES;
    }
    return NO;
}

- (BOOL)compareHints: (NSString *)hText
{
    for (int i = 0; i < [nameHints getNumberOfHints]; i++) {
		if ([(NSString *)[[nameHints getHintAtIndex:i] lowercaseString] isEqualToString:[[self clearString:hText] lowercaseString]]) {
			return YES;
		}
	}
    return NO;
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    self.hints = nil;
    self.delegate = nil;
    [nameHints release];
    [super dealloc];
}


@end

