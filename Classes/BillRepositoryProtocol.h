//
//  BillRepository.h
//  E-Iphone
//
//  Created by Ivan Chernov on 15.11.10.
//  Copyright 2010 SKB-Kontur. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bill.h"


@protocol BillRepositoryProtocol

- (NSArray *)getAllBillIds;
- (NSArray *)getActualIds;
- (Bill *)loadWithId:(int)billId;
- (void)saveBill:(Bill *)bill withId:(int)billId;
- (int)saveNewBill:(Bill *)bill;
- (void)deleteBill:(int)billId;
@end
