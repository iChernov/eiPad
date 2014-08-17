//
//  itemNonmutableFields.m
//  E-Iphone
//
//  Created by Ivan Chernov on 18.04.11.
//  Copyright 2011 SKB-Kontur. All rights reserved.
//

#import "itemNonmutableFields.h"


@implementation itemNonmutableFields
@synthesize edIzm, cost;

-(id)initWithEdizm:(NSString *)e andCost:(NSString *)c
{
    self = [super init];
    edIzm = e;
    cost = c;
    return self;
}

-(NSString *)getEdizm
{
    return edIzm;
}

-(NSString *)getCost
{
    return cost;
}

-(void)dealloc
{
    [super dealloc];
}
@end
