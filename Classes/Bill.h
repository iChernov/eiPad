//
//  bill.h
//  E-Iphone
//
//  Created by Ivan Chernov on 01.12.10.
//  Copyright 2010 SKB-Kontur. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Contragent.h"

@interface Bill : NSObject {
	BOOL Deleted;
	BOOL Modified;
	Contragent *Client;
	NSString *BillDate;
	NSString *BillNumb;
	NSArray *Items;
	NSString *Status;
	NSString *DocumentType;
	long long Timestamp;
	NSString *Id; //это id от Эльбы
	NSString *Comment;
}
@property (nonatomic) BOOL Deleted;
@property (nonatomic) BOOL Modified;
@property (nonatomic, retain) Contragent *Client;
@property (nonatomic, retain) NSString *BillDate;
@property (nonatomic, retain) NSString *BillNumb;
@property (nonatomic, retain) NSString *Status;
@property (nonatomic, retain) NSString *Id;
@property (nonatomic, retain) NSString *Comment;
@property (nonatomic, retain) NSString *DocumentType;
@property (nonatomic, retain) NSArray *Items;
@property (nonatomic) long long Timestamp;

- (Contragent *)makeClientFromArray:(NSArray *)clientArray;
- (id)initWithDictionary:(NSDictionary *)input;
- (id)initWithElbaDictionary:(NSDictionary *)input;
- (Contragent *)makeClientFromElbaArray:(NSArray *)clientArray;
- (NSDictionary *)getDictionary;
- (NSString *)convertToNotNullObject:(id)object;
- (NSArray *)makeItemContainersArrayFromDictionaryArray:(NSArray *)itemDictionariesArray;
- (NSArray*) getItemsAsArrayOfDictionary;
- (NSArray *)makeArrWithClient:(Contragent *)billClient;

@end;
