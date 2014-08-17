//
//  BillNumberCounter.m
//  eiPad
//
//  Created by Ivan Chernov on 11.08.11.
//  Copyright 2011 SKB-Kontur. All rights reserved.
//

#import "BillNumberCounter.h"


@implementation BillNumberCounter
+ (NSString *)findNextBillNumberForDocType:(NSString *)dtype
{
    NSUserDefaults *userDefs = [NSUserDefaults standardUserDefaults];
	NSString *lastBillNumber = [userDefs stringForKey:[NSString stringWithFormat:@"%@-%@-lastBillNumber", dtype, [userDefs stringForKey:@"UserUID"]]];
	if (lastBillNumber != nil) {
        
		NSPredicate *regex = [NSPredicate
                              predicateWithFormat:@"SELF MATCHES '.*[.0-9].*'"];
		
		if ([regex evaluateWithObject:lastBillNumber] == YES)
		{
			NSCharacterSet* numSet = [NSCharacterSet decimalDigitCharacterSet];
			int i = [lastBillNumber length]-1;
			while(![numSet characterIsMember: [lastBillNumber characterAtIndex:i]])
			{
				i--;
			}
			lastBillNumber = [BillNumberCounter growUpLastBillNumber:lastBillNumber withLastDigitCharacterAtIndex:i andCharacterSet:numSet];
			return lastBillNumber;
		}
		else {
			return [NSString stringWithFormat:@"%@1",lastBillNumber];
		}
	}
	else {
		return @"1";
	}
}

+ (NSString *)growUpLastBillNumber:(NSString *)lastBillNumber withLastDigitCharacterAtIndex:(int)i andCharacterSet:(NSCharacterSet*) numSet
{
	if (![[NSString stringWithFormat:@"%c",[lastBillNumber characterAtIndex:i]] isEqualToString: @"9"]) {
		int a = [[NSString stringWithFormat:@"%c", [lastBillNumber characterAtIndex:i]] intValue];
		a++;
		return [lastBillNumber stringByReplacingCharactersInRange:NSMakeRange(i,1) withString:[NSString stringWithFormat:@"%d", a]];
	}
	else if([numSet characterIsMember: [lastBillNumber characterAtIndex:i-1]]){
		lastBillNumber = [lastBillNumber stringByReplacingCharactersInRange:NSMakeRange(i,1) withString:@"0"];
		return [self growUpLastBillNumber:lastBillNumber withLastDigitCharacterAtIndex:i-1 andCharacterSet:numSet];
		
	}
	else {
		return [lastBillNumber stringByReplacingCharactersInRange:NSMakeRange(i,1) withString:@"10"];
	}
	return nil;
}

@end
