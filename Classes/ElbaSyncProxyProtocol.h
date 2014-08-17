//
//  ElbaSyncProxyProtocol.h
//  E-Iphone
//
//  Created by Ivan Chernov on 15.11.10.
//  Copyright 2010 SKB-Kontur. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bill.h"

@protocol ElbaSyncProxyProtocol

- (NSArray *)getChangedIds:(long long)timestamp;
- (NSString *)uploadBill:(Bill *)bill; //возвращаем строку с id и timestamp, разделёнными \n
- (Bill *)downloadBill:(NSString *)billId;


@end
