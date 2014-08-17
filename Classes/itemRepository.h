//
//  itemSaver.h
//  E-Iphone
//
//  Created by Ivan Chernov on 15.04.11.
//  Copyright 2011 SKB-Kontur. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "itemNonmutableFields.h"


@interface itemRepository : NSObject {
    
}

- (void)saveItemWithName:(NSString *)name andEdizm:(NSString *)edizm andCost:(NSString *)cost;
- (BOOL)doesExistItemWithName:(NSString *)name;
- (itemNonmutableFields *)loadItemWithName:(NSString *)name;
- (NSString *)getFilesPath;
- (NSDictionary *)getFullDictionary;
@end
