//
//  itemService.h
//  E-Iphone
//
//  Created by Ivan Chernov on 20.04.11.
//  Copyright 2011 SKB-Kontur. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bill.h"

@interface itemService : NSObject {
    
}
- (void)saveItemsFromBill:(Bill *)bill;
- (void)refreshNeededHintsWithItems:(NSArray *)items;
@end
