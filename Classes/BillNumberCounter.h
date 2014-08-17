//
//  BillNumberCounter.h
//  eiPad
//
//  Created by Ivan Chernov on 11.08.11.
//  Copyright 2011 SKB-Kontur. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BillNumberCounter : NSObject {
    
}
+ (NSString *)growUpLastBillNumber:(NSString *)lastBillNumber withLastDigitCharacterAtIndex:(int)i andCharacterSet:(NSCharacterSet*) numSet;
+ (NSString *)findNextBillNumberForDocType:(NSString *)dtype;

@end
