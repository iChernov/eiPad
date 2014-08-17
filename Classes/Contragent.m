//
//  Client.m
//  E-Iphone
//
//  Created by Ivan Chernov on 16.06.11.
//  Copyright 2011 SKB-Kontur. All rights reserved.
//

#import "Contragent.h"

@implementation Contragent
@synthesize iPhoneClientID, ElbaClientID,ClientName, Requisites;

- (id)init
{
    [super init];
    iPhoneClientID = [self getNewClientID];
    ElbaClientID = @"";
    ClientName = @"";
    Requisites = [[ClientRequsites alloc] init];
    return self;
}

- (int)getNewClientID
{
    NSUserDefaults *nsudef = [NSUserDefaults standardUserDefaults];
    int tempClientID = [[nsudef valueForKey:@"newClientIDInNSNumber"] intValue];
    if (tempClientID == 0) {
        tempClientID ++;
    }
    [nsudef setValue:[NSNumber numberWithInt:(tempClientID+1)] forKey:@"newClientIDInNSNumber"];
    return tempClientID;
}
    
- (id)initWithClient:(Contragent *)inputClient
{
    self = [super init];
    [self pasteToSelfFromInputClient: inputClient];
    return self;
}

- (void)pasteToSelfFromInputClient:(Contragent *)inputClient
{
    iPhoneClientID = [inputClient getiPhoneClientID];
    ElbaClientID = [inputClient getElbaClientID];
    ClientName = [inputClient getClientName];
    [Requisites pasteToSelfFromInputClient:[inputClient getClientRequisites]];    
    //нет ошибки с глубинным копированием? Вроде не должно быть
}

-(NSArray *)makeArr
{
    NSArray *tempClientArr = [[NSArray alloc] 
                              initWithObjects:
                              [[NSNumber alloc] initWithInt: self.iPhoneClientID],
                              self.ElbaClientID,
                              self.ClientName,
                              self.Requisites.billsClientAddress,
                              self.Requisites.billsClientINN,
                              self.Requisites.billsClientKPP,
                              self.Requisites.billsClientBIK,
                              self.Requisites.billsClientBank,
                              self.Requisites.billsClientRS,
                              self.Requisites.billsClientKS,
                              
                              nil];
    return tempClientArr;
}

- (void)makeClientFromArray:(NSArray *)clientArray
{
    self.iPhoneClientID = [[clientArray objectAtIndex:0] intValue];
    self.ElbaClientID = [clientArray objectAtIndex:1];
    self.ClientName = [clientArray objectAtIndex:2]; 
    self.Requisites.billsClientAddress = [clientArray objectAtIndex:3]; 
    self.Requisites.billsClientINN = [clientArray objectAtIndex:4]; 
    self.Requisites.billsClientKPP = [clientArray objectAtIndex:5]; 
    self.Requisites.billsClientBIK = [clientArray objectAtIndex:6];
    self.Requisites.billsClientBank = [clientArray objectAtIndex:7]; 
    self.Requisites.billsClientRS = [clientArray objectAtIndex:8]; 
    self.Requisites.billsClientKS = [clientArray objectAtIndex:9]; 
}

@end
