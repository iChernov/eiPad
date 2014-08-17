//
//  itemNameHints.h
//  E-Iphone
//
//  Created by Ivan Chernov on 20.04.11.
//  Copyright 2011 SKB-Kontur. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface itemNameHints : NSObject {
    NSMutableArray *hints, *loadedHints, *deletedHints;
    NSString *type;
}
-(id)initWithNameType;
-(id)initWithEdIzmType;
-(id)initWithClientNameType;
-(void)deleteHint:(id)hint;
-(NSString *)getHintAtIndex:(int)index;
-(NSArray *)getAllHintsContainingSubstring:(NSString *)substring;
-(void)tryToAddHint:(id)hint;
-(void)tryToAddNeededHint:(id)hint;
-(int)getNumberOfHints;
-(void)saveHints;
@end
