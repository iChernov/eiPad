//
//  FillClientRequisitesTableViewController.m
//  eiPad
//
//  Created by Ivan Chernov on 16.08.11.
//  Copyright 2011 SKB-Kontur. All rights reserved.
//

#import "FillClientRequisitesTableViewController.h"


@implementation FillClientRequisitesTableViewController
@synthesize delegate, innCell, kppCell, bikCell, ksCell, rsCell;

- (id)initWithStyle:(UITableViewStyle)style andClientRequisites:(ClientRequsites *)clReq;
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization

        [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg2.png"]]];
        cR = [[ClientRequsites alloc] init];
        innIsWrongType1 = NO;
        innIsWrongType2 = NO;
        bikIsWrong = NO;
        kppIsWrong = NO;
        rsIsWrong = NO;
        ksIsWrong = NO;
        
        self.tableView.scrollEnabled = YES;  
        if (clReq) {
            [cR release];
            cR = [clReq retain];
        }
    }
    return self;
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
    
    self.navigationItem.title = @"Заполнение реквизитов клиента";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Готово" style:UIBarButtonItemStylePlain target:self action:@selector(dismissView:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Отмена" style:UIBarButtonItemStylePlain target:self action:@selector(dismissViewWithoutSaving:)];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

// Done button clicked
- (void)dismissView:(id)sender{
    if ([self checkAllFields]) {
        willExit = YES;
        [cR release];
        cR = [[ClientRequsites alloc] 
              initWithAddress:addressTF.text
              andINN:innTF.text
              andBankName:bankNameTF.text
              andBankBIK:bankBikTF.text
              andRS:rsTF.text
              andKS:ksTF.text
              andKPP:kppTF.text];
        
        // Call the delegate to dismiss the modal view
        [delegate didDismissModalViewWithClientRequisites: cR];
        [cR release];
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Необходимо ввести корректные данные перед сохранением" delegate:self cancelButtonTitle:@"Ок" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
}

- (BOOL)checkAllFields
{
    return ([self checkINN]&&[self checkKPP]&&[self checkBankBIK]&&[self checkRs]&&[self checkKs]);
}

- (void)dismissViewWithoutSaving:(id)sender {
    [delegate didDismissModalViewWithClientRequisites: cR];
    [cR release];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    willExit = NO;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [innTF addTarget:self action:@selector(checkINN) forControlEvents:UIControlEventEditingDidEnd];
    [kppTF addTarget:self action:@selector(goToBankName) forControlEvents:UIControlEventEditingDidBegin];
    [kppTF addTarget:self action:@selector(checkKPP) forControlEvents:UIControlEventEditingDidEnd];
    [bankBikTF addTarget:self action:@selector(checkBankBIK) forControlEvents:UIControlEventEditingDidEnd];
    [rsTF addTarget:self action:@selector(checkRs) forControlEvents:UIControlEventEditingDidEnd];
    [ksTF addTarget:self action:@selector(checkKs) forControlEvents:UIControlEventEditingDidEnd];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    willExit = YES;
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    willExit = YES;
	if (alertView.title == @"Неверный формат ИНН") {
		[innTF becomeFirstResponder];
	}
    if (alertView.title == @"Неверный формат КПП") {
		[kppTF becomeFirstResponder];
	}
    if (alertView.title == @"Неверный формат БИК") {
		[bankBikTF becomeFirstResponder];
	}
    if (alertView.title == @"Неверный формат расчетного счета") {
		[rsTF becomeFirstResponder];
	}
    if (alertView.title == @"Неверный формат корреспондентского счета") {
		[ksTF becomeFirstResponder];
	}
    willExit = NO;
}


- (BOOL)checkINN
{
    innIsWrongType1 = NO;
    innIsWrongType2 = NO;
    BOOL dataIsRight = YES;
    if ((!willExit)&&([innTF.text length] > 0)) {
        int numOfDigitsInINN = [innTF.text length];
        BOOL allCharactersAreDigits = YES;
        for (int i = 0; i< numOfDigitsInINN; i++) {
            char c = [innTF.text characterAtIndex:i];
            if(c<'0' || c>'9')
            {
                allCharactersAreDigits = NO;
            }
        }
        if (numOfDigitsInINN != 10 && numOfDigitsInINN != 12 || !allCharactersAreDigits) {
            innIsWrongType1 = YES;
            dataIsRight = NO;
        }
        else if (![self controlSumINNisRight]) {
            innIsWrongType2 = YES;
            dataIsRight = NO;
            [self resignFirstResponders];
            
        }
        if (numOfDigitsInINN == 12)
        {
            kppTF.enabled = NO;
            kppTF.text = nil;
            kppTF.placeholder = @"Отсутствует";
        }
        else {
            kppTF.enabled = YES;
            kppTF.placeholder = @"Введите КПП";
        }
    }
    
    innCell.attentionButton.hidden = (!innIsWrongType1)&&(!innIsWrongType2);
    innCell.attentionLabel.hidden = (!innIsWrongType1)&&(!innIsWrongType2);
    
    if (innIsWrongType1) {
        [innCell.attentionLabel setText:@"ИНН должен состоять из 10 или 12 цифр"];
    }
    else if (innIsWrongType2) {
        [innCell.attentionLabel setText:@"ИНН не прошёл форматный контроль"];
    }
    else
    {
        [innCell.attentionLabel setText:@""];
    }
    return dataIsRight;
}

- (void)refreshDisplay:(UITableView *)tableView {
    [self.tableView reloadData]; 
}

- (void)goToBankName
{
    if ([innTF.text length] == 12) {
        [bankNameTF becomeFirstResponder];
    }
}

- (BOOL)controlSumINNisRight
{
    BOOL resultOfCheck = YES;
    int numOfDigitsInINN = [innTF.text length];
    if (numOfDigitsInINN == 12)
    {
        NSString *innstr = innTF.text;
        NSUInteger length = [innstr length];
        int weights[10] = {7,2,4,10,3,5,9,4,6,8};
        int result = 0;
        for (NSUInteger i = 0; i < 10; i++)
        {
            result += weights[i]*[[innstr substringWithRange:NSMakeRange(i, 1)] intValue];
        }
        int ost = result % 11;
        if(ost == 10)
        {
            ost = 0;
        }
        if (ost != [[innstr substringWithRange:NSMakeRange(10, 1)] intValue]) {
            resultOfCheck = NO;
        }
        else
        {
            NSString *innstr = innTF.text;
            NSUInteger length = [innstr length];
            int weights[11] = {3,7,2,4,10,3,5,9,4,6,8};
            int result = 0;
            for (NSUInteger i = 0; i < 11; i++)
            {
                result += weights[i]*[[innstr substringWithRange:NSMakeRange(i, 1)] intValue];
            }
            int ost = result % 11;
            if(ost == 10)
            {
                ost = 0;
            }
            if (ost != [[innstr substringWithRange:NSMakeRange(11, 1)] intValue]) {
                resultOfCheck = NO;
            }
            else
            {
             //   [bankNameTF becomeFirstResponder];
            }
        }
    }
    if (numOfDigitsInINN == 10) {
        NSString *innstr = innTF.text;
        NSUInteger length = [innstr length];
        int weights[9] = {2,4,10,3,5,9,4,6,8};
        int result = 0;
        for (NSUInteger i = 0; i < length-1; i++)
        {
            result += weights[i]*[[innstr substringWithRange:NSMakeRange(i, 1)] intValue];
        }
        int ost = result % 11;
        if(ost == 10)
        {
            ost = 0;
        }
        if (ost != [[innstr substringWithRange:NSMakeRange(9, 1)] intValue]) {
            resultOfCheck = NO;
        }
    }
    return resultOfCheck;
    
}
- (BOOL)checkKPP
{
    kppIsWrong = NO;
    BOOL dataIsRight = YES;
    if (([innTF.text length] != 12)&&(!willExit)&&([kppTF.text length] > 0)) {
    int numOfDigitsInKPP = [kppTF.text length];
    BOOL allCharactersAreDigits = YES;
    for (int i = 0; i< numOfDigitsInKPP; i++) {
        char c = [kppTF.text characterAtIndex:i];
        if(c<'0' || c>'9')
        {
            allCharactersAreDigits = NO;
        }
    }
    
    if (numOfDigitsInKPP != 9 || !allCharactersAreDigits) {
        kppIsWrong = YES;
        [self.tableView reloadData];
        dataIsRight = NO;
    }
    }
    kppCell.attentionButton.hidden = !kppIsWrong;
    kppCell.attentionLabel.hidden = !kppIsWrong;

    if (kppIsWrong) {
        kppCell.attentionLabel.text = @"КПП должен состоять из 9 цифр";
    }
    else
    {
        kppCell.attentionLabel.text = @"";
    }
    return dataIsRight;
}

- (BOOL)checkBankBIK
{
    bikIsWrong = NO;
    BOOL dataIsRight = YES;
    if ((!willExit)&&([bankBikTF.text length] > 0)) {
        int numOfDigitsInBIK = [bankBikTF.text length];
        BOOL allCharactersAreDigits = YES;
        for (int i = 0; i< numOfDigitsInBIK; i++) 
        {
            char c = [bankBikTF.text characterAtIndex:i];
            if(c<'0' || c>'9')
            {
                allCharactersAreDigits = NO;
            }
        }
    
        if (numOfDigitsInBIK != 9 || !allCharactersAreDigits) {
            bikIsWrong = YES;
            [self.tableView reloadData];
            dataIsRight = NO;
        }
    }
    bikCell.attentionButton.hidden = !bikIsWrong;
    bikCell.attentionLabel.hidden = !bikIsWrong;
    if (bikIsWrong) {
        bikCell.attentionLabel.text = @"БИК должен состоять из 9 цифр";
    }
    else
    {
        bikCell.attentionLabel.text = @"";
    }
    return dataIsRight;
}

- (BOOL)checkRs
{
    rsIsWrong = NO;
    BOOL dataIsRight = YES;
    NSString *txt;
    if ((!willExit)&&([rsTF.text length] > 0)) {
    int numOfDigitsInRs = [rsTF.text length];
    BOOL allCharactersAreDigits = YES;
    for (int i = 0; i< numOfDigitsInRs; i++) {
        char c = [rsTF.text characterAtIndex:i];
        if(c<'0' || c>'9')
        {
            allCharactersAreDigits = NO;
        }
    }
    
    if (numOfDigitsInRs != 20 || !allCharactersAreDigits) {
        rsIsWrong = YES;
        [self.tableView reloadData];
        dataIsRight = NO;
        if (!allCharactersAreDigits) {
            txt = @"Расчетный счет должен состоять только из цифр.";
        }
        if (numOfDigitsInRs != 20) {
            txt = [NSString stringWithFormat: @"Введено символов:%d. Необходимо ввести 20 символов.", numOfDigitsInRs];
        }
    }
}
    rsCell.attentionButton.hidden = !rsIsWrong;
    rsCell.attentionLabel.hidden = !rsIsWrong;
    if (rsIsWrong) {
        rsCell.attentionLabel.text = txt;
    }
    else
    {
        rsCell.attentionLabel.text = @"";
    }
    return dataIsRight;
}

- (BOOL)checkKs
{
    ksIsWrong = NO;
    BOOL dataIsRight = YES;
     NSString *txt;
    if ((!willExit)&&([ksTF.text length] > 0)) {
        int numOfDigitsInKs = [ksTF.text length];
        BOOL allCharactersAreDigits = YES;
        for (int i = 0; i< numOfDigitsInKs; i++) {
            char c = [ksTF.text characterAtIndex:i];
            if(c<'0' || c>'9')
            {
                allCharactersAreDigits = NO;
            }
        }
        
        if (numOfDigitsInKs != 20 || !allCharactersAreDigits) {
            ksIsWrong = YES;
            [self.tableView reloadData];
            dataIsRight = NO;
            if (!allCharactersAreDigits) {
                txt = @"Корр.счет должен состоять только из цифр.";
            }
            if (numOfDigitsInKs != 20) {
                txt = [NSString stringWithFormat: @"Введено символов:%d. Необходимо ввести 20 символов.", numOfDigitsInKs];
            }
        }
    }
    ksCell.attentionButton.hidden = !ksIsWrong;
    ksCell.attentionLabel.hidden = !ksIsWrong;
    if (ksIsWrong) {
        ksCell.attentionLabel.text = txt;
    }
    else
    {
        ksCell.attentionLabel.text = @"";
    }
    return dataIsRight;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (section == 3 || section == 4) {
        return 2;
    }
    return 1;
}

- (void)resignFirstResponders
{
    [innTF resignFirstResponder];
    [kppTF resignFirstResponder];
    [bankBikTF resignFirstResponder];
    [bankNameTF resignFirstResponder];
    [addressTF resignFirstResponder];
    [rsTF resignFirstResponder];
    [ksTF resignFirstResponder];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Адрес";
            break;
            
        case 1:
            return @"ИНН";
            break;
            
        case 2:
            return @"КПП";
            break;
            
        case 3:
            return @"Название и БИК банка";
            break;
            
        case 4:
            return @"Рассчетный и корреспондентский счета";
            break;
            
        default:
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat: @"Cell%d%d", indexPath.section, indexPath.row];
    

    RequisitesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[RequisitesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.attentionLabel.hidden = YES;
        cell.txtField.clearButtonMode = UITextFieldViewModeUnlessEditing;
        if ([indexPath section] == 0) {
            cell.txtField.placeholder = @"Введите адрес, например: г.Москва, ул.Крауля 2, офис 7";
            cell.txtField.text = cR.billsClientAddress;
            cell.attentionButton.hidden = YES;
            [cell.txtField becomeFirstResponder];
            addressTF = cell.txtField;
        }
        if ([indexPath section] == 1) {
            innCell = cell;
            cell.txtField.placeholder = @"Введите ИНН";
            cell.txtField.text = cR.billsClientINN;
            if (innIsWrongType1) {
                cell.attentionButton.hidden = NO;
                [cell.attentionButton addTarget:self action:@selector(innDonNotHaveEnoughDigits) forControlEvents:UIControlEventTouchUpInside];
            }
            else if (innIsWrongType1) {
                cell.attentionButton.hidden = NO;
                [cell.attentionButton addTarget:self action:@selector(innHaveWrongFormat) forControlEvents:UIControlEventTouchUpInside];
            }
            else
            {
                cell.attentionButton.hidden = YES;
            }
            cell.txtField.keyboardType = UIKeyboardTypeNumberPad;
            innTF = cell.txtField;
        }
        
        if ([indexPath section] == 2) {
            kppCell = cell;
            cell.txtField.placeholder = @"Введите КПП";
            cell.txtField.text = cR.billsClientKPP;
            
            if (kppIsWrong) {
                cell.attentionButton.hidden = NO;
                [cell.attentionButton addTarget:self action:@selector(kppHaveWrongFormat) forControlEvents:UIControlEventTouchUpInside];
            }
            else
            {
                cell.attentionButton.hidden = YES;
            }
            
            cell.txtField.keyboardType = UIKeyboardTypeNumberPad;
            kppTF = cell.txtField;
            if ([innTF.text length] == 12) {
                kppTF.placeholder = @"Отсутствует";
                kppTF.enabled = NO;
            }
        }
        
        if ([indexPath section] == 3) {
            if ([indexPath row] == 0) {
                cell.txtField.placeholder = @"Введите название банка";
                cell.txtField.text = cR.billsClientBank;
                cell.attentionButton.hidden = YES;
                bankNameTF = cell.txtField;
            }
            else {
                bikCell = cell;
                cell.txtField.placeholder = @"Введите БИК банка";
                cell.txtField.keyboardType = UIKeyboardTypeNumberPad;
                cell.txtField.text = cR.billsClientBIK;
                if (bikIsWrong) {
                    cell.attentionButton.hidden = NO;
                    [cell.attentionButton addTarget:self action:@selector(bikHaveWrongFormat) forControlEvents:UIControlEventTouchUpInside];
                }
                else
                {
                    cell.attentionButton.hidden = YES;
                }
                bankBikTF = cell.txtField;
            }     
        }
        
        if ([indexPath section] == 4) {
            if ([indexPath row] == 0) {
                rsCell = cell;
                cell.txtField.placeholder = @"Введите расчетный счет";
                cell.txtField.keyboardType = UIKeyboardTypeNumberPad;
                cell.txtField.text = cR.billsClientRS;
                if (rsIsWrong) {
                    cell.attentionButton.hidden = NO;
                    [cell.attentionButton addTarget:self action:@selector(rsHaveWrongFormat) forControlEvents:UIControlEventTouchUpInside];
                }
                else
                {
                    cell.attentionButton.hidden = YES;
                }
                rsTF = cell.txtField;
            }
            else {
                ksCell = cell;
                cell.txtField.placeholder = @"Введите корреспондентский счет";
                cell.txtField.keyboardType = UIKeyboardTypeNumberPad;
                cell.txtField.text = cR.billsClientKS;
                if (ksIsWrong) {
                    cell.attentionButton.hidden = NO;
                    [cell.attentionButton addTarget:self action:@selector(ksHaveWrongFormat) forControlEvents:UIControlEventTouchUpInside];
                }
                else
                {
                    cell.attentionButton.hidden = YES;
                }

                ksTF = cell.txtField;
            }     
        }
        
        [cell setBackgroundColor:[UIColor whiteColor]];
        
    }
    
//    if (cell == nil) {
//        cell = [self.tableView dequeueReusableCellWithIdentifier:];
//    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
