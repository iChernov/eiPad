//
//  BillsRequsites.m
//  E-Iphone
//
//  Created by Ivan Chernov on 15.06.11.
//  Copyright 2011 SKB-Kontur. All rights reserved.
//

#import "ClientRequsites.h"

@implementation ClientRequsites
@synthesize billsClientAddress, billsClientINN, billsClientBank, billsClientRS, billsClientBIK, billsClientKS, billsClientKPP;
- (id)init
{
    self = [super init];
    if (self) {
        billsClientAddress = @"";
        billsClientINN = @"";
        billsClientBank = @"";
        billsClientRS = @"";
        billsClientBIK = @"";
        billsClientKS = @"";
        billsClientKPP = @"";
    }
    
    return self;
}

- (id) initWithAddress:(NSString *)address
                andINN:(NSString *)inn
           andBankName:(NSString *)bankName
            andBankBIK:(NSString *)bankBIK
                 andRS:(NSString *)rs
                 andKS:(NSString *)ks
                andKPP:(NSString *)kpp
{
    self = [super init];
    if (self) {
        billsClientAddress = [self convertToNotNullString:address];
        billsClientINN = [self convertToNotNullString:inn];
        billsClientBank = [self convertToNotNullString:bankName];
        billsClientRS = [self convertToNotNullString:rs];
        billsClientBIK = [self convertToNotNullString:bankBIK];
        billsClientKS = [self convertToNotNullString:ks];
        billsClientKPP = [self convertToNotNullString:kpp];
        
    }
    return self;
}

- (void)pasteToSelfFromInputClient:(ClientRequsites *)inputBillsClientRequsites
{
    billsClientAddress = inputBillsClientRequsites.billsClientAddress;
    billsClientINN = inputBillsClientRequsites.billsClientINN;
    billsClientBank = inputBillsClientRequsites.billsClientBank;
    billsClientRS = inputBillsClientRequsites.billsClientRS;
    billsClientBIK = inputBillsClientRequsites.billsClientBIK;
    billsClientKS = inputBillsClientRequsites.billsClientKS;
    billsClientKPP = inputBillsClientRequsites.billsClientKPP;
}

- (NSString *)convertToNotNullString:(NSString *)object
{
    if (object && ![object isEqual:[NSNull null]] && ![object isEqualToString:@""]) {
		return object;
	}
	return [NSString stringWithString:@""];
}
@end
