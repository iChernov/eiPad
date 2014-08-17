//
//  Client.h
//  E-Iphone
//
//  Created by Ivan Chernov on 16.06.11.
//  Copyright 2011 SKB-Kontur. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClientRequsites.h"

@interface Contragent : NSObject {
    int iPhoneClientID;
    NSString *ElbaClientID;
    NSString *ClientName;
    ClientRequsites *Requisites;
}
@property (nonatomic) int iPhoneClientID;
@property (nonatomic, retain) NSString *ElbaClientID;
@property (nonatomic, retain) ClientRequsites *Requisites;
@property (nonatomic, retain) NSString *ClientName;

- (void)makeClientFromArray:(NSArray *)clientArray;
-(NSArray *)makeArr;
@end
