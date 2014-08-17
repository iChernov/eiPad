//
//  Syncronizer.m
//  E-Iphone
//
//  Created by Ivan Chernov on 15.11.10.
//  Copyright 2010 SKB-Kontur. All rights reserved.
//

#import "Synchronizer.h"


@implementation Synchronizer
@synthesize delegate;

- (id)init
{
	self = [super init];
	return self;
}
- (id)initWithProxy:(id <ElbaSyncProxyProtocol, NSObject>)proxy andRepository:(id <BillRepositoryProtocol, NSObject>)repository
{
	[super init];
	self_proxy = [proxy retain];
	self_repository = [repository retain];
	return self;
}

-(void) dealloc
{
	[self_proxy release];
	[self_repository release];
	[super dealloc];
}

- (void)synchronize
{
	NSDictionary* iPhoneBills = [self loadAllIphoneBills];
    [self processElbaBills: iPhoneBills]; //грузим счета, изменённые/созданные на эльбе
    [self processIPhoneBills: iPhoneBills]; //порядок не менять - сломаю руку.
}


-(NSDictionary*)loadAllIphoneBills
{
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	NSArray *allIPhoneBillIds = [self_repository getAllBillIds];
	for (NSNumber *iPhoneBillId in allIPhoneBillIds)
		[result setObject: [self_repository loadWithId:[iPhoneBillId intValue]] forKey:iPhoneBillId];
	return result;
}

- (void)processElbaBills:(NSDictionary*) iPhoneBills
{
    long long huj = 0;
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"wasSyncedAfterUpdateTo110"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"wasSyncedAfterUpdateTo110"];
    }
    else
    {
        huj = [self getMaxTimestamp:iPhoneBills];
    }
	NSArray *elbaChangedIds = [self_proxy getChangedIds: huj];
	NSDictionary *elbaIdToIPhoneIdMap = [self createElbaIdToIPhoneIdMap: iPhoneBills];
	for(NSString *elbaBillId in elbaChangedIds) {
		BOOL modifiedOnIphone = NO;
		NSNumber *iPhoneBillId = [[elbaIdToIPhoneIdMap objectForKey:elbaBillId] retain];
		if (iPhoneBillId != nil)
		{
			modifiedOnIphone = ((Bill *)[iPhoneBills objectForKey:iPhoneBillId]).Modified;
		}
		if (!modifiedOnIphone) //если подгруженный с Эльбы счет не был изменён на айфоне - его нужно записать. Если был - то ничего не делаем, мы главнее!
		{
			Bill *bill = [self_proxy downloadBill:elbaBillId];
			[self updateIphoneBill:bill withId:iPhoneBillId];
		}
		[iPhoneBillId release];
	}
}

- (Bill *)update: (Bill *)bill with:(NSString *) uploadResult
{
	long delimiterPosition = [uploadResult rangeOfString: @"\n"].location;
	bill.Id = [uploadResult substringToIndex: delimiterPosition]; 
	bill.Timestamp = [[uploadResult substringFromIndex: delimiterPosition + 1] longLongValue]; 
	bill.Modified = NO;
    
	return bill;
}

-(long long)getMaxTimestamp:(NSDictionary*) bills
{
	long long result = 0;
    
	NSArray* iPhoneBillIds = [bills allKeys];
	for (NSNumber *iPhoneBillId in iPhoneBillIds) {
		long long timestamp = ((Bill *)[bills objectForKey:iPhoneBillId]).Timestamp;
		result = MAX(result, timestamp);
	}
	return result;
}

- (void)processIPhoneBills:(NSDictionary*) bills
{
	NSArray* iPhoneBillIds = [bills allKeys];
	for (NSNumber *iPhoneBillId in iPhoneBillIds)
    {
		[self processIPhoneBill: [bills objectForKey:iPhoneBillId] withId: iPhoneBillId];
    }
}

- (void)uploadOnly:(int)bid
{
    [self processIPhoneBill:[self_repository loadWithId:bid] withId:[NSNumber numberWithInt: bid]];
    //uploadingBill.Modified = NO;
}

- (void)processIPhoneBill:(Bill *) bill withId:(NSNumber*) iPhoneBillId
{
	if(!bill.Modified)
		return;
	if(bill.Id == @"" && bill.Deleted) {
		[self_repository deleteBill:[iPhoneBillId intValue]];
		return;
	}
	NSString *uploadResult = [self_proxy uploadBill:bill];
	if (bill.Deleted)
		[self_repository deleteBill:[iPhoneBillId intValue]];
	else
		[self_repository saveBill:[self update:bill with:uploadResult] withId:[iPhoneBillId intValue]];
}

- (NSDictionary*) createElbaIdToIPhoneIdMap:(NSDictionary*) bills
{
	NSMutableDictionary *result = [NSMutableDictionary new];
	NSArray* iPhoneBillIds =[bills allKeys];
    
	
	
	for (NSNumber *iPhoneBillId in iPhoneBillIds)
	{
		NSString *elbaBillId = ((Bill *)[bills objectForKey:iPhoneBillId]).Id;
		if(elbaBillId != nil)
			[result setObject:iPhoneBillId forKey:elbaBillId];
	}	
	[result autorelease];
	return result;
}
- (void)updateIphoneBill:(Bill *)bill withId:(NSNumber *)iPhoneBillId
{
	if(bill.Id == @"")
	{
		if (iPhoneBillId != nil)
			[self_repository deleteBill:[iPhoneBillId intValue]];
	}
	else if(iPhoneBillId == nil)
    {
		[self_repository saveNewBill:bill];
        [[NSUserDefaults standardUserDefaults] setValue:bill.BillNumb forKey:[NSString stringWithFormat:@"%@-%@-lastBillNumber", bill.DocumentType, [[NSUserDefaults standardUserDefaults] stringForKey:@"UserUID"]]];
    }
	else 
		[self_repository saveBill:bill withId:[iPhoneBillId intValue]];
}
@end
