//
//  itemNonmutableFields.h
//  E-Iphone
//
//  Created by Ivan Chernov on 18.04.11.
//  Copyright 2011 SKB-Kontur. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface itemNonmutableFields : NSObject {
    NSString *edIzm;
    NSString *cost;
}
@property (nonatomic, retain) NSString *edIzm;
@property (nonatomic, retain) NSString *cost;
-(id)initWithEdizm:(NSString *)e andCost:(NSString *)c;
-(NSString *)getEdizm;
-(NSString *)getCost;
@end
