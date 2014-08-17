//
//  BillsRequsites.h
//  E-Iphone
//
//  Created by Ivan Chernov on 15.06.11.
//  Copyright 2011 SKB-Kontur. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClientRequsites : NSObject
{
    NSString *billsClientAddress;
    NSString *billsClientINN;
    NSString *billsClientBank;
    NSString *billsClientRS;
    NSString *billsClientKS;
    NSString *billsClientKPP;
    NSString *billsClientBIK;
}
- (NSString *)convertToNotNullObject:(id)object;
- (id) initWithAddress:(NSString *)address
                andINN:(NSString *)inn
           andBankName:(NSString *)bankName
            andBankBIK:(NSString *)bankBIK
                 andRS:(NSString *)rs
                 andKS:(NSString *)ks
                andKPP:(NSString *)kpp;
- (void)pasteToSelfFromInputClient:(ClientRequsites *)inputBillsClientRequsites;
@property (nonatomic, retain) NSString *billsClientAddress;
@property (nonatomic, retain) NSString *billsClientINN;
@property (nonatomic, retain) NSString *billsClientBank;
@property (nonatomic, retain) NSString *billsClientRS;
@property (nonatomic, retain) NSString *billsClientKS;
@property (nonatomic, retain) NSString *billsClientKPP;
@property (nonatomic, retain) NSString *billsClientBIK;
@end
