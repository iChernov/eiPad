//
//  itemContainer.m
//  E-Iphone
//
//  Created by Exile on 28.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "itemContainer.h"
#import "itemRepository.h"
#import "itemNonmutableFields.h"
@implementation itemContainer
@synthesize  itemsName, itemsEdIzm, itemsCost, itemsSummary, itemsQty, itemDeleted;
-(id)init
{
	self = [super init];
	itemDeleted = [[NSNumber alloc] initWithInt:0];
	itemsName = @"";
	itemsQty = @"0";
	itemsEdIzm = @"";
	itemsCost = @"0";
	itemsSummary = @"0,00";
    iSaver = [[itemRepository alloc] init];
	return self;
}

-(id)initWithItem:(NSDictionary *) dict
{
	[self init];
	self.itemsName = [self convertToNotNullObject:[dict objectForKey:@"Name"]]; 
	self.itemsQty = [self convertToNotNullObject:[dict objectForKey:@"Qty"]]; //[dict objectForKey:@"Qty"];  
	self.itemsEdIzm = [self convertToNotNullObject:[dict objectForKey:@"Edizm"]]; 
	self.itemsCost = [self convertToNotNullObject:[dict objectForKey:@"Cost"]];  
	self.itemsSummary = [self convertToNotNullObject:[dict objectForKey:@"Summary"]]; 
	return self;
}
	
- (void)markItemAsDeleted
{
	itemDeleted = [[NSNumber alloc] initWithInt:1];
}

- (BOOL)itemMarkedAsDeleted
{
	return [itemDeleted intValue]==1;
}

-(NSDictionary *)toDictionary
{
	
	NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:
		   (itemsName ? itemsName : @""), @"Name", 
		   (itemsQty ? [itemsQty stringByReplacingOccurrencesOfString:@"," withString:@"."] : @""), @"Qty", 
		   (itemsEdIzm ? itemsEdIzm : @""), @"Edizm",
		   (itemsCost ? [itemsCost stringByReplacingOccurrencesOfString:@"," withString:@"."] : @""), @"Cost", 
		   (itemsSummary ? [itemsSummary stringByReplacingOccurrencesOfString:@"," withString:@"."] : @""), @"Summary",
		   nil];
	return result;
}

- (void)reCalculateSummary
{
	NSString *costText = [itemsCost stringByReplacingOccurrencesOfString:@"," withString:@"."];

   

	double cost;
	if ([costText rangeOfString:@"."].location == NSNotFound) 
	{
		cost = [costText intValue];
	}
	else 
	{
		cost = [costText doubleValue];
	}
    
        
        NSString *qtyText = [itemsQty stringByReplacingOccurrencesOfString:@"," withString:@"."];
        
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

	itemsSummary =  [[NSString alloc] initWithString:[NSString stringWithFormat:@"%.2f", resCost]];
	
}

- (void)tryToFillAllData
{
    if([iSaver doesExistItemWithName:itemsName])
    {
        itemNonmutableFields *itemF = [[iSaver loadItemWithName:itemsName] retain];
        itemsEdIzm = [[itemF getEdizm] retain];
        itemsCost = [[itemF getCost] retain];
        [itemF release];
    }
}

- (void)itemNameViewControllerDidFinishWithString:(NSString *)dataString
{
	itemsName = [[NSString alloc] initWithString:dataString];
    [self tryToFillAllData];
    [self reCalculateSummary];
}


- (void)itemPriceViewControllerDidFinishWithCost:(NSString *)costString
{

	itemsCost = [[NSString alloc] initWithString: [costString stringByReplacingOccurrencesOfString:@","
																						withString:@"."]];
	[self reCalculateSummary];	
    [iSaver saveItemWithName:itemsName andEdizm:itemsEdIzm andCost:itemsCost];
}

- (NSString *)getItemsName
{
	return [NSString stringWithString:itemsName];
}
- (int)getItemsQty
{
	return [NSString stringWithString:[itemsQty stringByReplacingOccurrencesOfString:@"." withString:@","]];
}
- (NSString *)getItemsEdIzm
{
	return [NSString stringWithString:itemsEdIzm];
}
- (NSString *)getItemsCost
{
	return [NSString stringWithString:[itemsCost stringByReplacingOccurrencesOfString:@"." withString:@","]];
}
- (NSString *)getItemsSummary
{
	return [NSString stringWithString:[itemsSummary stringByReplacingOccurrencesOfString:@"." withString:@","]];
}
- (double)getItemsDoubleValueSummary
{
	return [[itemsSummary stringByReplacingOccurrencesOfString:@"," withString:@"."] doubleValue];
}

- (NSString *)convertToNotNullObject:(id)object
{
    if (object && ![object isEqual:[NSNull null]]) {
		return object;
	}
	return [NSString stringWithString:@""];
}

- (void)dealloc
{
    [itemsEdIzm release];
    [itemsCost release];
    [iSaver release];
    [super dealloc];
}

@end
