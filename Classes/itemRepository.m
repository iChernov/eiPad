//
//  itemSaver.m
//  E-Iphone
//
//  Created by Ivan Chernov on 15.04.11.
//  Copyright 2011 SKB-Kontur. All rights reserved.
//

#import "itemRepository.h"
#import "itemContainer.h"

@implementation itemRepository


- (void)saveItemWithName:(NSString *)name andEdizm:(NSString *)edizm andCost:(NSString *)cost
{
    NSMutableDictionary *hints = [[NSMutableDictionary alloc] initWithContentsOfFile:[self getFilesPath]];
    if(!hints)
    {
        hints = [NSMutableDictionary new];
    }
    NSArray *arr = [[NSArray alloc] initWithObjects:edizm, cost, nil];
    [hints setValue:arr forKey:[name lowercaseString]];
    [arr release];
    [hints writeToFile:[self getFilesPath] atomically:YES];
    [hints release];
}



- (BOOL)doesExistItemWithName:(NSString *)name
{
    NSMutableDictionary *hints = [[NSMutableDictionary alloc] initWithDictionary:[NSDictionary dictionaryWithContentsOfFile:[self getFilesPath]]];
    BOOL result = [[hints allKeys] containsObject:name];
    [hints release];
    return result;
}

- (NSString *)tryLoadItemWithName:(NSString *)name
{
    NSMutableDictionary *hints = [[NSMutableDictionary alloc] initWithDictionary:[NSDictionary dictionaryWithContentsOfFile:[self getFilesPath]]];
    NSArray *keys = [hints allKeys];
    NSMutableArray *lowerCaseHints = [NSMutableArray new];
    for (int i = 0; i < [keys count]; i++) {
        [lowerCaseHints addObject:[(NSString *)[keys objectAtIndex:i] lowercaseString]];
    }
    if (![lowerCaseHints containsObject:[name lowercaseString]]) {
        return @"";
    }
    int x = [lowerCaseHints indexOfObject:[name lowercaseString]];
    return (NSString *)[keys objectAtIndex:x];
}

- (itemNonmutableFields *)loadItemWithName:(NSString *)name
{
    NSArray *arr = [[NSDictionary dictionaryWithContentsOfFile:[self getFilesPath]] objectForKey:name];
    return [[itemNonmutableFields alloc] initWithEdizm:[arr objectAtIndex:0] andCost:[arr objectAtIndex:1]];
}
                                              
- (NSDictionary *)getFullDictionary
{
    return [NSDictionary dictionaryWithContentsOfFile:[self getFilesPath]];
}

- (void)saveFullDictionary:(NSDictionary *)receivedDict
{
    [receivedDict writeToFile:[self getFilesPath] atomically:YES];
}

- (NSString *)getFilesPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/fullitemshints.plist", [[NSUserDefaults standardUserDefaults] stringForKey:@"UserUID"]]];
    return fileName;
}



@end
