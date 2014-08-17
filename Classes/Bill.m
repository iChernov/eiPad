//
//  bill.m
//  E-Iphone
//
//  Created by Ivan Chernov on 01.12.10.
//  Copyright 2010 SKB-Kontur. All rights reserved.
//

#import "Bill.h"
#import "itemContainer.h"

@implementation Bill
@synthesize Client, BillDate, BillNumb, Items, Status, Timestamp, Id, Comment, Modified, Deleted, DocumentType;
- (id)init
{
	[super init];
	Deleted = NO;
	Modified = NO;
	Client = [[Contragent alloc] init];
	DocumentType = @"Счет";
	BillDate = @"";
	BillNumb = @"";
	Items = [[NSArray alloc] init];
	Status = @"";
	Timestamp = 0;
	Id = @"";
	Comment = @"";	
    
	return self;
}

- (id)initWithDictionary:(NSDictionary *)input
{
	self = [super init];
	self.Deleted = [[input objectForKey: @"Deleted"] isEqualToString:@"true"];
	self.Modified = [[input objectForKey: @"Modified"] isEqualToString:@"true"];
    self.Client = [[Contragent alloc] init];
    self.Client = [self makeClientFromArray:[input objectForKey: @"Client"]];
	self.BillDate = [self convertToNotNullObject:[input objectForKey:@"BillDate"]];
	self.BillNumb = [self convertToNotNullObject:[input objectForKey:@"BillNumb"]];
	self.Status = [self convertToNotNullObject:[input objectForKey:@"Status"]];
	self.DocumentType = ([input objectForKey:@"DocumentType"] ? [input objectForKey:@"DocumentType"] : @"Счет");
    if ([self.DocumentType isEqualToString:@"Счёт"]) {
        self.DocumentType = @"Счет";
    }
	self.Timestamp = ([input objectForKey:@"Timestamp"] ? [[input objectForKey:@"Timestamp"] longLongValue] : 0);
	self.Id = [self convertToNotNullObject:[input objectForKey:@"Id"]];
	self.Comment = [self convertToNotNullObject:[input objectForKey:@"Comment"]];
	self.Items = [self makeItemContainersArrayFromDictionaryArray:[input objectForKey:@"Items"]];
	return self;
}

- (id)initWithElbaDictionary:(NSDictionary *)input
{
	self = [super init];
	Deleted = [[input objectForKey: @"Deleted"] isEqualToString:@"true"];
	Modified = [[input objectForKey: @"Modified"] isEqualToString:@"true"];
    self.Client = [[Contragent alloc] init];
    self.Client = [self makeClientFromElbaArray:[input objectForKey: @"Client"]];
	self.BillDate = [self convertToNotNullObject:[input objectForKey:@"BillDate"]];
	self.BillNumb = [self convertToNotNullObject:[input objectForKey:@"BillNumb"]];
	self.Status = [self convertToNotNullObject:[input objectForKey:@"Status"]];
	self.DocumentType = ([input objectForKey:@"DocumentType"] ? [input objectForKey:@"DocumentType"] : @"Счет");
    if ([self.DocumentType isEqualToString:@"Счёт"]) {
        self.DocumentType = @"Счет";
    }
	self.Timestamp = ([input objectForKey:@"Timestamp"] ? [[input objectForKey:@"Timestamp"] longLongValue] : 0);
	self.Id = [self convertToNotNullObject:[input objectForKey:@"Id"]];
	self.Comment = [self convertToNotNullObject:[input objectForKey:@"Comment"]];
	self.Items = [self makeItemContainersArrayFromDictionaryArray:[input objectForKey:@"Items"]];
	return self;
}


- (Contragent *)makeClientFromArray:(NSArray *)clientArray
{
    Contragent *resultClient = [[Contragent alloc] init];
    resultClient.ElbaClientID = [clientArray objectAtIndex:1];
    resultClient.ClientName = [clientArray objectAtIndex:2]; 
    resultClient.Requisites.billsClientAddress = [clientArray objectAtIndex:3]; 
    resultClient.Requisites.billsClientINN = [clientArray objectAtIndex:4]; 
    resultClient.Requisites.billsClientKPP = [clientArray objectAtIndex:5]; 
    resultClient.Requisites.billsClientBIK = [clientArray objectAtIndex:6]; 
    resultClient.Requisites.billsClientBank = [clientArray objectAtIndex:7]; 
    resultClient.Requisites.billsClientRS = [clientArray objectAtIndex:8];
    resultClient.Requisites.billsClientKS = [clientArray objectAtIndex:9]; 
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *savedListOfHintsFileName = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/ClientHints.plist", [[NSUserDefaults standardUserDefaults] stringForKey:@"UserUID"]]];
        NSMutableDictionary *hints = [NSMutableDictionary dictionaryWithDictionary: [NSDictionary dictionaryWithContentsOfFile:savedListOfHintsFileName]];
        if ([[hints allKeys] containsObject:resultClient.ClientName]) {
            resultClient.iPhoneClientID = [[hints objectForKey:resultClient.ClientName] intValue];
        }
        else
        {
            
        }
    return resultClient;
}

- (Contragent *)makeClientFromElbaArray:(NSArray *)clientArray
{
    Contragent *resultClient = [[Contragent alloc] init];
    resultClient.ElbaClientID = [clientArray objectAtIndex:1];
    resultClient.ClientName = [clientArray objectAtIndex:2]; 
    resultClient.Requisites.billsClientAddress = [clientArray objectAtIndex:3]; 
    resultClient.Requisites.billsClientINN = [clientArray objectAtIndex:4]; 
    resultClient.Requisites.billsClientKPP = [clientArray objectAtIndex:5]; 
    resultClient.Requisites.billsClientRS = [clientArray objectAtIndex:6];
    resultClient.Requisites.billsClientBank = [clientArray objectAtIndex:9]; 
    resultClient.Requisites.billsClientKS = [clientArray objectAtIndex:8]; 
    resultClient.Requisites.billsClientBIK = [clientArray objectAtIndex:7]; 
    
    int trr = [[clientArray objectAtIndex:0] intValue];
    if (trr != 0) {
        resultClient.iPhoneClientID = trr;
    }
    else
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *savedListOfHintsFileName = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/ClientHints.plist", [[NSUserDefaults standardUserDefaults] stringForKey:@"UserUID"]]];
        NSMutableDictionary *hints = [NSMutableDictionary dictionaryWithDictionary: [NSDictionary dictionaryWithContentsOfFile:savedListOfHintsFileName]];
        if ([[hints allKeys] containsObject:resultClient.ClientName]) {
            resultClient.iPhoneClientID = [[hints objectForKey:resultClient.ClientName] intValue];
        }
        else
        {
            NSUserDefaults* nsudefs= [NSUserDefaults standardUserDefaults];
            int alfa = [nsudefs integerForKey:@"lastclientnumber"];
            alfa++;
            resultClient.iPhoneClientID = alfa;
            [nsudefs setInteger:alfa
                         forKey:@"lastclientnumber"];
        }
       
    }
    return resultClient;
}

- (Contragent *)makeClientFromString:(NSString *)clientStr
{
    Contragent *resultClient = [[Contragent alloc] init];
    resultClient.ClientName = clientStr; 
    return resultClient;
}

- (NSArray *)makeItemContainersArrayFromDictionaryArray:(NSArray *)itemDictionariesArray
{
	NSMutableArray *result = [NSMutableArray new];
	itemContainer *cont;
	for (int i = 0; i<[itemDictionariesArray count]; i++) {
		cont = [[itemContainer alloc] initWithItem:[itemDictionariesArray objectAtIndex:i]];
		[result addObject:cont];
		[cont release];
	}
	[result autorelease];
	return result;
}


- (id)convertToNotNullObject:(id)object
{
	if (object && ![object isEqual:[NSNull null]]) {
		return object;
	}
	return [NSString stringWithString:@""];
}

- (NSDictionary *)getDictionary
{
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  (Deleted ? @"true" : @"false"), @"Deleted",
						  (Modified ? @"true" : @"false"), @"Modified",
                          [self makeArrWithClient:Client], @"Client",
						  BillDate, @"BillDate",
						  BillNumb, @"BillNumb",
						  [self getItemsAsArrayOfDictionary], @"Items", 
						  Status, @"Status",
						  [NSNumber numberWithLongLong: Timestamp], @"Timestamp",
                          Comment, @"Comment",
						  DocumentType, @"DocumentType",
						  Id, @"Id",
						  nil];
    return dict;
}

-(NSArray *)makeArrWithClient:(Contragent *)billClient
{
    NSArray *tempClientArr = [[NSArray alloc] 
                                    initWithObjects:
                                    [[NSNumber alloc] initWithInt: billClient.iPhoneClientID],
                                    billClient.ElbaClientID,
                                    billClient.ClientName,
                                    billClient.Requisites.billsClientAddress,
                                    billClient.Requisites.billsClientINN,
                                    billClient.Requisites.billsClientKPP,
                                    billClient.Requisites.billsClientBIK,
                                    billClient.Requisites.billsClientBank,
                                    billClient.Requisites.billsClientRS,
                                    billClient.Requisites.billsClientKS,
                                    nil];
    return tempClientArr;
}

-(NSArray*) getItemsAsArrayOfDictionary
{
	NSMutableArray *result = [[NSMutableArray new] autorelease];
	for (int i = 0; i<[Items count]; i++) {
		[result addObject:[[Items objectAtIndex:i] toDictionary]];
	}
	return result;
}

-(Bill *)copy
{
	return [[Bill alloc] initWithDictionary:[self getDictionary]];
}

-(void)dealloc
{
    [super dealloc];
}

@end
