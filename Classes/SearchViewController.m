//
//  SearchViewController.m
//
#import "SearchViewController.h"
#import "StackScrollViewAppDelegate.h"
#import "RootViewController.h"
#import "StackScrollViewController.h"
#import "DataViewController.h"
#import "chooseOrCreateNewTableViewCell.h"
#import "BillRepository.h"
#import "itemContainer.h"
#import "Contragent.h"
#import "ClientRequsites.h"
#import <QuartzCore/QuartzCore.h>
#import "ElbaSyncProxy.h"
#import "Synchronizer.h"
#import "ElbaSyncProxy.h"

@implementation SearchViewController
@synthesize tableData;
@synthesize disableViewOverlay;
@synthesize theSearchBar;
@synthesize theTableView;
@synthesize horizLine;
@synthesize downloadBar;
@synthesize DocumentTypePickerPopover;
@synthesize delegate = _delegate;

#define REFRESH_HEADER_HEIGHT 60.0f

- (id)initWithFrame:(CGRect)frame andTitle:(NSString *)theTitle andRepo:(BillRepository *)repos{
    if (self = [super init]) {
        isSharikoff = NO;
        if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UserUID"] isEqualToString:@"-1"]) {
            isSharikoff = YES;
        }
        //NSLog(@"initWithFrame-1");
		[self.view setFrame:frame]; 
//		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
//		[_tableView setDelegate:self];
//		[_tableView setDataSource:self];
//		_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
//		[_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
//		[self.view addSubview:_tableView];
        if (!isSharikoff) {
            horizLine = [[UIView alloc] initWithFrame:CGRectMake(0, 107, 520, 1)];
            [horizLine setBackgroundColor:[UIColor lightGrayColor]];
            [self.view addSubview:horizLine];
            
            arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Pull_to_refresh.png"]];
            arrowView.center = CGPointMake(30, 80);
            [self.view addSubview:arrowView];
            
            arrowLabel = [[UILabel alloc] initWithFrame:CGRectMake(58, 62, 470, 30)];
            [arrowLabel setText:@"Потяните документы вниз для синхронизации"]; 
            [arrowLabel setFont:[UIFont fontWithName:@"Helvetica" size:17]];
            [arrowLabel setTextColor:[UIColor colorWithRed:0.29 green:0.133 blue:0 alpha:1]];
            [arrowLabel setBackgroundColor:[UIColor clearColor]];
            [self.view addSubview:arrowLabel];

        }
        else
        {
            CGRect viewFrame = theTableView.frame;
            viewFrame.origin.y -= 59;
            self.theTableView.frame = viewFrame;
        }
                
        dtype = theTitle;        
        repo = [repos retain];
        billiPadIds = [[repo getActualIdsWithType:dtype] retain];
        billiPadClientNames = [[self getUniqueClientsNames:[self reversedArray:billiPadIds]] retain];
        isLoading = NO;
//      dictionaryOfDocsAndCNames is ready at the moment
        self.tableData =[[NSMutableArray alloc]init];
        [self.tableData addObjectsFromArray:[self reversedArray:billiPadIds]];
        createNewDoc = [UIButton buttonWithType:UIButtonTypeCustom];
        [createNewDoc setBackgroundImage:[UIImage imageNamed:@"add_button.png"] forState:UIControlStateNormal];
        [createNewDoc setBackgroundImage:[UIImage imageNamed:@"add_button__pressed.png"] forState:UIControlStateSelected];
        createNewDoc.frame = CGRectMake(473, 8, 34, 34);
        [createNewDoc addTarget:self action:@selector(createNewDocument) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:createNewDoc];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(300,47, 220, 1)];
        lineView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:lineView];
        //NSLog(@"initWithFrame-2");
	}
    return self;
}


- (NSArray *)reversedArray:(NSArray *)arr {
    //NSLog(@"reversedArray-1");
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[arr count]];
    NSEnumerator *enumerator = [arr reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    //NSLog(@"reversedArray-2");
    return array;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ((!isSharikoff)&&(!isLoading)) {
            if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
                isLoading = YES;    
                [self startLoading];
            }
        }
}

- (void) startLoading {  
    //NSLog(@"startLoading-1");

//    refreshLabel.text = self.textLoading;
//    refreshArrow.hidden = YES;
//    [refreshSpinner startAnimating];
    arrowLabel.hidden = YES;
    arrowView.hidden = YES;
    syncIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [syncIndicator setCenter:CGPointMake(30, 80)];
    [self.view addSubview:syncIndicator];
    [syncIndicator startAnimating];
    
    syncLabel = [[UILabel alloc] initWithFrame:CGRectMake(58, 62, 400, 30)];
    [syncLabel setBackgroundColor:[UIColor clearColor]];
    theSearchBar.userInteractionEnabled = NO;
    theSearchBar.barStyle = UIBarStyleBlack;
    [syncLabel setText:@"Синхронизирую документы..."];
    [syncLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17]];
    [syncLabel setTextColor:[UIColor colorWithRed:0.29 green:0.133 blue:0 alpha:1]];
    [self.view addSubview:syncLabel];
    /* Operation Queue init (autorelease) */
    UIApplication *thisApp = [UIApplication sharedApplication];
    thisApp.idleTimerDisabled = YES;
    
    timer = [NSTimer scheduledTimerWithTimeInterval: 3.0f target: self selector: @selector(tableContentWasChanged) userInfo: nil repeats: YES];   
    NSOperationQueue *queue = [NSOperationQueue new];
    
    /* Create our NSInvocationOperation to call loadDataWithOperation, passing in nil */
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                            selector:@selector(syncBillsWithServer)
                                                                              object:nil];
    
    /* Add the operation to the queue */
    [queue addOperation:operation];
    [operation release];
    // Refresh action!
//    [self refresh];
    //NSLog(@"startLoading-2");
    
}

-(void)syncBillsWithServer
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	ElbaSyncProxy *elbaSyncProxy = [[ElbaSyncProxy alloc] init];
	BillRepository *billRepository = repo;
	Synchronizer *synchronizer = [[Synchronizer alloc] initWithProxy:elbaSyncProxy andRepository:repo];
    //synchronizer.delegate = self;
	@try {
		[synchronizer synchronize];
    }
	@catch (NSException *exception) {
        [UIView commitAnimations];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Внимание!" message:[NSString stringWithFormat:@"Синхронизация документов не удалась: %@. Пожалуйста, проверьте сетевое соединение и повторите попытку позже.", [exception reason]] delegate:self cancelButtonTitle:@"Ок" otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
	@finally {
        [self performSelectorOnMainThread:@selector(setDoneLabel) withObject:self waitUntilDone:YES];
		[synchronizer release];
		[elbaSyncProxy release];
        isLoading = NO;
        [self performSelectorOnMainThread:@selector(tableContentWasChanged) withObject:self waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(loadingFinished) withObject:self waitUntilDone:NO];
        [timer invalidate];
	}	
    [pool drain];
}

-(void)setDoneLabel
{
    [syncLabel setText:@"Обновляю список документов..."];
}

-(void)uploadBillToServer:(NSNumber *)bidnumb
{
    if (!isSharikoff) {
        NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
        ElbaSyncProxy *proxy = [[ElbaSyncProxy alloc] init];
        @try {
            [proxy uploadBill:[repo loadWithId:[bidnumb intValue]]];
        }
        @catch (NSException *exception) {
        }
        @finally {
            Bill* tmp = [repo loadWithId:[bidnumb intValue]];
            tmp.Modified = YES;
            [repo saveBill:tmp withId:[bidnumb intValue]];
            [proxy release];
            UIApplication *thisApp = [UIApplication sharedApplication];
            thisApp.idleTimerDisabled = NO;
        }	
        [pool drain];

    }
}

- (void)loadingFinished
{
    [syncIndicator removeFromSuperview];
    [downloadBar removeFromSuperview];
    [syncLabel removeFromSuperview];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [syncIndicator stopAnimating];
    self.theTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [UIView commitAnimations];
    theSearchBar.userInteractionEnabled = YES;
    theSearchBar.barStyle = UIBarStyleDefault;
    arrowLabel.hidden = NO;
    arrowView.hidden = NO;
}

- (void)createNewDocument
{
    //, @"Счет", @"Акт", @"Накладная"
    
    if (dtype == @"AllDocs") {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
        [actionSheet addButtonWithTitle:@"Счет"];
        [actionSheet addButtonWithTitle:@"Акт"];
        [actionSheet addButtonWithTitle:@"Накладную"];
        [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:@"Отмена"]];
        [actionSheet showFromRect:CGRectMake(473, 0, 34, 40) inView:self.view animated:YES];
    }
    else
    {
       // [self.theTableView reloadData];
        NSString* doctype = dtype;
        if (dtype == @"Накладную") {
            doctype = @"Накладная";
        }
        DataViewController *dataViewController = [[DataViewController alloc] initWithFrame:CGRectMake(0, 0, 520, self.view.frame.size.height) docType:doctype andBillId:-1];
        [[StackScrollViewAppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:dataViewController invokeByController:self isStackStartView:FALSE];
        [dataViewController setDelegate:self];
        [dataViewController autorelease];
    }

    

    /*
    if (_DocumentTypePicker == nil) {
        self.DocumentTypePicker = [[[DocumentTypePickerController alloc] 
                             initWithStyle:UITableViewStylePlain] autorelease];
        _DocumentTypePicker.delegate = self;
        self.DocumentTypePickerPopover = [[[UIPopoverController alloc] 
                                    initWithContentViewController:_DocumentTypePicker] autorelease];               
    }
     [self.DocumentTypePickerPopover presentPopoverFromRect:CGRectMake(345, 7, 160, 36) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];*/
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *doctype = [NSString new];
    switch (buttonIndex) {
		case 0:
			doctype = @"Счет";
			break;
		case 1:
			doctype = @"Акт";
			break;
		case 2:
			doctype = @"Накладная";
			break;
		default:
			break;
	}
   // [self.theTableView reloadData];
   // [self.DocumentTypePickerPopover dismissPopoverAnimated:NO];
    if (buttonIndex == 0 || buttonIndex == 1 || buttonIndex == 2) {
        DataViewController *dataViewController = [[DataViewController alloc] initWithFrame:CGRectMake(0, 0, 520, self.view.frame.size.height) docType:doctype andBillId:-1];
        [[StackScrollViewAppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:dataViewController invokeByController:self isStackStartView:FALSE];
        [dataViewController setDelegate:self];
        [dataViewController autorelease];
    }
}

- (void)documentSelected:(NSString *)doctype
{
  //  [self.DocumentTypePickerPopover dismissPopoverAnimated:NO];
    if ([doctype isEqualToString:@"Накладную"]) {
        doctype = @"Накладная";
    }
    DataViewController *dataViewController = [[DataViewController alloc] initWithFrame:CGRectMake(0, 0, 520, self.view.frame.size.height) docType:doctype andBillId:-1];
    [[StackScrollViewAppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:dataViewController invokeByController:self isStackStartView:FALSE];
	[dataViewController setDelegate:self];
    [dataViewController release];
}

- (NSArray *)getUniqueClientsNames:(NSArray *)reversedBilliPadIds
{
    //NSLog(@"getUniqueClientsNames-1");
    dictionaryOfDocsAndCNames = [[NSMutableDictionary alloc] init];
	NSMutableArray *uniqueClientIds = [[NSMutableArray new] autorelease];
	for (int i=0; i<[reversedBilliPadIds count]; i++) {
		Bill *currentBill = [[[[BillRepository alloc] init] autorelease] loadWithId:[[reversedBilliPadIds objectAtIndex:i] intValue]];
        NSString *temp = currentBill.Client.ClientName;
        if ([temp isEqualToString:@""]) {
            temp = @"Неизвестный контрагент";
        }
        if ([self checkIfLCArray:[dictionaryOfDocsAndCNames allKeys] containsObject:temp]) {
            NSMutableArray *tarr = [dictionaryOfDocsAndCNames objectForKey:[temp lowercaseString]];
           //NSLog(@"tarr1 %@", tarr);
            [tarr addObject:[reversedBilliPadIds objectAtIndex:i]];
           //NSLog(@"tarr2 %@", tarr);
            [dictionaryOfDocsAndCNames setObject:tarr forKey:[temp lowercaseString]];
        }
        else
        {
            NSMutableArray *tarr = [NSMutableArray new];
            [tarr addObject:[reversedBilliPadIds objectAtIndex:i]];
            if (tarr) {
                [dictionaryOfDocsAndCNames setObject:tarr forKey:[temp lowercaseString]];
            }
        }
		if (![self checkIfLCArray:uniqueClientIds containsObject:temp])
        {
			[uniqueClientIds addObject:temp];
        }
	}
    //NSLog(@"getUniqueClientsNames-2");
	return uniqueClientIds;
}

- (BOOL)checkIfLCArray:(NSArray *)arr containsObject:(NSString *)str
{
    for (int i = 0; i < [arr count]; i++) {
        if ([[[arr objectAtIndex:i] lowercaseString] isEqualToString:[str lowercaseString]]) {
            return YES;
        }
    }
    return NO;
}

- (void)dataViewDidSaveBill:(int)bid
{
    billiPadIds = [[repo getActualIdsWithType:dtype] retain];
    billiPadClientNames = [[self getUniqueClientsNames:[self reversedArray:billiPadIds]] retain];
    //[self performSelectorInBackground:@selector(uploadBillToServer:) withObject:[NSNumber numberWithInt:bid]];
    [self.tableData removeAllObjects];
    [self.tableData addObjectsFromArray:[self reversedArray:billiPadIds]];
    NSIndexPath *ipath = [self.theTableView indexPathForSelectedRow];
    [self.theTableView reloadData];
    [self.theTableView selectRowAtIndexPath:ipath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)dataViewDidDeleteBill
{
    [self tableContentWasChanged];
    [[StackScrollViewAppDelegate instance].rootViewController.stackScrollViewController bounceBack:@"RIGHT-WITH-RIGHT" finished:[NSNumber numberWithInt:1] context:nil];
}

- (void)tableContentWasChanged
{
    //NSLog(@"tableContentWasChanged-1");
    billiPadIds = [[repo getActualIdsWithType:dtype] retain];
    billiPadClientNames = [[self getUniqueClientsNames:[self reversedArray:billiPadIds]] retain];
    [self.tableData removeAllObjects];
    [self.tableData addObjectsFromArray:[self reversedArray:billiPadIds]];
    [self.theTableView reloadData];
    //NSLog(@"tableContentWasChanged-2");
}

- (void)reloadTable
{
    [self.theTableView reloadData];
}

// Initialize tableData and disabledViewOverlay 
- (void)viewDidLoad {
    //NSLog(@"viewDidLoad-1");
    [super viewDidLoad];
    

    self.disableViewOverlay = [[UIView alloc]
                               initWithFrame:CGRectMake(0.0f,48.0f,self.view.frame.size.width,self.view.frame.size.height-48)];
    self.disableViewOverlay.backgroundColor=[UIColor blackColor];
    self.disableViewOverlay.alpha = 0;
    //NSLog(@"viewDidLoad-2");
}

// Since this view is only for searching give the UISearchBar 
// focus right away
- (void)viewDidAppear:(BOOL)animated {
     //NSLog(@"viewDidAppear-1");
   // [self.theSearchBar becomeFirstResponder];
    [super viewDidAppear:animated];
     //NSLog(@"viewDidAppear-2");
}

- (void)viewWillAppear:(BOOL)animated
{
    //NSLog(@"viewWillAppear-1");
    UIImageView *tailView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
    int height = [self.delegate menuHeight];
    if ([dtype isEqualToString: @"AllDocs"])
    {
        theSearchBar.placeholder = @"Поиск по документам";
        tailView.frame = CGRectMake(-11, height+10, 11, 20);
    }
    else if ([dtype isEqualToString: @"Счет"])
    {
        theSearchBar.placeholder = @"Поиск по счетам";
        tailView.frame = CGRectMake(-11, height+55, 11, 20);
    }
    else if ([dtype isEqualToString: @"Акт"])
    {
        theSearchBar.placeholder = @"Поиск по актам";
        tailView.frame = CGRectMake(-11, height+100, 11, 20);
    }
    else if ([dtype isEqualToString: @"Накладная"])
    {
        theSearchBar.placeholder = @"Поиск по накладным";
        tailView.frame = CGRectMake(-11, height+145, 11, 20);
    }
    [self.view addSubview:tailView];
    //NSLog(@"viewWillAppear-2");
}

#pragma mark -
#pragma mark UISearchBarDelegate Methods

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText {
    // We don't want to do anything until the user clicks 
    // the 'Search' button.
    // If you wanted to display results as the user types 
    // you would do that here.
    NSArray *results = [self doSearchWithKey:searchBar.text];
	
    [self.tableData removeAllObjects];
    [self.tableData addObjectsFromArray:[self reversedArray:results]];
    
    [billiPadClientNames release];
    billiPadClientNames = [[NSMutableArray arrayWithArray:[self getUniqueClientsNames:self.tableData]] retain];
    
    [self.theTableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    // searchBarTextDidBeginEditing is called whenever 
    // focus is given to the UISearchBar
    // call our activate method so that we can do some 
    // additional things when the UISearchBar shows.
   // [self searchBar:searchBar activate:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    // searchBarTextDidEndEditing is fired whenever the 
    // UISearchBar loses focus
    // We don't need to do anything here.
   // [self searchBar:searchBar activate:NO];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    // Clear the search text
    // Deactivate the UISearchBar
    searchBar.text=@"";
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // Do the search and show the results in tableview
    // Deactivate the UISearchBar
    // You'll probably want to do this on another thread
    // SomeService is just a dummy class representing some 
    // api that you are using to do the search
   }

// We call this when we want to activate/deactivate the UISearchBar
// Depending on active (YES/NO) we disable/enable selection and 
// scrolling on the UITableView
// Show/Hide the UISearchBar Cancel button
// Fade the screen In/Out with the disableViewOverlay and 
// simple Animations
- (void)searchBar:(UISearchBar *)searchBar activate:(BOOL) active{	
    /*self.theTableView.allowsSelection = !active;
    self.theTableView.scrollEnabled = !active;
    if (!active) {
        [disableViewOverlay removeFromSuperview];
        [searchBar resignFirstResponder];
    } else {
        self.disableViewOverlay.alpha = 0;
        [self.view addSubview:self.disableViewOverlay];
		
        [UIView beginAnimations:@"FadeIn" context:nil];
        [UIView setAnimationDuration:0.5];
        self.disableViewOverlay.alpha = 0.6;
        [UIView commitAnimations];
		
        // probably not needed if you have a details view since you 
        // will go there on selection
        NSIndexPath *selected = [self.theTableView 
                                 indexPathForSelectedRow];
        if (selected) {
            [self.theTableView deselectRowAtIndexPath:selected 
                                             animated:NO];
        }
    }
    [searchBar setShowsCancelButton:active animated:YES];*/
}


#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
     //NSLog(@"numberOfRowsInSection-1");
    return [(NSArray *)[dictionaryOfDocsAndCNames objectForKey:[[billiPadClientNames objectAtIndex:section] lowercaseString]] count];
     //NSLog(@"numberOfRowsInSection-2");
}

/*- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"SearchResult";
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:MyIdentifier];
	
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] 
                 initWithStyle:UITableViewCellStyleDefault 
                 reuseIdentifier:MyIdentifier] autorelease];
    }
	
    id *data = [self.tableData objectAtIndex:indexPath.row];
    cell.textLabel.text = (NSString *)data;
    return cell;
}*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     //NSLog(@"cellForRowAtIndexPath-1");
    /*static NSString *CellIdentifier = @"Cell";
      //NSLog(@"numberOfRowsInSection-1");
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
     if (cell == nil) {
     cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
     }
     
     // Configure the cell...
     cell.textLabel.text = [NSString stringWithFormat:@"Document %d", indexPath.row];
     cell.textLabel.textColor = [UIColor blackColor];
     
     return cell;*/
    static NSString *CellIdentifier = @"Cell";
    chooseOrCreateNewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[[chooseOrCreateNewTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg1.png"]] autorelease];
    /*id *data = [self.tableData objectAtIndex:indexPath.row];
    cell.textLabel.text = (NSString *)data;*/
	//Bill *bill = [repo loadWithId:[[self.tableData objectAtIndex:indexPath.row] intValue]];
    
    NSString *tkey = [billiPadClientNames objectAtIndex:indexPath.section];
    NSArray *tarr = (NSArray *)[dictionaryOfDocsAndCNames objectForKey:[tkey lowercaseString]];
    Bill *bill = [repo loadWithId:[[tarr objectAtIndex:indexPath.row] intValue]];
	cell.clientNameLabel.text = [NSString stringWithFormat:@"%@ №%@ от %@", bill.DocumentType, bill.BillNumb, bill.BillDate];
    NSMutableString *str = [NSMutableString new];
    for (int i=0; i < [bill.Items count]-1; i++) {
        NSString *itemName = ((itemContainer *)[bill.Items objectAtIndex:i]).itemsName;
        [str appendFormat:@"%@, ", (!itemName || [itemName isEqualToString:@""]) ? @"Неназванный товар" : itemName];
    }
    [str appendFormat:@"%@", ((itemContainer *)[bill.Items objectAtIndex:[bill.Items count]-1]).itemsName];
    cell.billDetailsLabel.text = str;
   // cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.summaryLabel.text = [self collectSummaryFromBill:bill];
	
    //NSLog(@"cellForRowAtIndexPath-2");
    return cell;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section 
{
    //NSLog(@"viewForHeaderInSection-1");
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)] autorelease];
    [headerView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"table_header.png"]]];
    NSString *sectionHeader = nil;
    sectionHeader = [billiPadClientNames objectAtIndex:section];
	UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 0, tableView.bounds.size.width-12, 20)];
    [headerLabel setText:sectionHeader];
    [headerLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14.0]];
    [headerLabel setBackgroundColor:[UIColor clearColor]];
    [headerLabel setTextColor:[UIColor colorWithRed:0.29 green:0.133 blue:0 alpha:1]];
    [headerView addSubview:headerLabel];
    //NSLog(@"viewForHeaderInSection-2");
    return headerView;
     
}

- (NSArray *)doSearchWithKey:(NSString *)text
{
    if ([text isEqualToString:@""]) {
        return billiPadIds;
    }
    NSMutableArray *actualIds = [[NSMutableArray new] autorelease];
	for (int i=0; i<[billiPadIds count]; i++) {
		Bill *currentBill = [repo loadWithId:[[billiPadIds objectAtIndex:i] intValue]];
        {
            NSRange dateTextRange;
            dateTextRange =[[currentBill.BillDate lowercaseString] rangeOfString:[text lowercaseString]];
            
            NSRange numberTextRange;
            numberTextRange =[[currentBill.BillNumb lowercaseString] rangeOfString:[text lowercaseString]];
            
            NSRange clientNameTextRange;
            clientNameTextRange =[[currentBill.Client.ClientName lowercaseString] rangeOfString:[text lowercaseString]];
            
            NSRange itemsTextRange;
            BOOL wasFound = NO;
            for (int i = 0; i<[currentBill.Items count]; i++) {
                itemsTextRange =[[((itemContainer *)[currentBill.Items objectAtIndex:i]).itemsName lowercaseString] rangeOfString:[text lowercaseString]];
                if(itemsTextRange.location != NSNotFound)
                {
                    wasFound = YES;
                }
            }
            
            if((dateTextRange.location != NSNotFound) || (numberTextRange.location != NSNotFound) || (clientNameTextRange.location != NSNotFound) || wasFound)
            {
                [actualIds addObject:[billiPadIds objectAtIndex:i]];
            }
        }
    }
    return actualIds;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

- (int)calculateBillIdFromCellNumber:(int)row
{
    //NSLog(@"calculateBillIdFromCellNumber-1");
    return [[[repo getActualIdsWithType:dtype] objectAtIndex:([billiPadIds count] - row - 1)] intValue];
    //NSLog(@"calculateBillIdFromCellNumber-2");
}

- (NSString *)collectSummaryFromBill:(Bill *)bill
{
    //NSLog(@"collectSummaryFromBill-1");
	float a = 0.0;
	for (int i=0; i<[bill.Items count]; i++) {
		a += [((itemContainer *)[bill.Items objectAtIndex:i]) getItemsDoubleValueSummary];
	}
    //NSLog(@"collectSummaryFromBill-2");
	return [[NSString stringWithFormat:@"%.2f", a] stringByReplacingOccurrencesOfString:@"." withString:@","];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    DataViewController *dataViewController = [[DataViewController alloc] initWithFrame:CGRectMake(0, 0, 520, self.view.frame.size.height) docType:nil andBillId:[[(NSArray *)[dictionaryOfDocsAndCNames objectForKey:[[billiPadClientNames objectAtIndex:indexPath.section] lowercaseString]] objectAtIndex:indexPath.row] intValue]];
    
   
    
    [[StackScrollViewAppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:dataViewController invokeByController:self isStackStartView:FALSE];
	[dataViewController setDelegate:self];
    [dataViewController release];
}

#pragma mark -
#pragma mark Memory Management Methods

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];	
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //NSLog(@"numberOfSectionsInTableView-0");
	return [billiPadClientNames count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    //NSLog(@"titleForHeaderInSection-1");
	NSString *sectionHeader = nil;
    sectionHeader = [billiPadClientNames objectAtIndex:section];
    //NSLog(@"titleForHeaderInSection-2");
	return sectionHeader;
}

- (void)dealloc {
    [theTableView release], theTableView = nil;
    [theSearchBar release], theSearchBar = nil;
    [tableData dealloc];
    [horizLine release];
    [disableViewOverlay dealloc];
    [super dealloc];
}

@end