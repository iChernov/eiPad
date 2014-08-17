//
//  itemContainer.h
//  E-Iphone
//
//  Created by Exile on 28.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "itemRepository.h"



@interface itemContainer : NSObject {
	NSString *itemsName, *itemsEdIzm, *itemsCost, *itemsSummary;
	NSString *itemsQty;
	NSNumber *itemDeleted;
    itemRepository *iSaver;
}
@property (nonatomic, retain) NSString *itemsName;
@property (nonatomic, retain) NSString *itemsEdIzm;
@property (nonatomic, retain) NSString *itemsCost;
@property (nonatomic, retain) NSString *itemsSummary;
@property (nonatomic, retain) NSString *itemsQty;
@property (nonatomic, retain) NSNumber *itemDeleted;

-(id)init;
-(id)initWithItem:(NSDictionary *) dict;
- (NSString *)convertToNotNullObject:(id)object;
-(NSDictionary *)toDictionary;
- (NSString *)getItemsName;
- (int)getItemsQty;
- (NSString *)getItemsEdIzm;
- (NSString *)getItemsCost;
- (NSString *)getItemsSummary;
- (double)getItemsDoubleValueSummary;
- (void)reCalculateSummary;
- (void)itemNameViewControllerDidFinishWithString:(NSString *)dataString;
- (void)itemEdIzmViewControllerDidFinishWithQty:(int)qtyNumber andEdIzm:(NSString *)edIzmString;
//- (void)itemPriceViewControllerDidFinishWithCost:(NSString *)costString;
- (void)markItemAsDeleted;
- (BOOL)itemMarkedAsDeleted;

@end
