//
//  BillRepository.m
//  E-Iphone
//
//  Created by Ivan Chernov on 26.11.10.
//  Copyright 2010 SKB-Kontur. All rights reserved.
//

#import "BillRepository.h"
#import "itemService.h"
#import "DocumentHintPickerController.h"
#import "itemNameHints.h"
@implementation BillRepository
- (id)init
{
	self = [super init];
	userDefs = [NSUserDefaults standardUserDefaults];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	pathToDocumentsFolder = [[NSString alloc] initWithString:[paths objectAtIndex:0]];
    NSString *comp = [pathToDocumentsFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/billiPhoneIds.plist", [userDefs stringForKey:@"UserUID"]]];
	billIdsFileName = [[NSString alloc] initWithString:comp];
	return self;
}

- (void)dealloc
{
	[pathToDocumentsFolder release];
	[billIdsFileName release];
	[super dealloc];
}

- (NSArray *)getAllBillIds
{
	return [[[NSArray alloc] initWithContentsOfFile:billIdsFileName] autorelease];
}

-(NSArray *)getActualIds
{
	NSArray *allIds = [self getAllBillIds];
	NSMutableArray *actualIds = [[NSMutableArray new] autorelease];
	for (int i=0; i<[allIds count]; i++) {
		Bill *currentBill = [self loadWithId:[[allIds objectAtIndex:i] intValue]];
		if (!currentBill.Deleted)
			[actualIds addObject:[allIds objectAtIndex:i]];
	}
	return actualIds;
}

-(NSString *)getActualIdsWithType:(NSString *)dtype
{
	NSArray *allIds = [self getAllBillIds];
	NSMutableArray *actualIds = [[NSMutableArray new] autorelease];
	for (int i=0; i<[allIds count]; i++) {
		Bill *currentBill = [self loadWithId:[[allIds objectAtIndex:i] intValue]];
		if ((!currentBill.Deleted)&&([dtype isEqualToString:@"AllDocs"] ? YES : [currentBill.DocumentType isEqualToString:dtype]))
        {
			[actualIds addObject:[allIds objectAtIndex:i]];
        }
	}
	return actualIds;
}

-(int)getCountOfBillsWhichNeedsSync
{
	int result = 0;
	NSArray *allIds = [self getAllBillIds];
	for (int i=0; i<[allIds count]; i++) {
		Bill *currentBill = [self loadWithId:[[allIds objectAtIndex:i] intValue]];
		if (!currentBill.Deleted && currentBill.Modified)
			result++;
	}
	return result;
}

- (Bill *)loadWithId:(int)billId
{
	NSDictionary *dct = [[NSDictionary alloc] initWithContentsOfFile:[self fileNameBy:billId]];
	Bill *bill = [[[Bill alloc] initWithDictionary:dct] autorelease];
	[dct release];
	return bill;
}

- (NSDictionary *)loadDictionariedBillWithId:(int)billId
{
    return [[[NSDictionary alloc] initWithContentsOfFile:[self fileNameBy:billId]] autorelease];
}

- (void)saveBill:(Bill *)bill withId:(int)billId
{
	[[bill getDictionary] writeToFile:[self fileNameBy:billId] atomically:YES];
    if(!bill.Deleted)
    {
        [self tryToAddClientHint:bill.Client];
        
        [self refreshItemsDictionary:bill];
    }
}

- (int)saveNewBill:(Bill *)bill
{
	int billId = [self saveIphoneBillIdToBillsFile];
	NSDictionary *dict = [bill getDictionary];
	[dict writeToFile:[self fileNameBy:billId] atomically:YES];
    [self refreshItemsDictionary:bill];
    [self tryToAddClientHint:bill.Client];
    return billId;
}

- (void)refreshItemsDictionary:(Bill *)bill
{
    [self tryToAddClientHint:bill.Client];
    itemService *iService = [[itemService alloc] init];
    [iService saveItemsFromBill:bill];
    [iService saveClientFromBill:bill];
    [iService release];
}

- (void)tryToAddClientHint:(Contragent *)Client
{
    [self saveClientToHints:Client];
}

- (void)saveClientToHints:(Contragent *)Client
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *savedListOfClientHintsFileName = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/ClientHints.plist", [userDefs stringForKey:@"UserUID"]]];
    NSMutableDictionary *hints = [[NSMutableDictionary alloc] initWithDictionary:[NSDictionary dictionaryWithContentsOfFile:savedListOfClientHintsFileName]];
    [hints setObject:[NSNumber numberWithInt:Client.iPhoneClientID] forKey:Client.ClientName];
    [hints writeToFile:savedListOfClientHintsFileName atomically:YES];
    NSString *clientFileName = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/Client-%d.plist", [userDefs stringForKey:@"UserUID"], Client.iPhoneClientID]];
    
    [[Client makeArr] writeToFile:clientFileName atomically:YES];
    

    itemNameHints *hint = [[itemNameHints alloc] initWithClientNameType];
    [hint tryToAddHint:Client.ClientName];
    [hint saveHints];
    [hint autorelease];
}

- (void)deleteBill:(int)billId
{
    NSMutableArray *billiPhoneIds = [[NSMutableArray alloc] initWithArray:[self getAllBillIds]];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:[self fileNameBy:billId] error:NULL];
	[billiPhoneIds removeObject:[NSNumber numberWithInt: billId]];
	[self saveBillIds:billiPhoneIds];
}

-(void)saveBillIds:(NSArray*) billIds
{
	[billIds writeToFile:billIdsFileName atomically:YES];	
}

-(int)saveIphoneBillIdToBillsFile
{	
    NSMutableArray *billIphoneIds = [[NSMutableArray alloc] initWithArray:[self getAllBillIds]];
	int lastBillId = -1;
	if ([billIphoneIds count] > 0) 
		lastBillId = [[billIphoneIds objectAtIndex:[billIphoneIds count] - 1] intValue];
    
	int billId = lastBillId + 1;
	[billIphoneIds addObject: [NSNumber numberWithInt:billId]];
	[self saveBillIds: billIphoneIds];
	[billIphoneIds release];
	return billId;
}

- (NSString *)fileNameBy:(int)billId
{
	
	return [pathToDocumentsFolder stringByAppendingPathComponent:[[[NSString alloc] initWithFormat:@"%@/%d-bill.plist", [userDefs stringForKey:@"UserUID"], billId] autorelease]];
}


@end
