//
//  itemNameHints.m
//  E-Iphone
//
//  Created by Ivan Chernov on 20.04.11.
//  Copyright 2011 SKB-Kontur. All rights reserved.
//

#import "itemNameHints.h"


@implementation itemNameHints

-(id)initWithNameType
{
    self = [super init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *listOfSavedHintsFileName = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/itemshints.plist", [[NSUserDefaults standardUserDefaults] stringForKey:@"UserUID"]]];
    NSString *listOfDeletedHintsFileName = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/deleteditemshints.plist", [[NSUserDefaults standardUserDefaults] stringForKey:@"UserUID"]]];
    
    
    hints = [[NSMutableArray alloc] init];
    [hints addObjectsFromArray:[[NSArray alloc] initWithContentsOfFile:listOfSavedHintsFileName]];
    
    deletedHints = [[NSMutableArray alloc] init];
    [deletedHints addObjectsFromArray:[[NSArray alloc] initWithContentsOfFile:listOfDeletedHintsFileName]];
    type = @"name";
    return self;
}

-(id)initWithClientNameType
{
    self = [super init];    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *listOfSavedHintsFileClient = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/hints.plist", [[NSUserDefaults standardUserDefaults] stringForKey:@"UserUID"]]];
    NSString *listOfDeletedHintsFileClient = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/deletedhints.plist", [[NSUserDefaults standardUserDefaults] stringForKey:@"UserUID"]]];
    
    hints = [[NSMutableArray alloc] init];
    [hints addObjectsFromArray:[[NSArray alloc] initWithContentsOfFile:listOfSavedHintsFileClient]];
    deletedHints = [[NSMutableArray alloc] init];
    [deletedHints addObjectsFromArray:[[NSArray alloc] initWithContentsOfFile:listOfDeletedHintsFileClient]];
    
    type = @"client";
    return self;
}

-(id)initWithEdIzmType
{
    self = [super init];
    hints = [[NSMutableArray alloc] init];
    


    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *listOfSavedHintsFileEdIzm = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/edizmhints.plist", [[NSUserDefaults standardUserDefaults] stringForKey:@"UserUID"]]];
    NSString *listOfDeletedHintsFileEdIzm = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/deletededizmhints.plist", [[NSUserDefaults standardUserDefaults] stringForKey:@"UserUID"]]];
    NSArray *initialHints = [NSArray arrayWithObjects:@"час",@"м³",@"м²",@"м",@"услуга",@"кг",@"шт", nil];
    [hints addObjectsFromArray:[[NSArray alloc] initWithContentsOfFile:listOfSavedHintsFileEdIzm]];
    for (int i = 0; i < [initialHints count]; i++) {
        NSString *lowerCaseHint = [[initialHints objectAtIndex:i] lowercaseString];
        if ([self search:lowerCaseHint] == -1) {
            [hints addObject:lowerCaseHint];
        }
    }
    deletedHints = [[NSMutableArray alloc] init];
    [deletedHints addObjectsFromArray:[[NSArray alloc] initWithContentsOfFile:listOfDeletedHintsFileEdIzm]];
    
    type = @"edizm";
    return self;
}

-(NSString *)getHintAtIndex:(int)index
{
    return [hints objectAtIndex:index];
}

-(NSArray *)getAllHints
{
    return hints;
}

-(NSArray *)getAllHintsContainingSubstring:(NSString *)substring
{
    NSMutableArray *result = [[NSMutableArray new] autorelease];
    for (int i = 0; i < [hints count]; i++) {
        if ([[[hints objectAtIndex:i] lowercaseString] rangeOfString:[substring lowercaseString]].location == NSNotFound) {
        }
        else {
            [result addObject:[hints objectAtIndex:i]];
        }
    }
    return result; 
}

-(int)getNumberOfHints
{
    return [hints count];
}

-(void)tryToAddHint:(id)hint
{
    NSString *lowerCaseHint = [(NSString*)hint lowercaseString];
    if (![lowerCaseHint isEqualToString:@""])
    {
        int i = [self search:lowerCaseHint];
        if (i >= 0) {
            [hints removeObjectAtIndex:i];
        }
        [hints addObject:hint];
    }
}

-(int)search:(NSString *)lowerCaseHint
{
    int alfa = -1;
    for (int i = 0; i<[hints count]; i++) {
        NSString *lccurrhint = [[hints objectAtIndex:i] lowercaseString];
        if ([lccurrhint isEqualToString:lowerCaseHint]) {
            alfa = i;
        }
    }
    return alfa;
}

-(void)tryToAddNeededHint:(id)hint
{
    NSString *lowerCaseHint = [(NSString*)hint lowercaseString];
    int ss = [self search:lowerCaseHint];
    if((![lowerCaseHint isEqualToString:@""])&&(![deletedHints containsObject:lowerCaseHint]))
    {
        if (ss >= 0) {
            [hints removeObjectAtIndex:ss];
        }
        [hints addObject:hint];
    }
}

-(void)deleteHint:(id)hint
{
    NSString *lowerCaseHint = [(NSString*)hint lowercaseString];
    if(![deletedHints containsObject:lowerCaseHint])
    {
        [deletedHints addObject:lowerCaseHint];
    }
    if([hints containsObject:hint])
    {
       [hints removeObject:hint]; 
    }
    
}
-(void)saveHints
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *listOfSavedHintsFileName;
    NSString *listOfDeletedHintsFileName;
    if([type isEqualToString:@"name"])
    {
        listOfSavedHintsFileName = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/itemshints.plist", [[NSUserDefaults standardUserDefaults] stringForKey:@"UserUID"]]];
        listOfDeletedHintsFileName = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/deleteditemshints.plist", [[NSUserDefaults standardUserDefaults] stringForKey:@"UserUID"]]];
    }
    else if([type isEqualToString:@"edizm"])
    {
        listOfSavedHintsFileName = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/edizmhints.plist", [[NSUserDefaults standardUserDefaults] stringForKey:@"UserUID"]]];
        listOfDeletedHintsFileName = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/deletededizmhints.plist", [[NSUserDefaults standardUserDefaults] stringForKey:@"UserUID"]]];

    }
    else if([type isEqualToString:@"client"])
    {
        listOfSavedHintsFileName = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/hints.plist", [[NSUserDefaults standardUserDefaults] stringForKey:@"UserUID"]]];
        listOfDeletedHintsFileName = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/deletedhints.plist", [[NSUserDefaults standardUserDefaults] stringForKey:@"UserUID"]]];
        
    }
    else
    {
        listOfSavedHintsFileName = @"";
        listOfDeletedHintsFileName = @"";

    }
    [hints writeToFile:listOfSavedHintsFileName atomically:YES];
    [deletedHints writeToFile:listOfDeletedHintsFileName atomically:YES];
}

- (void)dealloc
{
    [hints release];
    [deletedHints release];
    [type release];
    [super dealloc];
}
@end
